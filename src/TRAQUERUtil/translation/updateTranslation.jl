"""

    updateTranslation()::Bool

Update Medilegist.translation singleton

"""
function TRAQUERUtil.updateTranslation()::Bool

    # NOTE: It would be easier to do `parse_conf!(Medilegist.translation)` but this errors
    #        with SystemError: seek: Illegal seek
    translations = TRAQUERUtil.loadTranslation()
    ConfParser.merge!(Medilegist.translation,translations)

end
