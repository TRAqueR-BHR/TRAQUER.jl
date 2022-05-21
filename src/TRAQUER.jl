module TRAQUER

"""
  greet()

A function that says hello
"""
function greet()
  @info "Hello"
end

function greet(str::String)
  @info "Hello $str"
end


module Enum
    include("Enum/enums.jl")
end  # module Enum

module TRAQUERUtil
    export openDBConn,openDBConnAndBeginTransaction,beginDBTransaction,
           commitDBTransaction,rollbackDBTransaction,closeDBConn,
           getConf, formatExceptionAndStackTrace, json2Entity
    include("./TRAQUERUtil/util-def.jl")

end # module TRAQUERUtil

module Model
    export Patient, Unit, Stay, Analysis, PatientBirthdateCrypt,
           PatientNameCrypt, AnalysisType, PatientRefCrypt, AnalysisRefCrypt,
           InfectiousStatus,InfectionType, Appuser, Role, AppuserRoleAsso,
           RoleRoleAsso, Outbreak, OutbreakInfectiousStatusAsso
    using PostgresORM,TimeZones,..Enum.Gender, ..Enum.CarrierContact,
          ..Enum.AppuserType, ..Enum.RoleCodeName, ..Enum.InfectiousStatusType,
          ..Enum.HospitalizationStatusType, ..Enum.InfectiousAgentCodeName
    include("Model/abstract-types.jl")
    include("Model/Unit.jl")
    include("Model/Stay.jl")
    include("Model/Analysis.jl")
    include("Model/AnalysisRefCrypt.jl")
    include("Model/AnalysisType.jl")
    include("Model/PatientBirthdateCrypt.jl")
    include("Model/PatientNameCrypt.jl")
    include("Model/PatientRefCrypt.jl")
    include("Model/Patient.jl")
    include("Model/InfectiousStatus.jl")
    include("Model/InfectionType.jl")
    include("Model/Patient.jl")
    include("Model/InfectiousStatus.jl")
    include("Model/InfectionType.jl")
    include("Model/ContactExposure.jl")
    include("Model-protected/Appuser.jl")
    include("Model/Role.jl")
    include("Model/AppuserRoleAsso.jl")
    include("Model/RoleRoleAsso.jl")
    include("Model/Outbreak.jl")
    include("Model/PatientCurrentStatus.jl")
    include("Model/OutbreakInfectiousStatusAsso.jl")
end  # module Model

module ORM

  module UnitORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/UnitORM.jl")
  end
  module StayORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/StayORM.jl")
  end
  module AnalysisORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/AnalysisORM.jl")
  end
  module AnalysisRefCryptORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/AnalysisRefCryptORM.jl")
  end
  module AnalysisTypeORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/AnalysisTypeORM.jl")
  end
  module PatientBirthdateCryptORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/PatientBirthdateCryptORM.jl")
  end
  module PatientNameCryptORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/PatientNameCryptORM.jl")
  end
  module PatientRefCryptORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/PatientRefCryptORM.jl")
  end
  module PatientORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/PatientORM.jl")
  end
  module PatientCurrentStatusORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/PatientCurrentStatusORM.jl")
  end
  module InfectiousStatusORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/InfectiousStatusORM.jl")
  end
  module InfectionTypeORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/InfectionTypeORM.jl")
  end
  module ContactExposureORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/ContactExposureORM.jl")
  end
  module AppuserORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/AppuserORM.jl")
    include("./ORM-tracking/AppuserORM-tracking.jl")
  end
  module RoleORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/RoleORM.jl")
  end
  module AppuserRoleAssoORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/AppuserRoleAssoORM.jl")
  end
  module RoleRoleAssoORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/RoleRoleAssoORM.jl")
  end
  module OutbreakORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/OutbreakORM.jl")
  end
  module OutbreakInfectiousStatusAssoORM
    using ..ORM, ...Model
    using PostgresORM
    include("./ORM/OutbreakInfectiousStatusAssoORM.jl")
  end

end  # module ORM

module Controller

  module AppuserCtrl
    include("Controller/AppuserCtrl/AppuserCtrl-def.jl")
  end

  module ETLCtrl
    include("Controller/ETLCtrl/ETLCtrl-def.jl")
  end

  module PatientCtrl
    include("Controller/PatientCtrl/PatientCtrl-def.jl")
  end

  module StayCtrl
    include("Controller/StayCtrl/StayCtrl-def.jl")
  end

  module UnitCtrl
    include("Controller/UnitCtrl/UnitCtrl-def.jl")
  end

  module AnalysisCtrl
    include("Controller/AnalysisCtrl/AnalysisCtrl-def.jl")
  end

  module AnalysisTypeCtrl
    include("Controller/AnalysisTypeCtrl/AnalysisTypeCtrl-def.jl")
  end

  module InfectiousStatusCtrl
    include("Controller/InfectiousStatusCtrl/InfectiousStatusCtrl-def.jl")
  end

  # Default CRUD actions are the base of the Controller module
  include("Controller/default-crud-def.jl")

end # module Controller

# using
include("using-for-imp.jl")
# using ..Controller.AnalysisCtrl,..Controller.StayCtrl,
#       ..Controller.PatientCtrl, ..Controller.AnalysisTypeCtrl,
#       ..Controller.InfectiousStatusCtrl,
#       ..Model
# using DataFrames

# Default CRUD implementation
include("Controller/default-crud-imp.jl")

# TRAQUERUtil
# include("TRAQUERUtil/using.jl")
include("TRAQUERUtil/util-imp.jl")
include("TRAQUERUtil/util-imp-partition.jl")
include("TRAQUERUtil/utils-impl-ref-generation.jl")
include("TRAQUERUtil/do-functions.jl")

# AppuserCtrl
include("Controller/AppuserCtrl/AppuserCtrl-imp.jl")

# PatientCtrl
include("Controller/PatientCtrl/PatientCtrl-imp.jl")

# StayCtrl
include("Controller/StayCtrl/StayCtrl-imp.jl")

# AnalysisCtrl
include("Controller/AnalysisCtrl/AnalysisCtrl-imp.jl")

# AnalysisTypeCtrl
include("Controller/AnalysisTypeCtrl/AnalysisTypeCtrl-imp.jl")

# ETLCtrl
include("Controller/ETLCtrl/ETLCtrl-importStays-imp.jl")
include("Controller/ETLCtrl/ETLCtrl-importAnalyses-imp.jl")

# InfectiousStatusCtrl
include("Controller/InfectiousStatusCtrl/InfectiousStatusCtrl-imp.jl")

# UnitCtrl
include("Controller/UnitCtrl/UnitCtrl-imp.jl")

PostgresORM.ModificationORM.get_schema_name() = "supervision"

const config = TRAQUERUtil.loadConf()

end # module
