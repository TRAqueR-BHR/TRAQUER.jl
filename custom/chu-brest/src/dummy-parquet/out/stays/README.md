# Description of 'stays' Parquet file

This file contains the description of the 'stays' Parquet file.
Several lines can refer to the same stay,
Eg. one line for when the patient arrives in the unit and one line for when he leaves.

## Column: patientFirstname
- Type: String
- Optional: No

## Column: patientLastname
- Type: String
- Optional: No

## Column: patientBirthdate
- Type: Date
- Optional: No

## Column: patientRef
- Type: String
- Optional: No

## Column: unitCodeName
- Type: String
- Optional: No

## Column: unitName
- Type: String
- Optional: No

## Column: inTime
- Type: DateTime
- Optional: No
- Note: In the timezone of the hospital

## Column: outTime
- Type: DateTime
- Optional: Yes
- Note: In the timezone of the hospital

## Column: hospitalizationInTime
- Type: DateTime
- Optional: No
- Note: In the timezone of the hospital

## Column: hospitalizationOutTime
- Type: DateTime
- Optional: Yes
- Note: In the timezone of the hospital

## Column: hospitalizationOutComment
- Type: String
- Optional: Yes

## Column: room
- Type: String
- Optional: Yes

## Column: sector
- Type: String
- Optional: Yes

## Column: patientDiedDuringStay
- Type: Bool
- Optional: Yes

