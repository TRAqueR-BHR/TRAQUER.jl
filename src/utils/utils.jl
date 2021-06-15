using PostgresqlDAO
using LibPQ
using TimeZones
using Dates


function opendbconn()
   database = "traquer"
   user = "traquer"
   host = "127.0.0.1"
   port = "5432"
   password = "Root95"

   conn = LibPQ.Connection("host=$(host)
                            port=$(port)
                            dbname=$(database)
                            user=$(user)
                            password=$(password)
                            "; throw_error=true)
    return conn
end

function closedbconn(conn::LibPQ.Connection)
   close(conn)

end

function convertStringToZonedDateTime(dateStr::String,
                                    timeStr::String,
                                    _tz::VariableTimeZone)



               dateDate = Date(dateStr,DateFormat("d/m/y"))


               timeTime = begin

                  timeTemp = missing

                  if length(timeStr) == 1
                     timeTemp = Time(timeStr, DateFormat("M"))
                  end

                  if length(timeStr) == 2
                     timeTemp = Time(timeStr, DateFormat("MM"))
                  end


                  if length(timeStr) == 3
                     timeTemp = Time(timeStr, DateFormat("HMM"))
                  end

                  if length(timeStr) == 4
                     timeTemp = Time(timeStr, DateFormat("HHMM"))
                  end
                  if length(timeStr) == 5
                     timeTemp = Time(timeStr, DateFormat("HH:MM"))
                  end
                  timeTemp

               end



               dateTimes = DateTime(dateDate,timeTime)


               inDateTest =  TimeZones.first_valid(dateTimes,_tz)

               @info typeof(inDateTest)
               return  inDateTest
end
