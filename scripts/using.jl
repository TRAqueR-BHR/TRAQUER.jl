# NOTE that we dont call @everywhere because this we want worker 1 to first load the modules,
# if not for some reason it was causing issues.
# The caller of this script can to @everywhere include("using.jl")
using TRAQUER
using TRAQUER.TRAQUERUtil
using TRAQUER.Model
using TRAQUER.Enum
using TRAQUER.Custom
using TRAQUER.Controller
using TRAQUER.Controller.PatientCtrl
using TRAQUER.Controller.UnitCtrl
using TRAQUER.Controller.ETLCtrl
using TRAQUER.Controller.StayCtrl
using TRAQUER.Controller.AnalysisResultCtrl
using TRAQUER.Controller.InfectiousStatusCtrl
using TRAQUER.Controller.ContactExposureCtrl
using TRAQUER.Controller.AppuserCtrl
using TRAQUER.Controller.OutbreakCtrl
using TRAQUER.Controller.SchedulerCtrl
using TRAQUER.Controller.MaintenanceCtrl
using TRAQUER.Controller.EventRequiringAttentionCtrl

using TRAQUER.Enum.AnalysisRequestStatusType
using TRAQUER.Enum.AnalysisResultValueType
using TRAQUER.Enum.AppuserType
using TRAQUER.Enum.AnalysisRequestType
using TRAQUER.Enum.Gender
using TRAQUER.Enum.HospitalizationStatusType
using TRAQUER.Enum.SampleMaterialType
using TRAQUER.Enum.InfectiousStatusType
using TRAQUER.Enum.InfectiousAgentCategory
using TRAQUER.Enum.RoleCodeName
using TRAQUER.Enum.OutbreakCriticity

using PostgresORM, Dates, TimeZones, DataFrames, StringCases, UUIDs, Distributed
using Logging,LoggingExtras
