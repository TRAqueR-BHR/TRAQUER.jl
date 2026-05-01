"""
    Check that the FHIR XML document does not declare the hospital itself as a Location
    resource that is referenced by any Encounter.location element.
    The reason is that the hospital should not be treated as a location in the same way as
    units or sectors because the integration logic assumes that the resources <Location>
    referenced in Encounter.location are units or sectors where the patient stayed, and not
    the hospital as a whole.
"""
function ETLCtrl.FHIR.checkHospitalIsNotDeclaredAsLocation(xmlDoc::EzXML.Document)
    # TODO
end
