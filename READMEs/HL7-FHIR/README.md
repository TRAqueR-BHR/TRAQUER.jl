# README HL7 FHIR

Traquer expects data in the XML HL7 FHIR (https://hl7.org/fhir) (Fast Healthcare
Interoperability Resources) format.

## Overview
HL7 FHIR is a standard for exchanging healthcare information electronically. It defines a
set of "resources" that represent different types of healthcare data, such as patients,
observations, medications, and more.

We use this format to ensure interoperability and standardization in the communication
between the hospital and its Traquer instance.

As a reminder, the type of data that Traquer is interested in is:
  - Where is the patient (what unit, what sector, what room)?
  - What is the status of an analysis request (pending, in progress, completed)?
  - What is the result of an analysis (positive, negative, details of the bacteria found)?

The overal list of FHIR resources is available at (https://hl7.org/fhir/resourcelist.html)

### General note on the interpretation of FHIR and tolerance of Traquer to these variations

Hospitals and healthcare providers may implement FHIR resources differently based on
their specific workflows, systems, and requirements.

For example, some institutions give each movement of a patient to a new location its own
`Encounter` resource, while others use a single `Encounter` resource for the entire stay and
record location changes within that resource.

Traquer tries to accommodate these variations as much as possible.

## Supported FHIR Versions

Traquer supports **FHIR R5** specifications.

## Examples
[Example file](https://github.com/TRAqueR-BHR/TRAQUER.jl/blob/main/READMEs/HL7-FHIR/examples/scenario1-fhir-r5.xml)

## Coding/Terminology of medical and biological names
Traquer has its own coding system (see list of possible values in the sections below) but is
compatible with standard coding systems (eg. LOINC (https://loinc.org), SNOMED CT...). You
can find a list of coding systems on the HL7 website
(https://hl7.org/fhir/terminologies-systems.html). FHIR XSD does not implement any check on
codes, only the business logic in Traquer will do so.

## Validation tools
You can validate your FHIR XML files against the schemas using the following command:
```xmllint --schema READMEs/HL7-FHIR/xsd/r5/fhir-r5-single.xsd READMEs/HL7-FHIR/examples/scenario1-fhir-r5.xml --noout```


## Types of data

### Summary

Here are the main FHIR resources used to represent the different types of data used by
Traquer:
  - Units/Sectors/Rooms: `Location` (https://hl7.org/fhir/location.html)
  - Patient stay and movements: `Encounter` (https://hl7.org/fhir/encounter.html)
  - Analysis requests and samples: `ServiceRequest` (https://hl7.org/fhir/servicerequest.html) + `Specimen` (https://hl7.org/fhir/specimen.html)
  - Analysis results: `Observation` (https://hl7.org/fhir/observation.html)

### Patient stay and movements

A unit is represented as both an `Organization` and a `Location`.
As stated in (https://hl7.org/fhir/location.html#bnr):

> Locations and Organizations are very closely related resources and can often be
> mixed/matched/confused.
> The Location is intended to describe the more physical structures managed/operated by an
> organization, whereas the Organization is intended to represent the more conceptual
> hierarchies, such as a ward. Location may also be used to represent virtual locations, for
> example for telehealth visits.

Units/Sectors/Rooms are represented using the `Location` resouces.
Patient stay and movements are represented using the `Encounter` resource.

The location hierarchy follows this structure:
- **Unit** (required): The main service/department (e.g., ICU, REA1)
- **Sector** (optional): A subdivision within a unit (e.g., Sector 2)
- **Room** (optional): The specific room where the patient is located (e.g., Room 302)

#### Location Resource Structure

Each location level is represented as a separate `Location` resource with:
- `identifier`: A system-specific code for the location
- `name`: Human-readable name for the location
- `partOf`: Reference to the parent location (for hierarchical relationships)

**Example hierarchy:**
```
Unit: REA1 (Service de réanimation post-opératoire)
├── Sector: REA1-S2 (Secteur 2)
    └── Room: REA1-S2-302 (Chambre 302)
```

#### Encounter Resource

__Note about interpretation of the Encounter resource:__
Some institutions may choose to represent each patient movement as a separate `Encounter`
resource, while others may use a single `Encounter` resource for the entire stay, recording
location changes within that resource.

In the following example, we illustrate the latter approach with a single `Encounter`
resource.

The `Encounter` resource tracks the patient's stay and includes a `location` array that
records:
- Which specific location (room/sector/unit) the patient occupied
- The time period for each location
- Location changes during the stay

The most specific location available should be referenced (room if available, otherwise
sector, otherwise unit).

### Analysis requests
An analysis request is typically represented as a `ServiceRequest` and `Specimen` resource.
Where `Specimen` represents the biological sample taken from the patient for analysis (e.g.
stool) and `ServiceRequest` represents the order/request for that analysis (e.g. bacterial
culture).

In Traquer terminology, the following analysis types are supported:

  - molecular_analysis_carbapenemase_producing_enterobacteriaceae
  - bacterial_culture_carbapenemase_producing_enterobacteriaceae
  - molecular_analysis_vancomycin_resistant_enterococcus
  - bacterial_culture_vancomycin_resistant_enterococcus


### Analysis result
An analysis result is typically represented as an `Observation` resource.
