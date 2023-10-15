function TRAQUERUtil.loadTranslation()::ConfParse
    translationFilepath = "translation/translation.conf"
    @info "loading translation file[$translationFilepath]"
    translations = ConfParse(translationFilepath)
    parse_conf!(translations)
    return(translations)
end
