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
           getConf, formatExceptionAndStackTrace, json2Entity, getTimezone
    include("./TRAQUERUtil/util-def.jl")

end # module TRAQUERUtil

module Model
    export AnalysisRefCrypt, AnalysisRequest, AnalysisResult, AppuserRoleAsso,
           ContactExposure, FrontendVersion, InfectiousStatus,
           EventRequiringAttention, Modification, Outbreak,
           OutbreakInfectiousStatusAsso, Patient, PatientBirthdateCrypt,
           PatientCurrentStatus, PatientNameCrypt, PatientRefCrypt, Role, RoleRoleAsso,
           Stay, Unit, OutbreakConfig, OutbreakConfigUnitAsso
    export Appuser
    using PostgresORM,TimeZones
    using ..Enum.AnalysisRequestStatusType,
          ..Enum.AnalysisResultValueType,
          ..Enum.AppuserType,
          ..Enum.AnalysisRequestType,
          ..Enum.Gender,
          ..Enum.HospitalizationStatusType,
          ..Enum.InfectiousAgentCategory,
          ..Enum.InfectiousStatusEventResponseType,
          ..Enum.InfectiousStatusEventType,
          ..Enum.InfectiousStatusType,
          ..Enum.RoleCodeName,
          ..Enum.SampleMaterialType
    include("Model/abstract-types.jl")
    include("Model/AnalysisRefCrypt.jl")
    include("Model/AnalysisRequest.jl")
    include("Model/AnalysisResult.jl")
    include("Model/AppuserRoleAsso.jl")
    include("Model/ContactExposure.jl")
    include("Model/FrontendVersion.jl")
    include("Model/InfectiousStatus.jl")
    include("Model/EventRequiringAttention.jl")
    include("Model/Modification.jl")
    include("Model/Outbreak.jl")
    include("Model/OutbreakInfectiousStatusAsso.jl")
    include("Model/OutbreakConfig.jl")
    include("Model/OutbreakConfigUnitAsso.jl")
    include("Model/Patient.jl")
    include("Model/PatientBirthdateCrypt.jl")
    include("Model/PatientCurrentStatus.jl")
    include("Model/PatientNameCrypt.jl")
    include("Model/PatientRefCrypt.jl")
    include("Model/Role.jl")
    include("Model/RoleRoleAsso.jl")
    include("Model/Stay.jl")
    include("Model/Unit.jl")
    include("Model-protected/Appuser.jl")
end  # module Model

module ORM

    module AnalysisRefCryptORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/AnalysisRefCryptORM.jl")
    end
    module AnalysisRequestORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/AnalysisRequestORM.jl")
    end
    module AnalysisResultORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/AnalysisResultORM.jl")
    end
    module AppuserRoleAssoORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/AppuserRoleAssoORM.jl")
    end
    module ContactExposureORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/ContactExposureORM.jl")
    end
    module FrontendVersionORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/FrontendVersionORM.jl")
    end
    module InfectiousStatusORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/InfectiousStatusORM.jl")
    end
    module EventRequiringAttentionORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/EventRequiringAttentionORM.jl")
    end
    # module ModificationORM
    #     using ..ORM, ...Model
    #     using PostgresORM
    #     include("./ORM/ModificationORM.jl")
    # end
    module OutbreakORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/OutbreakORM.jl")
    end
    module OutbreakConfigORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/OutbreakConfigORM.jl")
    end
    module OutbreakConfigUnitAssoORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/OutbreakConfigUnitAssoORM.jl")
    end
    module OutbreakInfectiousStatusAssoORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/OutbreakInfectiousStatusAssoORM.jl")
    end
    module PatientORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/PatientORM.jl")
    end
    module PatientBirthdateCryptORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/PatientBirthdateCryptORM.jl")
    end
    module PatientCurrentStatusORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/PatientCurrentStatusORM.jl")
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
    module RoleORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/RoleORM.jl")
    end
    module RoleRoleAssoORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/RoleRoleAssoORM.jl")
    end

    module StayORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/StayORM.jl")
    end
    module UnitORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/UnitORM.jl")
    end
    module AppuserORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/AppuserORM.jl")
        include("./ORM-tracking/AppuserORM-tracking.jl")
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

  module AnalysisResultCtrl
    include("Controller/AnalysisResultCtrl/AnalysisResultCtrl-def.jl")
  end

  "Un super module"
  module InfectiousStatusCtrl
    include("Controller/InfectiousStatusCtrl/InfectiousStatusCtrl-def.jl")
  end

  module EventRequiringAttentionCtrl
    include("Controller/EventRequiringAttentionCtrl/EventRequiringAttentionCtrl-def.jl")
  end

  module ContactExposureCtrl
    include("Controller/ContactExposureCtrl/ContactExposureCtrl-def.jl")
  end

  # Default CRUD actions are the base of the Controller module
  include("Controller/default-crud-def.jl")

end # module Controller

module Custom
    include(ENV["TRAQUER_CUSTOM_MODULE_DEFINITION_FILE"])
end

# using
include("using-for-imp.jl")

# Default CRUD implementation
include("Controller/default-crud-imp.jl")

# TRAQUERUtil
# include("TRAQUERUtil/using.jl")
include("TRAQUERUtil/util-imp.jl")
include("TRAQUERUtil/util-imp-partition.jl")
include("TRAQUERUtil/utils-impl-ref-generation.jl")
include("TRAQUERUtil/do-functions.jl")
include("TRAQUERUtil/getMappingAnalysisRequestType2InfectiousAgentCategory.jl")
include("TRAQUERUtil/analysisRequestType2InfectiousAgentCategory.jl")
include("TRAQUERUtil/infectiousAgentCategory2AnalysisRequestTypes.jl")

# AppuserCtrl
include("Controller/AppuserCtrl/AppuserCtrl-imp.jl")

# PatientCtrl
include("Controller/PatientCtrl/PatientCtrl-imp.jl")

# StayCtrl
include("Controller/StayCtrl/StayCtrl-imp.jl")

# AnalysisResultCtrl
include("Controller/AnalysisResultCtrl/AnalysisResultCtrl-imp.jl")

# ETLCtrl
include("Controller/ETLCtrl/ETLCtrl-imp.jl")

# InfectiousStatusCtrl
include("Controller/InfectiousStatusCtrl/InfectiousStatusCtrl-imp.jl")

# EventRequiringAttentionCtrl
include("Controller/EventRequiringAttentionCtrl/EventRequiringAttentionCtrl-imp.jl")

# ContactExposureCtrl
include("Controller/ContactExposureCtrl/ContactExposureCtrl-imp.jl")

# UnitCtrl
include("Controller/UnitCtrl/UnitCtrl-imp.jl")

# Custom implementation
include(ENV["TRAQUER_CUSTOM_MODULE_IMPLEMENTATION_FILE"])

PostgresORM.ModificationORM.get_schema_name() = "supervision"

const config = TRAQUERUtil.loadConf()

end # module
