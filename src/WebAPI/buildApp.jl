function WebAPI.build_app()
    mux_filters = (
        Mux.stack(WebAPI.Filters.mux_get_appuser_from_jwt),
    )
    endpoints = (
        # Hello
        route("/api/hello", Endpoints.handle_hello),
        # Auth
        route("/api/authenticate", Endpoints.handle_authenticate),
        # Appuser
        route("/api/appuser/get-all-users", Endpoints.handle_appuser_get_all_users),
        route("/api/appuser/save", Endpoints.handle_appuser_save),
        route("/api/appuser/retrieve-user-from-id", Endpoints.handle_appuser_retrieve_user_from_id),
        # Analysis
        route("/api/analysis/listing", Endpoints.handle_analysis_listing),
        route("/api/analysis/upsert", Endpoints.handle_analysis_upsert),
        route("/api/analysis/get-analyses-from-patient", Endpoints.handle_analysis_get_from_patient),
        # Analysis request
        route("/api/analysis-request/listing", Endpoints.handle_analysis_request_listing),
        route("/api/analysis-request/save", Endpoints.handle_analysis_request_save),
        route("/api/analysis-request/listing-as-xlsx", Endpoints.handle_analysis_request_listing_as_xlsx),
        # Contact exposure
        route("/api/contact-exposure/patient-exposures-for-listing", Endpoints.handle_contact_exposure_patient_for_listing),
        route("/api/contact-exposure/simulate-contact-exposures", Endpoints.handle_contact_exposure_simulate),
        # Enum
        route("/api/enum/posible-values/:enumType", Endpoints.handle_enum_possible_values),
        # Event requiring attention
        route("/api/event-requiring-attention/get-event", Endpoints.handle_event_requiring_attention_get),
        route("/api/event-requiring-attention/update", Endpoints.handle_event_requiring_attention_update),
        # Exposed function
        route("/api/exposed-function/get-functions", Endpoints.handle_exposed_function_get),
        route("/api/exposed-function/execute", Endpoints.handle_exposed_function_execute),
        # Infectious status
        route("/api/infectious-status/listing", Endpoints.handle_infectious_status_listing),
        route("/api/infectious-status/upsert", Endpoints.handle_infectious_status_upsert),
        route("/api/infectious-status/delete", Endpoints.handle_infectious_status_delete),
        route("/api/infectious-status/get-infectious-status-from-infectious-status-filter", Endpoints.handle_infectious_status_get_from_filter),
        route("/api/infectious-status/update-vector-property-outbreak-infectious-status-assoes", Endpoints.handle_infectious_status_update_outbreak_assos),
        # Misc
        route("/api/misc/get-current-frontend-version", Endpoints.handle_misc_get_frontend_version),
        route("/api/misc/name-of-dataset-password-header-for-http-request", Endpoints.handle_misc_dataset_password_header_name),
        route("/api/misc/reset-data", Endpoints.handle_misc_reset_data),
        route("/api/misc/process-newly-integrated-data", Endpoints.handle_misc_process_newly_integrated_data),
        # Outbreak
        route("/api/outbreak/save", Endpoints.handle_outbreak_save),
        route("/api/outbreak/initialize", Endpoints.handle_outbreak_initialize),
        route("/api/outbreak/get-outbreak-from-outbreak-filter", Endpoints.handle_outbreak_get_from_filter),
        route("/api/outbreak/get-outbreak-from-event-requiring-attention", Endpoints.handle_outbreak_get_from_event),
        route("/api/outbreak/get-outbreaks-that-can-be-associated-to-infectious-status", Endpoints.handle_outbreak_get_associable),
        route("/api/outbreak/get-outbreak-infectious-status-assos-from-infectious-status", Endpoints.handle_outbreak_get_infectious_status_assos),
        route("/api/outbreak/get-outbreak-unit-assos-from-outbreak", Endpoints.handle_outbreak_get_unit_assos_from_outbreak),
        route("/api/outbreak/get-outbreak-unit-assos-from-infectious-status", Endpoints.handle_outbreak_get_unit_assos_from_infectious_status),
        # Outbreak unit asso
        route("/api/outbreak-unit-asso/update-asso-and-refresh-exposures-and-contact-statuses", Endpoints.handle_outbreak_unit_asso_update_and_refresh),
        # Patient
        route("/api/patient/listing", Endpoints.handle_patient_listing),
        route("/api/patient/create", Endpoints.handle_patient_create),
        route("/api/patient/update-name-and-birthdate", Endpoints.handle_patient_update_name_and_birthdate),
        route("/api/patient/get-decrypted", Endpoints.handle_patient_get_decrypted),
        route("/api/patient/get-patient-decrypted-info/:id", Endpoints.handle_patient_get_decrypted_info),
        # Role
        route("/api/role/composed-roles-for-listing", Endpoints.handle_role_composed_for_listing),
        route("/api/role/all-composed-roles", Endpoints.handle_role_all_composed),
        route("/api/role/all-composed-roles/:appuser_type", Endpoints.handle_role_all_composed_by_type),
        # Stay
        route("/api/stay/listing", Endpoints.handle_stay_listing),
        route("/api/stay/upsert", Endpoints.handle_stay_upsert),
        route("/api/stay/get-stay-from-stay-filter", Endpoints.handle_stay_get_from_filter),
        route("/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso", Endpoints.handle_stay_get_carriers_or_contacts),
        route("/api/stay/get-patient-hospitalizations-dates", Endpoints.handle_stay_get_hospitalization_dates),
        route("/api/stay/save-patient-isolation-date-from-event-requiring-attention", Endpoints.handle_stay_save_isolation_date),
        route("/api/stay/delete-isolation-time", Endpoints.handle_stay_delete_isolation_time),
        # Task waiting for user execution
        route("/api/task-waiting-for-user-execution/execute-pending-tasks", Endpoints.handle_task_execute_pending),
        # Unit
        route("/api/unit/get-all-units", Endpoints.handle_unit_get_all),
    )
    @app web_api = (
        Mux.defaults,
        mux_filters...,
        endpoints...,
        Mux.notfound(),
    )
    return web_api
end
