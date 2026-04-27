function ETLCtrl.FHIR.checkReferenceIsDeclared(fhirRef::String, xmlDoc::EzXML.Document)
    ns = ["fhir" => "http://hl7.org/fhir"]

    if startswith(fhirRef, "urn:uuid:")
        # Match against the entry fullUrl
        matches = EzXML.findall(
            "fhir:entry[fhir:fullUrl/@value='$fhirRef']",
            xmlDoc.root,
            ns
        )
    else
        error("Only references in 'urn:uuid:id' format are supported for now. Got: $fhirRef")
    end

    return !isempty(matches)
end
