"""

    updateTranslation()::Bool

Update TRAQUER.translation singleton

"""
function TRAQUERUtil.updateTranslation()::Bool

    # NOTE: It would be easier to do `parse_conf!(TRAQUER.translation)` but this errors
    #        with SystemError: seek: Illegal seek
    translations = TRAQUERUtil.loadTranslation()
    ConfParser.merge!(TRAQUER.translation,translations)

end
