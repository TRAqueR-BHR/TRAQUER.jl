# AGENTS.md

Guidance for coding agents working in this repository.

## Project overview

TRAQUER.jl is a Julia healthcare/infectious-disease tracking application. It uses
PostgreSQL via PostgresORM, ETL pipelines for stays/analyses, a Mux-based web API,
scheduled tasks, and hospital-specific custom modules under `custom/`.

Core domain concepts:
- `InfectiousStatus` drives `EventRequiringAttention` generation.
- `Outbreak` relates to infectious statuses through `OutbreakInfectiousStatusAsso`.
- Patient risk/stay logic lives mainly in `StayCtrl` and `InfectiousStatusCtrl`.
- Sensitive patient values are stored through encrypted model variants such as
  `PatientNameCrypt`, `PatientBirthdateCrypt`, `PatientRefCrypt`, and decrypted
  through protected access patterns.

## Repository layout

- `src/TRAQUER.jl` — top-level module wiring submodules together.
- `src/Model/` — generated/ORM-backed entity structs.
- `src/Model-protected/` — protected/sensitive models such as `Appuser` and
  `PatientDecrypt`.
- `src/ORM/` and `src/ORM-tracking/` — PostgresORM mapping and overrides.
- `src/Controller/` — business logic, generally organized by controller directory.
- `src/WebAPI/` — API endpoints, filters, utilities.
- `src/TRAQUERUtil/` — configuration, DB connections, encoding, translation,
  utilities.
- `custom/<site>/` — hospital/site-specific ETL and business rules.
- `conf/` — local configuration templates/examples. Treat real credentials as secrets.
- `test/` — shared tests and test prerequisites.
- `scripts/` — local setup/loading helpers.

## Architecture and coding patterns

### Def/imp split

Many modules use a definition/implementation split:

- `__def.jl`, `_def.jl`, or similar files declare empty generic
  functions/signatures.
- `__imp.jl`, `_imp.jl`, or feature files add methods.

When adding behavior, follow the existing pattern in the same module. Do not put large
implementations into def files unless that directory already does so.

### Controllers

CRUD and business logic live in `src/Controller/*Ctrl/`.

Use one source file per function. When adding a new function, create a dedicated file
named after the function and include it from the relevant `__imp.jl`, `_imp.jl`, or
module wiring file, following the local convention.

Prefer existing controller helpers and hooks over direct SQL when possible.

### Function naming

Use `buildSomething` for functions that instantiate/derive in-memory objects without
persisting them. Reserve `createSomething`, `createSomethingIfNotExist`, and similar
names for functions that persist objects or otherwise create database state.

### Database access

Use `TRAQUERUtil` connection helpers:

```julia
dbconn = TRAQUERUtil.openDBConn()
dbconn = TRAQUERUtil.openDBConnAndBeginTransaction()
```

For transactions, ensure commit/rollback/close paths are handled. Avoid leaking
`LibPQ.Connection`s.

### Encryption and privacy

This project handles healthcare data. Be conservative:
- Do not log patient-identifying data, decrypted values, tokens, passwords, or
  encryption keys.
- Use encrypted model variants and the existing BlindBake/encryption helpers.
- ETL functions that need encryption usually take or derive an `encryptionStr`; tests
  often use `getDefaultEncryptionStr()`.

### Custom site modules

Site-specific logic belongs in `custom/<site>/src/` and should mirror core patterns.
Custom modules may be selected by config/environment variables such as
`TRAQUER_CUSTOM_MODULE_*_FILE`; check `conf/*.conf` and the target site test
prerequisites before changing load behavior.

## Development commands

Run commands from the repository root (`/home/traquer/CODE/TRAQUER.jl`).

Start a Julia REPL with the project environment:

```bash
julia --project
```

If another tmux pane exists, prefer using that pane to run and keep the Julia session
alive rather than starting repeated one-shot Julia processes.

When a Julia session is started, the first script to execute is:

```julia
include("test/runtests-prerequisite.jl")
```

Run an individual test file:

```bash
julia --project test/TRAQUERUtil/test-createHospitalZonedDateTime.jl
```

Run a custom-site test file, for example:

```bash
julia --project custom/demo/test/runtests-demo-importStays.jl
```

Some tests require PostgreSQL, local config, custom modules, or input data. If a test
depends on local services or secrets, state that clearly rather than inventing
credentials.

### Test utilities

Unit tests can use helper functions from module `Main._TestUtils`, defined under
`test/_TestUtils/` and loaded by `test/runtests-prerequisite.jl`. Prefer these helpers
for common test setup/teardown such as creating dummy patients, units, or infectious
statuses, instead of duplicating setup logic in individual test files.

## Scheduler

Scheduler control is exposed from the top-level module:

```julia
TRAQUER.stopScheduler()
TRAQUER.startScheduler()
```

To disable scheduled functions for an environment, prefer config (`scheduler.blacklist`)
instead of deleting scheduled code.

## Style guidelines

- Ensure every modified or newly created text file ends with a final newline.
- Match existing Julia style and naming; many functions use camelCase.
- Keep changes localized and consistent with neighboring files.
- Prefer explicit module qualification where existing code does.
- Avoid broad rewrites of generated-looking ORM/model files unless the task requires it.
- Preserve public method signatures used by controllers, WebAPI, tests, and custom
  modules.
- Add or update targeted tests when changing business logic.

## Safety checklist before finishing

- Ensure new code is included from the relevant module file.
- Run the most specific applicable test(s), if local dependencies allow.
- Do not commit generated tmp/log files, local secrets, or patient data.
- Mention any tests not run and why.
