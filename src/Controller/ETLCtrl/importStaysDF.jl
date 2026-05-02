"""
    importStaysDF(
        df::DataFrame,
        encryptionStr::AbstractString
        ;ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
    )

Import stays from a DataFrame.

The DataFrame is expected to have the right columns with the right types (enums must be
enums and dates must be Date or ZonedDateTime).

The DataFrame must have the following columns and types:
  - patient_ref::String
  - firstname::String
  - lastname::String
  - birthdate::Date
  - hospitalization_in_time::ZonedDateTime
  - hospitalization_out_time::Union{Missing,ZonedDateTime}
  - unit_code_name::String
  - unit_name::String
  - sector::Union{Missing,String}
  - room::Union{Missing,String}
  - unit_in_time::ZonedDateTime
  - unit_out_time::Union{Missing,ZonedDateTime}
"""
function ETLCtrl.importStaysDF(
    df::DataFrame,
    encryptionStr::AbstractString
    ;ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
)

    @info (
          "\n# ################################## #"
        * "\n# Starting the integration of stays #"
        * "\n# ################################## #"
        )

    # Input file can be empty
    if isempty(df)
        return DataFrame()
    end

    # Group by patient_ref and process each patient's stays in parallel
    grouped = DataFrames.groupby(df, :patient_ref)

    dfOfRowsInError = @showprogress pmap(1:length(grouped)) do i
        ETLCtrl.importStaysDF(
            grouped[i],
            encryptionStr;
            ignoreEventsAfter = ignoreEventsAfter
        )
    end |>
    n -> vcat(n...)

    return dfOfRowsInError

end

"""
    importStaysDF(
        subdf::SubDataFrame,
        encryptionStr::AbstractString,
        dbconn
        ;ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
    )

Import stays from a SubDataFrame for a single patient.

This method processes stays grouped by patient_ref and is called by the main
importStaysDF(DataFrame, ...) method.
"""
function ETLCtrl.importStaysDF(
    subdf::SubDataFrame,
    encryptionStr::AbstractString
    ;ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
)

    TRAQUERUtil.createDBConnAndExecute() do dbconn

        # Create an empty DataFrame for storing problems
        dfOfRowsInError = DataFrame(
            lineNumInSrcFile = Vector{Int}(),
            error = Vector{String}()
        )

        _tz = TRAQUERUtil.getTimeZone()

        lineNumInSrcFile = 0

        for r in eachrow(subdf)

            try

                # Keep track of the line number in the src file if available
                lineNumInSrcFile = hasproperty(r, :lineNumInSrcFile) ? r.lineNumInSrcFile : lineNumInSrcFile + 1

                unitCodeName = string(r.unit_code_name)
                unitName = r.unit_name
                ref = string(r.patient_ref)
                firstname = string(r.firstname)
                lastname = string(r.lastname)
                birthdate::Date = r.birthdate
                inTime =  r.unit_in_time
                outTime = r.unit_out_time
                hospitalizationInTime =  r.hospitalization_in_time
                hospitalizationOutTime =  r.hospitalization_out_time

                # We may want to simulate that we are at a given point in time, in which case
                # some information need to be ignored
                if !ismissing(ignoreEventsAfter)
                    if inTime > ignoreEventsAfter
                        continue
                    end
                    if inTime <= ignoreEventsAfter && !ismissing(outTime) && outTime > ignoreEventsAfter
                        outTime = missing
                    end
                    if !ismissing(hospitalizationOutTime) && hospitalizationOutTime > ignoreEventsAfter
                        hospitalizationOutTime = missing
                    end
                end

                room = passmissing(string)(r.room)

                # Get a unit
                unit = UnitCtrl.createUnitIfNotExists(unitCodeName,unitName,dbconn)

                # Get a patient
                patient = PatientCtrl.createPatientIfNoExist(
                    firstname,
                    lastname,
                    birthdate,
                    ref,
                    encryptionStr,
                    dbconn
                )

                if ismissing(patient)
                    error("Unable to find patient for firstname[$firstname]"
                    * " lastname[$lastname] birthdate[$birthdateAsStr]."
                    * " Maybe a file of checks has not been integrated.")
                end

                # Retrieve the stay
                stay = Stay(
                    patient = patient,
                    unit = unit,
                    inTime = inTime,
                    outTime = outTime,
                    hospitalizationInTime = hospitalizationInTime,
                    hospitalizationOutTime = hospitalizationOutTime,
                    room = room
                )
                StayCtrl.upsert!(stay, dbconn)

            catch e
                errorDescription = TRAQUERUtil.formatExceptionAndStackTraceCore(
                    e, stacktrace(catch_backtrace())
                )

                push!(
                    dfOfRowsInError,
                    (
                        lineNumInSrcFile = lineNumInSrcFile,
                        error = errorDescription
                    )
                )
            end

        end # `for r in eachrow(subdf)`

        return dfOfRowsInError

    end # ENDOF createDBConnAndExecute do function

end
