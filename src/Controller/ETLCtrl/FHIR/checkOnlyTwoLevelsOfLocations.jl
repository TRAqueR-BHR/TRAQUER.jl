"""
    Check that the FHIR XML document contains at most two levels of Location resources
    (e.g., unit and sector) and that the Encounter.location references are consistent with
    this structure.
"""
function ETLCtrl.FHIR.checkOnlyTwoLevelsOfLocations(xmlDoc::EzXML.Document)
    # TODO
end
