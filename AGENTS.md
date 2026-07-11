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
- `src/__module-extensions/<PkgName>/` — code that adds methods to external
  Julia modules (Base, AWS, ConfParser, ...). See "External module extensions"
  below.
- `custom/<site>/` — hospital/site-specific ETL and business rules.
- `conf/` — local configuration templates/examples. Treat real credentials as secrets.
- `test/` — shared tests and test prerequisites.
- `scripts/` — local setup/loading helpers.

## Architecture and coding patterns

### Def/imp split

Many modules use a definition/implementation split:

- `__def.jl`, `_def.jl`, or similar files declare empty generic
  functions/signatures. **Keep `__def.jl` signatures-only.** Struct definitions
  belong in their own file under the controller directory (e.g.
  `Controller/<Ctrl>/_SomeStruct.jl`) or under `src/__module-extensions/` when
  the struct is part of an external-module extension — not in `__def.jl`.
- `__imp.jl`, `_imp.jl`, or feature files add methods.

When adding behavior, follow the existing pattern in the same module. Do not put large
implementations into def files unless that directory already does so.

Submodule wiring: in `src/TRAQUER.jl`, each controller's `__def.jl` is included
from inside its `module ... end` block, while `__imp.jl` is included at the
top level after `using-for-imp.jl` has bound the submodule into scope. This is
why impl files write `S3Ctrl.download(...)` (qualified by the bound submodule
name) but files inside the `__def.jl` block see names from inside that module.

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

### External module extensions

Code that adds methods to an external Julia module (e.g. extending `AWS.foo` for a
custom config type, replacing `ConfParser.parse_line`, or adding a `Base.push!`
overload for an ORM entity) lives in `src/__module-extensions/<PkgName>/`. Each
subdirectory has:

- A `__include.jl` aggregator that pulls in the per-concept files in dependency
  order. **Make it self-sufficient**: declare any required `import`/`using` at
  the top of `__include.jl` rather than relying on side effects from elsewhere.
  This protects against future load-order changes silently breaking the
  extension.
- One file per concept. Tightly-coupled concepts (e.g. a small struct plus its
  one or two method extensions) can live together in one file — e.g.
  `AWS/TRAQUERS3Config.jl` defines the struct, and `AWS/credentials.jl`,
  `AWS/region.jl`, etc. define each interface method separately.

This replaces the older `src/package-overwrite/` layout. Prefer
`__module-extensions/` for any new external-module extension.

Include `__module-extensions/` from `src/TRAQUER.jl` *after* `using-for-imp.jl`
and *before* any controller implementation that references the types/methods
defined there. Without this ordering, downstream code will see undefined names.

#### Cross-namespace struct definitions

Structures that are conceptually part of an external module (e.g. an
`AWS.AbstractAWSConfig` subtype) must live in a module's namespace. Julia does
not allow `struct Parent.Child.Name ... end` from a different scope — the
qualified-name syntax is only valid when written inside an explicit
`module ... end` block. Two practical patterns:

- **Define inside the submodule** (e.g. `module S3Ctrl ... include("...TRAQUERS3Config.jl") ... end`)
  if the type is meaningful only to one controller. Other code accesses it as
  `Controller.S3Ctrl.TRAQUERS3Config`.
- **Define at TRAQUER top level** (the current convention for `TRAQUERS3Config`)
  if the type is shared across controllers. Other code accesses it as
  `TRAQUER.<Type>` from inside a submodule, or as bare `<Type>` from anywhere
  `using-for-imp.jl` has placed TRAQUER in scope.

Pick the simpler option: prefer keeping the struct where most of its methods
live, so most references stay unqualified.

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
- Add new external-package `using`/`import` calls to `src/using-for-imp.jl` rather
  than scattering them through individual impl files. The one exception is inside
  a `__module-extensions/<Pkg>/__include.jl` aggregator, where each extension
  directory should declare its own dependencies to stay self-sufficient.
- Avoid broad rewrites of generated-looking ORM/model files unless the task requires it.
- Preserve public method signatures used by controllers, WebAPI, tests, and custom
  modules.
- Add or update targeted tests when changing business logic.

## Safety checklist before finishing

- Ensure new code is included from the relevant module file.
- Run the most specific applicable test(s), if local dependencies allow.
- Do not commit generated tmp/log files, local secrets, or patient data.
- Mention any tests not run and why.
