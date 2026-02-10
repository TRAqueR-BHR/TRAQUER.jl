# File gateway

## Get a file exchange passphrase

The hospital client needs to get the latest file exchange passphrase from Traquer in order
to encrypt files before uploading them to S3.
A file exchange passphrase can be used multiple times until it is rotated by Traquer. Using
an old passphrase will work but will be logged for security auditing purposes and trigger
an alert to the referers and admins of the hospital and of Traquer.

```mermaid
sequenceDiagram
title File exchange passphrase flow

%% Participants
participant HC as Hospital file exchange client
actor HU as Hospital hygiene service staff user (Traquer GUI)
participant TS as Traquer server side
participant TDB as Traquer database

%% Messages
HC->>TS: Request file exchange passphrase
activate TS

TS->>HU: Request query of latest exchange passphrase
activate HU
HU->>TS: Query latest exchange passphrase
deactivate HU

TS->>TDB: Query latest exchange passphrase
activate TDB
TDB->>TS: Return latest exchange passphrase
deactivate TDB

TS->>HC: Return latest exchange passphrase
deactivate TS
```

## Submit a file to Traquer via S3 flow
This diagram illustrates the flow of submitting a file to Traquer via S3 storage service.

```mermaid
sequenceDiagram
title Submit a file to Traquer via S3 flow

%% Participants
participant HC as Hospital file exchange client
participant S3 as S3 file storage service
participant TS as Traquer server side
participant RMQ as Traquer RabbitMQ message broker

%% Messages
rect rgb(240,248,255)
note over HC,RMQ: Upload phase
HC->>TS: Request pre-signed upload URL
activate HC
activate TS
TS->>HC: Return pre-signed upload URL
deactivate TS

HC->>S3: Upload encrypted file to S3

HC->>TS: Notify new file uploaded (object key, size, ETag/checksum)
deactivate HC
activate TS
TS->>S3: Verify object exists and metadata matches (HEAD)
activate S3
S3->>TS: Return metadata (status, size, ETag)
deactivate S3
TS->>RMQ: Publish new file uploaded message
deactivate TS
end

rect rgb(240,255,240)
note over S3,RMQ: Processing phase
TS->>RMQ: Consume new file uploaded message
activate TS
activate RMQ
RMQ->>TS: Deliver new file uploaded message
deactivate RMQ
TS->>S3: Request uploaded file
activate S3
S3->>TS: Return uploaded file
deactivate S3
TS->>TS: Process uploaded file (decrypt, analyze, store results)
deactivate TS
end

rect rgb(255,248,240)
note over HC,TS: Status check phase
HC->>TS: Check file processing status
activate TS
TS->>HC: Return file processing status
deactivate TS
end

```

## Check existence of a pending special extraction
This diagram illustrates the flow of checking if an extraction with a specific perimeter of
units and time window is needed. Those special extractions are needed when Traquer is
missing data to compute the outbreak.

```mermaid
sequenceDiagram
title Check pending special extractions
%% Participants
participant HC as Hospital file exchange client
participant TS as Traquer server side
%% Messages
HC->>TS: Request pending special extraction for units and time window
activate HC
activate TS
TS->>TS: Check if a special extraction is pending
TS->>HC: Return parameters for the expected extraction: List[Patient], List[Unit], TimeWindow
deactivate TS
deactivate HC
```
