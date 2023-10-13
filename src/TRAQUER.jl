module TRAQUER

"""
  greet()

A function that says hello
"""
function greet()
  @info "Hello"
end

function greet(str::AbstractString)
  @info "Hello $str"
end


module Enum
    include("Enum/enums.jl")
end  # module Enum

module TRAQUERUtil
    export openDBConn,openDBConnAndBeginTransaction,beginDBTransaction,
           commitDBTransaction,rollbackDBTransaction,closeDBConn,
           getConf, formatExceptionAndStackTrace, json2entity, getTimeZone,
           executeOnBgThread, createDBConnAndExecute, isMissingOrNothing,
           json2Entity
    include("./TRAQUERUtil/util-def.jl")

end # module TRAQUERUtil

module Model
    export AnalysisRefCrypt, AnalysisRequest, AnalysisResult, AppuserRoleAsso,
           ContactExposure, FrontendVersion, InfectiousStatus,
           EventRequiringAttention, Modification, Outbreak,
           OutbreakInfectiousStatusAsso, Patient, PatientBirthdateCrypt,
           PatientCurrentStatus, PatientNameCrypt, PatientRefCrypt, Role, RoleRoleAsso,
           ScheduledTaskExecution, Stay, TaskWaitingForUserExecution, Unit, WebApiUsage,
           OutbreakUnitAsso, PatientDecrypt
    export Appuser
    using PostgresORM,TimeZones
    using ..Enum.AnalysisRequestStatusType,
          ..Enum.AnalysisResultValueType,
          ..Enum.AppuserType,
          ..Enum.AnalysisRequestType,
          ..Enum.Gender,
          ..Enum.HospitalizationStatusType,
          ..Enum.InfectiousAgentCategory,
          ..Enum.ResponseType,
          ..Enum.EventRequiringAttentionType,
          ..Enum.InfectiousStatusType,
          ..Enum.RoleCodeName,
          ..Enum.SampleMaterialType,
          ..Enum.OutbreakCriticity
    include("Model/abstract-types.jl")
    include("Model-protected/abstract-types.jl")
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
    include("Model/OutbreakUnitAsso.jl")
    include("Model/Patient.jl")
    include("Model/PatientBirthdateCrypt.jl")
    include("Model/PatientCurrentStatus.jl")
    include("Model/PatientNameCrypt.jl")
    include("Model/PatientRefCrypt.jl")
    include("Model/Role.jl")
    include("Model/RoleRoleAsso.jl")
    include("Model/ScheduledTaskExecution.jl")
    include("Model/Stay.jl")
    include("Model/TaskWaitingForUserExecution.jl")
    include("Model/Unit.jl")
    include("Model/WebApiUsage.jl")
    include("Model-protected/Appuser.jl")
    include("Model-protected/PatientDecrypt.jl")
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
        include("./ORM-tracking/InfectiousStatusORM-overwrite.jl")
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
    module OutbreakUnitAssoORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/OutbreakUnitAssoORM.jl")
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
    module ScheduledTaskExecutionORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/ScheduledTaskExecutionORM.jl")
    end
    module StayORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/StayORM.jl")
    end
    module TaskWaitingForUserExecutionORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/TaskWaitingForUserExecutionORM.jl")
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
    module PatientDecryptORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM-tracking/PatientDecryptORM.jl")
    end
    module WebApiUsageORM
        using ..ORM, ...Model
        using PostgresORM
        include("./ORM/WebApiUsageORM.jl")
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

  module InfectiousStatusCtrl
    include("Controller/InfectiousStatusCtrl/InfectiousStatusCtrl-def.jl")
  end

  module OutbreakCtrl
    include("Controller/OutbreakCtrl/OutbreakCtrl-def.jl")
  end

  module OutbreakUnitAssoCtrl
    include("Controller/OutbreakUnitAssoCtrl/OutbreakUnitAssoCtrl-def.jl")
  end

  module EventRequiringAttentionCtrl
    include("Controller/EventRequiringAttentionCtrl/EventRequiringAttentionCtrl-def.jl")
  end

  module ContactExposureCtrl
    include("Controller/ContactExposureCtrl/ContactExposureCtrl-def.jl")
  end

  module TaskWaitingForUserExecutionCtrl
      include("Controller/TaskWaitingForUserExecutionCtrl/TaskWaitingForUserExecutionCtrl-def.jl")
  end

  module WebApiUsageCtrl
      include("Controller/WebApiUsageCtrl/WebApiUsageCtrl-def.jl")
  end

  module SchedulerCtrl
    using Dates
    include("Controller/SchedulerCtrl/SchedulerCtrl-def.jl")
  end

  module MaintenanceCtrl
    include("Controller/MaintenanceCtrl/MaintenanceCtrl-def.jl")
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

# OutbreakCtrl
include("Controller/OutbreakCtrl/OutbreakCtrl-imp.jl")

# OutbreakUnitAssoCtrl
include("Controller/OutbreakUnitAssoCtrl/OutbreakUnitAssoCtrl-imp.jl")

# EventRequiringAttentionCtrl
include("Controller/EventRequiringAttentionCtrl/EventRequiringAttentionCtrl-imp.jl")

# ContactExposureCtrl
include("Controller/ContactExposureCtrl/ContactExposureCtrl-imp.jl")

# UnitCtrl
include("Controller/UnitCtrl/UnitCtrl-imp.jl")

# TaskWaitingForUserExecutionCtrl
include("Controller/TaskWaitingForUserExecutionCtrl/TaskWaitingForUserExecutionCtrl-imp.jl")

# WebApiUsageCtrl
include("Controller/WebApiUsageCtrl/WebApiUsageCtrl-imp.jl")

# SchedulerCtrl
include("Controller/SchedulerCtrl/SchedulerCtrl-imp.jl")

# MaintenanceCtrl
include("Controller/MaintenanceCtrl/MaintenanceCtrl-imp.jl")

# Custom implementation
include(ENV["TRAQUER_CUSTOM_MODULE_IMPLEMENTATION_FILE"])

# Overwrite of other modules
include("Base/push.jl")

PostgresORM.ModificationORM.get_schema_name() = "supervision"

const config = TRAQUERUtil.loadConf()


"""
Scheduler is of type `Timer` it executes every 45s to check whether there is a recurring
action to execute
  (cf  `SchedulerCtrl.checkIfAnythingNeedsToBeExecuted()`).
NOTE : Function `startScheduler()` is to be invoked on one worker only
"""
scheduler = missing

"Create and start the scheduler"
function startScheduler()
   @info "Start scheduler on proc[$(Distributed.myid())]"
   global scheduler =
     Timer(timer -> SchedulerCtrl.checkIfAnythingNeedsToBeExecuted(), 1; interval=45)
end

"Stop the scheduler"
function stopScheduler()
  global scheduler
   @info "Stop scheduler on proc[$(Distributed.myid())]"
   close(scheduler)
end

end # module
