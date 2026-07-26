# Module `ETLCtrl.ScopeCtrl`

This module builds and persists the scope of stay data that the ETL layer must
monitor and extract.

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

- `requestTime`
- `periodOiStartTime`
- `periodOiEndTime`
- `monitoredUnitCodeName`
- `monitoredPatientRef`

`monitoredPatientRef` is decrypted through `PatientCtrl.getPatientDecrypt(...)`
and therefore requires `encryptionStr`.

## Public functions

## `buildStayMonitoringScopeList(infectiousStatus, dbconn)`
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

Dependencies:

- `StayCtrl.retrieveOneStay(infectiousStatus, dbconn)`
- `StayCtrl.getSortedPatientStays(patient, dbconn)`

## `createStayMonitoringScopeListIfNotExist(infectiousStatus, dbconn)`
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

## `buildStayExtractionScope(stayMonitoringScope, dbconn)`
Builds one `StayExtractionScope` from one `StayMonitoringScope`.

Behavior:

- sets `requestTime = now(TRAQUERUtil.getTimeZone())`
- currently copies `periodOiStartTime` and `periodOiEndTime` directly from the
  monitoring scope
- does **not** persist the object

Note: the source code contains a TODO saying the extraction period should later
be more restrictive than the monitoring period.

## `createStayExtractionScope(stayMonitoringScope, dbconn)`
Builds and persists one `StayExtractionScope`.

Behavior:

- requires `stayMonitoringScope.id` to be present
- throws `ArgumentError` if the monitoring scope is not already persisted
- calls `buildStayExtractionScope(...)`
- persists the result with `PostgresORM.create_entity!(...)`

## `prepareStayExtractionScopeDTO(stayExtractionScope, encryptionStr, dbconn)`
Builds a transport DTO from a `StayExtractionScope`.

This DTO is the exchange payload intended to be sent to the hospital side so
that the hospital information system can understand which patient/unit and time
window must be extracted.

Behavior:

- lazily reloads the linked `StayMonitoringScope` if needed
- resolves `monitoredUnitCodeName` from `monitoredUnit.codeName`
- resolves `monitoredPatientRef` by decrypting the patient ref
- returns `Model.DTO.StayExtractionScopeDTO`

Important note: the implementation creates a fresh random UUID for the DTO `id`
with `UUIDs.uuid4()`, even though the DTO comment says it is a copy of
`StayExtractionScope.id`.

## Typical workflow

```julia
using TRAQUER

dbconn = TRAQUERUtil.openDBConnAndBeginTransaction()

infectiousStatus = InfectiousStatus(id = infectious_status_id)

stayMonitoringScopes = ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(
    infectiousStatus,
    dbconn,
)

if !isnothing(stayMonitoringScopes)
    for stayMonitoringScope in stayMonitoringScopes
        stayExtractionScope = ETLCtrl.ScopeCtrl.createStayExtractionScope(
            stayMonitoringScope,
            dbconn,
        )

        dto = ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO(
            stayExtractionScope,
            encryptionStr,
            dbconn,
        )

        # Send dto to the hospital/source-system integration layer
    end
end
```

## Practical expectations

- `infectiousStatus.id` should be set
- for lazy loading to work correctly, the referenced database rows must exist
- `prepareStayExtractionScopeDTO(...)` requires a valid `encryptionStr`
- `createStayExtractionScope(...)` requires a persisted `StayMonitoringScope`
- `buildStayMonitoringScopeList(...)` assumes a carrier/suspicion patient has at
  least one stay; otherwise `first(stays)` / `last(stays)` would fail

## Summary

Use this module when you need to:

1. derive monitoring scopes from an infectious status,
2. persist those scopes idempotently,
3. derive extraction requests from them,
4. convert extraction requests into DTOs consumable by ETL integrations.
