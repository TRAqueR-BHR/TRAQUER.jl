function TRAQUERUtil.generateHumanReadableUniqueRef(obj::Patient)

    _today = Dates.format(TRAQUERUtil.nowInTargetTimeZone(), "yyyymmdd")
    _seqNextVal = TRAQUERUtil.retrieveSequenceNextval("patient_traquer_ref_seq")
    parse(Int64,"$_today$_seqNextVal")
end

function TRAQUERUtil.retrieveSequenceNextval(postgreslSequenceName::String)

    # Get the next value of the sequence
    # NOTE: In case we have several postresql master servers, make sure that the
    #         sequences do not overlap. Eg. - If two master servers make the
    #         sequence create off numbers for one master and even numbers for
    #         the other
    queryStringNextVal = "SELECT nextval(\$1)"
    nextVal = TRAQUERUtil.openDBConnectionAndExecuteQuery(
        queryStringNextVal,[postgreslSequenceName])[1,1]
    return nextVal
end
