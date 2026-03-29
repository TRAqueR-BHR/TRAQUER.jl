function ETLCtrl.FHIR.checkReferenceIsDeclared(fhirRef::String, xmlDoc::EzXML.Document)
    # fhirRef is expected in the form "ResourceType/id" e.g. "Location/loc-CARDIO"
    parts = split(fhirRef, "/")
    resourceType = parts[end-1]
    resourceId = parts[end]
    matches = EzXML.findall(
        "fhir:entry[fhir:resource/fhir:$resourceType[fhir:id/@value='$resourceId']]",
        xmlDoc.root,
        ["fhir" => "http://hl7.org/fhir"]
    )
    return !isempty(matches)
end
