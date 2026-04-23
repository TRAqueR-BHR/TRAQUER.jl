"""
    ETLCtrl.FHIR.validateAgainstSchema(xmlFilePath, xsdFilePath) -> Tuple{Bool, Vector{Model.FhirXmlError}}

Validate an XML file against an XSD schema using `xmllint`. Returns a tuple `(isValid, errors)`
where `isValid` is `true` if the file conforms to the schema, and `errors` is a vector of
[`Model.FhirXmlError`](@ref) structs, one per error line emitted by `xmllint`.

Each error line produced by `xmllint` has the form:

    {fileName}:{lineNumber}: {errorMessage}

For example:

    test/Controller/ETLCtrl/FHIR/assets/invalid.xml:1711: element start: Schemas validity error \
: Element '{http://hl7.org/fhir}start', attribute 'value': [facet 'pattern'] The value \
'2023-10-06T00:00:00' is not accepted by the pattern \
'([0-9]([0-9]([0-9][1-9]|[1-9]0)|[1-9]00)|[1-9]000)(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])\
(T([01][0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)(\\.[0-9]+)?(Z|(\\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00)))?)?)?'.

This would produce a `FhirXmlError` with:
- `fileName = "test/Controller/ETLCtrl/FHIR/assets/invalid.xml"`
- `lineNumber = 1711`
- `errorMessage = "element start: Schemas validity error : Element ..."`

Note: the final summary line emitted by `xmllint` (e.g. `"file.xml fails to validate"`) is
always dropped and does not appear in `errors`.

Throws an `ErrorException` if `xmllint` is not installed.
"""
function ETLCtrl.FHIR.validateAgainstSchema(
    xmlFilePath::String,
    xsdFilePath::String
)::Tuple{Bool, Vector{Model.FhirXmlError}}

    cmd = `xmllint --noout --schema $xsdFilePath $xmlFilePath`
    stderrBuffer = IOBuffer()

    process = try
        run(pipeline(ignorestatus(cmd); stdout = devnull, stderr = stderrBuffer))
    catch e
        if isa(e, Base.IOError)
            throw(ErrorException("xmllint command not found. Please install libxml2-utils/xmllint."))
        end
        rethrow(e)
    end

    validationOutput = String(take!(stderrBuffer))

    rawLines = filter(
        !isempty,
        split(validationOutput, '\n')
    )

    # Always drop the last line that tells whether the file is valid or not
    if !isempty(rawLines)
        pop!(rawLines)
    end

    # xmllint lines follow the format: "{fileName}:{lineNumber}: {errorMessage}"
    linePattern = r"^(.+):([0-9]+): (.+)$"

    errors::Vector{Model.FhirXmlError} = map(rawLines) do line
        m = match(linePattern, line)
        if m !== nothing
            Model.FhirXmlError(
                fileName     = String(m[1]),
                lineNumber   = Int32(parse(Int, m[2])),
                errorMessage = String(m[3]),
            )
        else
            Model.FhirXmlError(errorMessage = line)
        end
    end

    if success(process)
        return (true, errors)
    else
        return (false, errors)
    end
end
