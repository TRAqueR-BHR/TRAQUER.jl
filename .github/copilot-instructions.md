# TRAQUER.jl AI Coding Guidelines

## Architecture Overview

TRAQUER.jl is a Julia-based healthcare infectious disease tracking system with a modular MVC architecture:

- **Models**: Entity definitions in `src/Model/` with encrypted variants (`*Crypt.jl`) for sensitive data
- **ORM**: Database layer modules in `src/ORM/` using PostgresORM with schema `supervision`
- **Controllers**: Business logic in `src/Controller/` following def/imp pattern (`_def.jl`/`_imp.jl`)
- **Custom modules**: Hospital-specific implementations in `custom/{hospital-code}/`

## Key Architectural Patterns

### Module Structure
All major components follow the def/imp pattern:
```julia
# _def.jl - Function signatures only
function persist! end
function retrieveOneEntity end

# _imp.jl - Implementation
function Controller.persist!(newObject::T; creator::Union{Missing, Appuser} = missing)
    # Implementation here
end
```

### CRUD Operations
Base CRUD operations are defined in `src/Controller/default-crud-{def,imp}.jl`:
- `persist!()` - Create with automatic transaction handling
- `update!()` - Update with pre/post hooks
- `retrieveOneEntity()` / `retrieveEntities()` - Query with optional vector props
- `enrichWithVectorProps!()` - Load related collections

### Data Encryption
Sensitive patient data uses BlindBake encryption:
- `PatientNameCrypt`, `PatientBirthdateCrypt`, `PatientRefCrypt` for encrypted storage
- `PatientDecrypt` for decrypted access (protected module)
- Always use `encryptionStr` parameter in ETL functions

### Custom Hospital Modules
Environment variable `TRAQUER_CUSTOM_MODULE_*_FILE` determines custom module loading:
```julia
module Custom
    include(ENV["TRAQUER_CUSTOM_MODULE_DEFINITION_FILE"])
end
```

## Development Workflows

### Testing
- Prerequisites: Include `scripts/prerequisite.jl` for distributed setup
- Test pattern: `include("_prerequisite.jl")` then `@testset`
- Use `getDefaultEncryptionStr()` for test encryption
- Test files follow `test-{functionality}.jl` naming

### Database Operations
Always use connection helpers from `TRAQUERUtil`:
```julia
dbconn = TRAQUERUtil.openDBConn()
# or for transactions:
dbconn = TRAQUERUtil.openDBConnAndBeginTransaction()
```

### Scheduler System
- Timer-based scheduler runs every 45s checking `ScheduledTaskExecution`
- Functions scheduled using time constants: `every1Minutes`, `every5Minutes`, etc.
- Control with `TRAQUER.startScheduler()` / `TRAQUER.stopScheduler()`
- Use `scheduler.blacklist` in config to disable functions per environment

### ETL Processing
ETL operations in `ETLCtrl` follow pattern:
1. `importAnalyses()` / `importStays()` - Data ingestion from CSV/Parquet
2. `integrateAndProcessNewStaysAndAnalyses()` - Processing pipeline
3. `processNewlyIntegratedData()` - Business rule application

## Configuration
- Main config: `conf/traquer.conf` with sections `[default]`, `[custom]`, `[database]`
- Access via `TRAQUERUtil.getConf(section, key)`
- Environment-specific custom module paths in config
- JWT keys referenced by URI in `[security]` section

## Web API
- Route definitions in `scripts/web/api-def/*.jl`
- JWT authentication except for paths in `apis_paths_wo_jwt`
- CORS handling with dynamic headers including custom encryption headers
- WebSocket support defined in `web-socket-definition.jl`

## Critical Domain Concepts
- `InfectiousStatus` drives `EventRequiringAttention` generation
- Outbreaks link to infectious statuses via `OutbreakInfectiousStatusAsso`
- Patient risk calculation: `StayCtrl.getStaysWherePatientAtRisk()`
- Carrier exclusion requires configurable negative test counts

## File Naming Conventions
- Controllers: `{Entity}Ctrl/_def.jl` and `{Entity}Ctrl/_imp.jl`
- Models: `{Entity}.jl`, encrypted variants as `{Entity}Crypt.jl`
- Tests: `test-{functionality}.jl` with `_prerequisite.jl` inclusion
- Custom implementations: `custom/{hospital}/src/` following same def/imp pattern
