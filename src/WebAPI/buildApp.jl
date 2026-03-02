function WebAPI.build_app()
    mux_filters = (
        Mux.stack(WebAPI.mux_get_appuser_from_jwt),
    )
    endpoints = (
        # Hello
        route("/api/hello", WebAPI.handle_hello),
        # Auth
        route("/api/authenticate", WebAPI.handle_authenticate),
        # Appuser
        route("/api/appuser/get-all-users", WebAPI.handle_appuser_get_all_users),
        route("/api/appuser/save", WebAPI.handle_appuser_save),
        route("/api/appuser/retrieve-user-from-id", WebAPI.handle_appuser_retrieve_user_from_id),
        # Analysis
        route("/api/analysis/listing", WebAPI.handle_analysis_listing),
        route("/api/analysis/upsert", WebAPI.handle_analysis_upsert),
        route("/api/analysis/get-analyses-from-patient", WebAPI.handle_analysis_get_from_patient),
        # Analysis request
        route("/api/analysis-request/listing", WebAPI.handle_analysis_request_listing),
        route("/api/analysis-request/save", WebAPI.handle_analysis_request_save),
        route("/api/analysis-request/listing-as-xlsx", WebAPI.handle_analysis_request_listing_as_xlsx),
        # Contact exposure
        route("/api/contact-exposure/patient-exposures-for-listing", WebAPI.handle_contact_exposure_patient_for_listing),
        route("/api/contact-exposure/simulate-contact-exposures", WebAPI.handle_contact_exposure_simulate),
        # Enum
        route("/api/enum/posible-values/:enumType", WebAPI.handle_enum_possible_values),
        # Event requiring attention
        route("/api/event-requiring-attention/get-event", WebAPI.handle_event_requiring_attention_get),
        route("/api/event-requiring-attention/update", WebAPI.handle_event_requiring_attention_update),
        # Exposed function
        route("/api/exposed-function/get-functions", WebAPI.handle_exposed_function_get),
        route("/api/exposed-function/execute", WebAPI.handle_exposed_function_execute),
        # Infectious status
        route("/api/infectious-status/listing", WebAPI.handle_infectious_status_listing),
        route("/api/infectious-status/upsert", WebAPI.handle_infectious_status_upsert),
        route("/api/infectious-status/delete", WebAPI.handle_infectious_status_delete),
        route("/api/infectious-status/get-infectious-status-from-infectious-status-filter", WebAPI.handle_infectious_status_get_from_filter),
        route("/api/infectious-status/update-vector-property-outbreak-infectious-status-assoes", WebAPI.handle_infectious_status_update_outbreak_assos),
        # Misc
        route("/api/misc/get-current-frontend-version", WebAPI.handle_misc_get_frontend_version),
        route("/api/misc/name-of-dataset-password-header-for-http-request", WebAPI.handle_misc_dataset_password_header_name),
        route("/api/misc/reset-data", WebAPI.handle_misc_reset_data),
        route("/api/misc/process-newly-integrated-data", WebAPI.handle_misc_process_newly_integrated_data),
        # Outbreak
        route("/api/outbreak/save", WebAPI.handle_outbreak_save),
        route("/api/outbreak/initialize", WebAPI.handle_outbreak_initialize),
        route("/api/outbreak/get-outbreak-from-outbreak-filter", WebAPI.handle_outbreak_get_from_filter),
        route("/api/outbreak/get-outbreak-from-event-requiring-attention", WebAPI.handle_outbreak_get_from_event),
        route("/api/outbreak/get-outbreaks-that-can-be-associated-to-infectious-status", WebAPI.handle_outbreak_get_associable),
        route("/api/outbreak/get-outbreak-infectious-status-assos-from-infectious-status", WebAPI.handle_outbreak_get_infectious_status_assos),
        route("/api/outbreak/get-outbreak-unit-assos-from-outbreak", WebAPI.handle_outbreak_get_unit_assos_from_outbreak),
        route("/api/outbreak/get-outbreak-unit-assos-from-infectious-status", WebAPI.handle_outbreak_get_unit_assos_from_infectious_status),
        # Outbreak unit asso
        route("/api/outbreak-unit-asso/update-asso-and-refresh-exposures-and-contact-statuses", WebAPI.handle_outbreak_unit_asso_update_and_refresh),
        # Patient
        route("/api/patient/listing", WebAPI.handle_patient_listing),
        route("/api/patient/create", WebAPI.handle_patient_create),
        route("/api/patient/update-name-and-birthdate", WebAPI.handle_patient_update_name_and_birthdate),
        route("/api/patient/get-decrypted", WebAPI.handle_patient_get_decrypted),
        route("/api/patient/get-patient-decrypted-info/:id", WebAPI.handle_patient_get_decrypted_info),
        # Role
        route("/api/role/composed-roles-for-listing", WebAPI.handle_role_composed_for_listing),
        route("/api/role/all-composed-roles", WebAPI.handle_role_all_composed),
        route("/api/role/all-composed-roles/:appuser_type", WebAPI.handle_role_all_composed_by_type),
        # Stay
        route("/api/stay/listing", WebAPI.handle_stay_listing),
        route("/api/stay/upsert", WebAPI.handle_stay_upsert),
        route("/api/stay/get-stay-from-stay-filter", WebAPI.handle_stay_get_from_filter),
        route("/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso", WebAPI.handle_stay_get_carriers_or_contacts),
        route("/api/stay/get-patient-hospitalizations-dates", WebAPI.handle_stay_get_hospitalization_dates),
        route("/api/stay/save-patient-isolation-date-from-event-requiring-attention", WebAPI.handle_stay_save_isolation_date),
        route("/api/stay/delete-isolation-time", WebAPI.handle_stay_delete_isolation_time),
        # Task waiting for user execution
        route("/api/task-waiting-for-user-execution/execute-pending-tasks", WebAPI.handle_task_execute_pending),
        # Unit
        route("/api/unit/get-all-units", WebAPI.handle_unit_get_all),
    )
    @app web_api = (
        Mux.defaults,
        mux_filters...,
        endpoints...,
        Mux.notfound(),
    )
    return web_api
end
