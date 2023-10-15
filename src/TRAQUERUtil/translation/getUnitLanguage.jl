function TRAQUERUtil.getUnitLanguage()
    languageCode = TRAQUERUtil.getConf("default","unit_language_code")
    language = Languages.from_code(languageCode)
    if isnothing(language)
        error("Unknown languages code[$languageCode],"
            * " supported codes are [$(join(Languages.list_languages(),", "))]")
    end
    return language
end
