function ETLCtrl.FHIR.validateUnitsData(xmlDoc::EzXML.Document)
    locationEntries = EzXML.findall(
        "fhir:entry[fhir:resource/fhir:Location]",
        xmlDoc.root,
        ["fhir" => "http://hl7.org/fhir"]
    )
    return locationEntries
end
