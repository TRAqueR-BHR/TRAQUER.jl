function ETLCtrl.FHIR.checkAllReferencesAreDeclared(xmlDoc::EzXML.Document)::Vector{String}
    ns = ["fhir" => "http://hl7.org/fhir"]

    # Collect all unique ResourceType/id references across the document
    refNodes = EzXML.findall("//fhir:reference/@value", xmlDoc.root, ns)
    allRefs = unique(node.content for node in refNodes)

    # Return only those that are NOT declared in the bundle
    filter(ref -> !ETLCtrl.FHIR.checkReferenceIsDeclared(ref, xmlDoc), allRefs)
end
