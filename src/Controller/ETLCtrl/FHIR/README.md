# Module ETLCtrl.FHIR

This module is responsible for handling FHIR data within the ETL process. It includes functions to load and process FHIR XML files, as well as any other necessary operations related to FHIR data management.

## Validating FHIR XML files

Validation has several folds:

### DTD Validation
Check that the file passes validation against the FHIR XML schemas. This validation is
similar to what would be done with command-line tool `xmllint`.

### Business validation
Given the current state of the database, check that the file contains the necessary resources
and fields required by Traquer, and that the values.
