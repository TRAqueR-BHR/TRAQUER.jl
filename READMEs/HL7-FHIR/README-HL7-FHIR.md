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

Traquer supports **FHIR R5** specifications. Example files are provided
for this version:
- `examples/scenario1-fhir-r5.xml` - FHIR R5 example

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

__Note about interpretation of the Encounter resource:__ Some institutions may choose to
represent each patient movement as a separate `Encounter` resource, while others may use a
single `Encounter` resource for the entire stay, recording location changes within that
resource.

In the following example, we illustrate the latter approach with a single `Encounter` resource


The `Encounter` resource tracks the patient's stay and includes a `location` array that
records:
- Which specific location (room/sector/unit) the patient occupied
- The time period for each location
- Location changes during the stay

The most specific location available should be referenced (room if available, otherwise
sector, otherwise unit).

#### XML Example (FHIR R5)


```xml
<Bundle xmlns="http://hl7.org/fhir">

  [...]

  <!-- Unit Location: Cardiac Surgery -->
  <entry>
    <resource>
      <Location>
        <id value="loc-chir-card"/>
        <identifier>
          <system value="urn:unit-code"/>
          <value value="CHIR-CARD"/>
        </identifier>
        <name value="Service de chirurgie cardiaque"/>
        [...]
      </Location>
    </resource>
  </entry>

  <!-- Unit Location: ICU REA1 -->
  <entry>
    <resource>
      <Location>
        <id value="loc-rea1"/>
        <identifier>
          <system value="urn:unit-code"/>
          <value value="REA1"/>
        </identifier>
        <name value="Service de réanimation post-opératoire"/>
        [...]
      </Location>
    </resource>
  </entry>

  <!-- Sector Location (optional) -->
  <entry>
    <resource>
      <Location>
        <id value="loc-rea1-sector2"/>
        <identifier>
          <system value="urn:sector-code"/>
          <value value="REA1-S2"/>
        </identifier>
        <name value="Secteur 2"/>
        <partOf>
          <reference value="urn:uuid:loc-rea1"/>
        </partOf>
        [...]
      </Location>
    </resource>
  </entry>

  <!-- Room Location (optional) -->
  <entry>
    <resource>
      <Location>
        <id value="loc-room302"/>
        <identifier>
          <system value="urn:room-code"/>
          <value value="REA1-S2-302"/>
        </identifier>
        <name value="Chambre 302"/>
        <partOf>
          <reference value="urn:uuid:loc-rea1-sector2"/>
        </partOf>
        [...]
      </Location>
    </resource>
  </entry>

  <!-- Patient -->
  <entry>
    <resource>
      <Patient>
        <id value="pat-p123456"/>
        <identifier>
          <system value="urn:patient-ref"/>
          <value value="P123456"/>
        </identifier>
        [...]
      </Patient>
    </resource>
  </entry>

  <!-- Encounter with location history (multiple movements) -->
  <entry>
    <resource>
      <Encounter>
        <id value="enc-1"/>
        <!-- Patient is still in hospital, so status is in-progress -->
        <status value="in-progress"/>
        <subject>
          <reference value="urn:uuid:pat-p123456"/>
        </subject>
        <!-- Overall hospitalization period -->
        <actualPeriod>
          <start value="2024-09-01T17:00:00+02:00"/>
          <!-- end omitted because patient is still in hospital -->
        </actualPeriod>
        <!-- First location: Cardiac Surgery -->
        <location>
          <location>
            <reference value="urn:uuid:loc-chir-card"/>
            <display value="Service de chirurgie cardiaque"/>  <!-- optional reminder -->
          </location>
          <period>
            <start value="2024-09-01T17:00:00+02:00"/>
            <end value="2024-10-01T08:00:00+02:00"/>
          </period>
        </location>
        <!-- Second location: ICU REA1, Room 302 -->
        <location>
          <location>
            <reference value="urn:uuid:loc-room302"/>
            <display value="Chambre 302, Secteur 2, REA1"/> <!-- optional reminder -->
          </location>
          <period>
            <start value="2024-10-01T08:00:00+02:00"/>
            <end value="2024-10-03T08:00:00+02:00"/>
          </period>
        </location>
        [...]
      </Encounter>
    </resource>
  </entry>

  [...]
</Bundle>
```

### Analysis requests
An analysis request is typically represented as a `ServiceRequest` and `Specimen` resource.
Where `Specimen` represents the biological sample taken from the patient for analysis (e.g.
stool) and `ServiceRequest` represents the order/request for that analysis (e.g. bacterial
culture).

```
<entry>
    <fullUrl value="urn:uuid:sr-a123456"/>
    <resource>
      <ServiceRequest>
        <id value="sr-a123456"/>
        <identifier>
          <system value="urn:analysis-ref"/>
          <value value="A123456"/>
        </identifier>
        <status value="completed"/>
        <intent value="order"/>
        <!-- R5 CHANGE: code is now CodeableReference with concept wrapper -->
        <code>
          <concept>
            <coding>
              <system value="https://traquer.org"/>
              <code value="101552-8"/>
              <display value="Carbapenem resistant Enterobacteriaceae [Presence] in Stool by Organism specific culture"/>
            </coding>
            <text value="bacterial_culture_carbapenemase_producing_enterobacteriaceae"/>
          </concept>
        </code>
        <subject>
          <reference value="urn:uuid:pat-p123456"/>
        </subject>
        <encounter>
          <reference value="urn:uuid:enc-1"/>
        </encounter>
        <authoredOn value="2024-10-01T23:00:00+02:00"/>
        <specimen>
          <reference value="urn:uuid:spec-a123456"/>
        </specimen>
      </ServiceRequest>
    </resource>
    <request>
      <method value="POST"/>
      <url value="ServiceRequest"/>
    </request>
  </entry>
```

### Analysis result
An analysis result is typically represented as an `Observation` resource.

### Complete Examples

Full working examples are available in the `examples/` directory:
- **`scenario1.xml`** - Complete FHIR R4 example with patient location, analysis request, and results
- **`scenario1-r5.xml`** - Complete FHIR R5 example (migrated from R4)

Both files have been validated against their respective FHIR schemas (`xsd/r4/` and `xsd/r5/`).

For migration guidance between versions, see [`MIGRATION-R4-TO-R5.md`](MIGRATION-R4-TO-R5.md).
