# Module `ETLCtrl.ScopeCtrl`

This module builds, persists, and exports the scope of stay data that the ETL
layer must monitor and extract.

It works in two stages:

1. `StayMonitoringScope`: long-lived scope explaining **what must be monitored**.
2. `StayExtractionScope`: point-in-time scope explaining **what must be extracted now**.

The main input is an `InfectiousStatus`. The main output for downstream ETL is a
`StayExtractionScopeDTO`, which is meant to be exchanged with the hospital
information system/source system so it can return the requested stay data.

## Related models

### `src/Model/StayMonitoringScope.jl`

A monitoring scope can target:

- one patient: `monitoredPatient`
- one unit: `monitoredUnit`
- and is justified by `justifyingInfectiousStatus`

Important fields:

- `periodOiStartTime`
- `periodOiEndTime`
- `activationTime`
- `deactivationTime`
- `stayExtractionScopes`

### `src/Model/StayExtractionScope.jl`

A requested extraction linked to one `StayMonitoringScope`.

Important fields:

- `stayMonitoringScope`
- `periodOiStartTime`
- `periodOiEndTime`
- `requestTime`

### `src/Model-protected/DTO/StayExtractionScopeDTO.jl`

A DTO used when sending extraction instructions outside the core model,
typically for exchange with the hospital information system/source system.

Important fields:

- `id`
- `requestTime`
- `periodOiStartTime`
- `periodOiEndTime`
- `monitoredUnitCodeName`
- `monitoredPatientRef`
- `extractionScopesIds`

`monitoredPatientRef` is decrypted through `PatientCtrl.getPatientDecrypt(...)`
and therefore requires `encryptionStr`.

## Public functions

### `buildStayMonitoringScopeList(infectiousStatus, dbconn)`

Builds the list of `StayMonitoringScope` objects implied by one
`InfectiousStatus`.

Behavior:

- lazily reloads `infectiousStatus` if `patient` or `infectiousStatus` is missing
- returns `nothing` if the infectious status is not in
  `INFECTIOUS_STATUS_TYPES_AT_RISK`
- always creates one **patient-oriented** monitoring scope
- for `carrier` and `suspicion`, also creates **unit-oriented** scopes for the
  units visited by the patient since the infectious-status stay
- for `contact`, the comments say the scope should be restricted to the current
  hospitalization, but the current implementation still creates the patient
  scope with `periodOiStartTime = missing` and `periodOiEndTime = missing`
- does **not** persist the scopes

Dependencies:

- `StayCtrl.retrieveOneStay(infectiousStatus, dbconn)`
- `StayCtrl.getSortedPatientStays(patient, dbconn)`

### `createStayMonitoringScopeListIfNotExist(infectiousStatus, dbconn)`

Creates the monitoring scopes in the database if they do not already exist.

Behavior:

- calls `buildStayMonitoringScopeList(...)`
- returns `nothing` if no scope should exist
- checks for an existing row with the same:
  - `justifyingInfectiousStatus`
  - `monitoredUnit`
  - `monitoredPatient`
  - `periodOiStartTime`
  - `periodOiEndTime`
- persists only missing scopes
- returns the final list of persisted or reused `StayMonitoringScope` objects

### `refreshStayMonitoringScopes(dbconn)`

Refreshes persisted monitoring scopes from current at-risk infectious statuses.

Behavior:

- calls `InfectiousStatusCtrl.getCurrentInfectiousStatusesAtRisk(dbconn)`
- calls `createStayMonitoringScopeListIfNotExist(...)` for each returned status
- skips statuses for which no monitoring scope should exist
- returns the flattened list of persisted or reused monitoring scopes touched by
  the refresh

### `getActiveStayMonitoringScopes(dbconn)`

Retrieves monitoring scopes that are currently active.

Behavior:

- reads from `etl.stay_monitoring_scope`
- only returns rows where `deactivation_time IS NULL`
- orders results by `activation_time, id`
- retrieves ORM entities without complex properties

### `buildStayExtractionScope(stayMonitoringScope, dbconn)`

Builds one `StayExtractionScope` from one `StayMonitoringScope`.

Behavior:

- sets `requestTime = now(TRAQUERUtil.getTimeZone())`
- currently copies `periodOiStartTime` and `periodOiEndTime` directly from the
  monitoring scope
- initializes `id` with a random UUID string before persistence so DTO
  `extractionScopesIds` can be populated reliably
- does **not** persist the object

Note: the source code contains a TODO saying the extraction period should later
be more restrictive than the monitoring period.

### `createStayExtractionScope(stayMonitoringScope, dbconn)`

Builds and persists one `StayExtractionScope`.

Behavior:

- requires `stayMonitoringScope.id` to be present
- throws `ArgumentError` if the monitoring scope is not already persisted
- calls `buildStayExtractionScope(...)`
- persists the result with `PostgresORM.create_entity!(...)`

### `prepareStayExtractionScopeDTO(stayExtractionScope, encryptionStr, dbconn)`

Builds a transport DTO from a `StayExtractionScope`.

This DTO is the exchange payload intended to be sent to the hospital side so
that the hospital information system can understand which patient/unit and time
window must be extracted.

Behavior:

- lazily reloads the linked `StayMonitoringScope` if needed
- resolves `monitoredUnitCodeName` from `monitoredUnit.codeName`
- resolves `monitoredPatientRef` by decrypting the patient ref
- stores the source extraction-scope ID in `extractionScopesIds`
- returns `Model.DTO.StayExtractionScopeDTO`

Important note: the implementation creates a fresh random UUID for the DTO `id`

### `mergeStayExtractionScopeDTOs(stayExtractionScopeDTOs)`

Merges DTOs that target the same unit/patient pair.

Behavior:

- groups DTOs by `(monitoredUnitCodeName, monitoredPatientRef)`
- keeps the least restrictive period:
  - `periodOiStartTime = missing` if either merged DTO start is missing,
    otherwise the earliest start time
  - `periodOiEndTime = missing` if either merged DTO end is missing, otherwise
    the latest end time
- keeps the earliest non-missing `requestTime`
- concatenates `extractionScopesIds` from merged DTOs
- keeps the first DTO `id` for the merged result
- sorts the returned DTOs for deterministic output

### `getStayExtractionScopeDTOsForExtraction(encryptionStr, dbconn)`

Runs the end-to-end extraction-scope workflow and returns DTOs ready for the
hospital information system/source system.

Behavior:

1. calls `refreshStayMonitoringScopes(dbconn)`
2. retrieves active monitoring scopes with `getActiveStayMonitoringScopes(dbconn)`
3. creates and persists one `StayExtractionScope` for each active monitoring
   scope
4. converts each extraction scope to a `StayExtractionScopeDTO`
5. merges DTOs that target the same unit/patient pair
6. returns the merged DTO list

## Typical workflow

```julia
using TRAQUER

dbconn = TRAQUERUtil.openDBConn()
try
    encryptionStr = "..."
    dtoList = ETLCtrl.ScopeCtrl.getStayExtractionScopeDTOsForExtraction(
        encryptionStr,
        dbconn,
    )
    # Send dtoList to the source-system ETL integration.
finally
    close(dbconn)
end
```

For lower-level workflows, use the stages explicitly:

1. derive and persist monitoring scopes with
   `createStayMonitoringScopeListIfNotExist(...)`,
2. retrieve active monitoring scopes with `getActiveStayMonitoringScopes(...)`,
3. create extraction scopes with `createStayExtractionScope(...)`,
4. convert them with `prepareStayExtractionScopeDTO(...)`,
5. optionally merge them with `mergeStayExtractionScopeDTOs(...)`.

## Practical expectations

- `infectiousStatus.id` should be set
- for lazy loading to work correctly, the referenced database rows must exist
- `prepareStayExtractionScopeDTO(...)` and
  `getStayExtractionScopeDTOsForExtraction(...)` require a valid `encryptionStr`
- `createStayExtractionScope(...)` requires a persisted `StayMonitoringScope`
- `buildStayMonitoringScopeList(...)` assumes a carrier/suspicion patient has at
  least one stay; otherwise `first(stays)` / `last(stays)` would fail
- active monitoring scopes are currently defined only by missing `deactivationTime`

## Summary

Use this module when you need to:

1. derive monitoring scopes from infectious statuses,
2. persist those scopes idempotently,
3. retrieve the currently active monitoring scopes,
4. derive and persist extraction requests from them,
5. convert extraction requests into DTOs consumable by ETL integrations,
6. merge equivalent extraction requests before sending them downstream.
