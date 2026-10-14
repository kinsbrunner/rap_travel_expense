CLASS zak_cl_trip_reimburse_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_rt_run.

    "! <p class="shorttext synchronized" lang="en">Status</p>
    DATA status type zak_status.

    "! <p class="shorttext synchronized" lang="en">Test mode?</p>
    DATA mode type abap_boolean.

    METHODS constructor
      RAISING cx_bali_runtime.

  PRIVATE SECTION.
    DATA application_log TYPE REF TO if_bali_log.

    METHODS add_text_to_app_log
      IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
      RAISING   cx_bali_runtime.


ENDCLASS.



CLASS zak_cl_trip_reimburse_job IMPLEMENTATION.
  METHOD constructor.
    application_log = cl_bali_log=>create_with_header( header = cl_bali_header_setter=>create(
                                                                    object      = 'ZAK_TRIP_APPL_LOG'
                                                                    subobject   = 'ZAK_TRIP_JOB_EXEC'
                                                                    external_id = 'ZAPP_DEMO_LOG_DEV' ) ).
  ENDMETHOD.

  METHOD add_text_to_app_log.
    DATA(application_log_free_text) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_status
                                                                        text     = i_text ).

    application_log_free_text->set_detail_level( detail_level = '1' ).
    application_log->add_item( item = application_log_free_text ).
    cl_bali_log_db=>get_instance( )->save_log( log                        = application_log
                                               assign_to_current_appl_job = abap_true ).
  ENDMETHOD.

  METHOD if_apj_rt_run~execute.
    DATA message_text TYPE cl_bali_free_text_setter=>ty_text.

    TRY.
        " Job started.
        MESSAGE s001(zmsg_trip_job) INTO message_text.
        add_text_to_app_log( i_text = message_text ).

        SELECT FROM zak_r_trip
          FIELDS *
          WHERE status = @status
          INTO TABLE @DATA(trips_to_reimburse).

        DATA(count_trips) = lines( trips_to_reimburse ).
        " There are &1 trips eligible to be reimbursed.
        MESSAGE i005(zmsg_trip_job) WITH count_trips INTO message_text.
        add_text_to_app_log( i_text = message_text ).

        LOOP AT trips_to_reimburse INTO DATA(trip).
          DATA(reimbursed) = abap_false.

          MODIFY ENTITIES OF zak_r_trip
                 ENTITY Trip
                 EXECUTE reimburse
                 FROM VALUE #( ( uuid = trip-uuid ) )
                 FAILED DATA(failed).

          IF failed IS INITIAL AND mode = abap_false.
            COMMIT ENTITIES RESPONSE OF zak_r_Trip
                   FAILED DATA(commit_failed).

            reimbursed = xsdbool( commit_failed IS INITIAL ).
          ENDIF.

          IF reimbursed = abap_false.
            " Discard this trip's changes so they don't ride along with the next commit
            ROLLBACK ENTITIES.
          ENDIF.

          IF reimbursed = abap_true OR ( mode = abap_true AND failed IS INITIAL ).
            " Trip '&1' has been reimbursed.
            MESSAGE s004(zmsg_trip_job) WITH trip-title INTO message_text.
            add_text_to_app_log( i_text = message_text ).
          ELSE.
            " Trip '&1' could not be reimbursed.
            MESSAGE e006(zmsg_trip_job) WITH trip-title INTO message_text.
            add_text_to_app_log( i_text = message_text ).
          ENDIF.
        ENDLOOP.

        " Job finished.
        MESSAGE s002(zmsg_trip_job) INTO message_text.
        add_text_to_app_log( i_text = message_text ).

      CATCH cx_bali_runtime INTO DATA(log_error).
        RAISE EXCEPTION NEW cx_apj_rt_content( previous = log_error ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
