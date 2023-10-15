function TRAQUERUtil.getTranslation(translationId::String)
    TRAQUERUtil.getTranslation(
        translationId,
        Languages.isocode(TRAQUERUtil.getUnitLanguage()))

end

function TRAQUERUtil.getTranslation(translationId::Symbol)
    TRAQUERUtil.getTranslation(
        string(translationId),
        Languages.isocode(TRAQUERUtil.getUnitLanguage()))

end

function TRAQUERUtil.getTranslation(translationId::Bool)
    TRAQUERUtil.getTranslation(
        string(translationId),
        Languages.isocode(TRAQUERUtil.getUnitLanguage()))

end

function TRAQUERUtil.getTranslation(enum::Base.Enum)

    languageCode = Languages.isocode(TRAQUERUtil.getUnitLanguage())

    enumTypeName = enum |> typeof |> nameof |> string

    translationId = "$(enumTypeName)_$(string(enum))"

    # Try to find the translation with the prefix first
    if ConfParser.haskey(Medilegist.translation, languageCode, translationId)
        return TRAQUERUtil.getTranslation(translationId,languageCode)
    else
        translationId = string(enum)
        return TRAQUERUtil.getTranslation(
            translationId,
            languageCode)
    end

end

function TRAQUERUtil.getTranslation(enums::Vector{T} where T<:Base.Enum)

    getTranslation.(enums) |> n -> join(n , ", ")

end

function TRAQUERUtil.getTranslation(translationId::String,languageCode::String)

    if ConfParser.haskey(Medilegist.translation, languageCode, translationId)
        return ConfParser.retrieve(Medilegist.translation, languageCode, translationId)
    elseif ConfParser.haskey(
        Medilegist.translation, languageCode, StringCases.underscore(translationId)
    )
        return ConfParser.retrieve(Medilegist.translation, languageCode, underscore(translationId))
    else
        @warn "Missing translation for [$translationId] in [$languageCode]"
        return translationId
    end

end
