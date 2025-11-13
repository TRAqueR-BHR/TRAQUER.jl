# FHIR R4 to R5 Migration Summary

This document summarizes the changes made when migrating `scenario1.xml` from FHIR R4 to FHIR R5.

## Key Changes

### 1. Encounter Resource

#### Encounter.status
- **R4**: `finished`
- **R5**: `completed`
- **Change**: The status value "finished" was renamed to "completed" in R5.

#### Encounter.class
- **R4**: Type `Coding`, required (minOccurs="1" maxOccurs="1")
- **R5**: Type `CodeableConcept`, optional and repeatable (minOccurs="0" maxOccurs="unbounded")
- **Change**: Wrapped the Coding element inside a CodeableConcept structure to support multiple codings and text.

**R4 Structure:**
```xml
<class>
  <system value="http://terminology.hl7.org/CodeSystem/v3-ActCode"/>
  <code value="IMP"/>
</class>
```

**R5 Structure:**
```xml
<class>
  <coding>
    <system value="http://terminology.hl7.org/CodeSystem/v3-ActCode"/>
    <code value="IMP"/>
  </coding>
</class>
```

#### Encounter.period
- **R4**: `period`
- **R5**: `actualPeriod`
- **Change**: The element was renamed to better distinguish between planned and actual encounter periods.

### 2. ServiceRequest Resource

#### ServiceRequest.code
- **R4**: Type `CodeableConcept`
- **R5**: Type `CodeableReference`
- **Change**: The code element now uses CodeableReference, which can contain either a concept (CodeableConcept) or a reference to a resource.

**R4 Structure:**
```xml
<code>
  <coding>
    <system value="http://loinc.org"/>
    <code value="XXXXX-X"/>
    <display value="CPE screening, stool/rectal swab"/>
  </coding>
  <text value="bacterial_culture_carbapenemase_producing_enterobacteriaceae"/>
</code>
```

**R5 Structure:**
```xml
<code>
  <concept>
    <coding>
      <system value="http://loinc.org"/>
      <code value="XXXXX-X"/>
      <display value="CPE screening, stool/rectal swab"/>
    </coding>
    <text value="bacterial_culture_carbapenemase_producing_enterobacteriaceae"/>
  </concept>
</code>
```

## No Changes Required

The following resources remained compatible between R4 and R5 for this scenario:
- Organization
- Location (all three: unit, sector, room)
- Patient
- Specimen
- Observation
- DiagnosticReport

## Validation

Both files have been validated against their respective schemas:
- **R4**: Validates against `fhir-r4-single.xsd`
- **R5**: Validates against `fhir-r5-single.xsd`

## Files

- Original R4: `scenario1.xml`
- Migrated R5: `scenario1-r5.xml`
