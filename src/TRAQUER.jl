module TRAQUER

greet() = print("Lorembv")

module Enums
    include("Enums/enums.jl")
end  # module Enums

module TRAQUERUtils

    include("./utils/utils.jl")

end # module TRAQUERUtils



module Model
    export Patient, FctUnit, FctUnitStay
    using PostgresqlDAO,PostgresqlDAO.Model,TimeZones,..Enums.Gender
    include("Model/abstract-types.jl")
    include("Model/FctUnit.jl")
    include("Model/FctUnitStay.jl")
    include("Model/Patient.jl")




end  # module Model

module DAO

    module FctUnitDAO
        using ...Model,PostgresqlDAO,PostgresqlDAO.Model.Enums.CRUDType,..DAO
        include("DAO/FctUnitDAO.jl")
    end  # module

    module FctUnitStayDAO
        using ...Model,PostgresqlDAO,PostgresqlDAO.Model.Enums.CRUDType,..DAO
        include("DAO/FctUnitStayDAO.jl")
    end  # module

    module PatientDAO
        using ...Model,PostgresqlDAO,PostgresqlDAO.Model.Enums.CRUDType,..DAO
        include("DAO/PatientDAO.jl")
    end  # module




end  # module DAO


end # module
