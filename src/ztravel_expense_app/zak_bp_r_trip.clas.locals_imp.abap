CLASS lhc_expense DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS check_mandatory_fields FOR VALIDATE ON SAVE
      keys FOR Expense~check_mandatory_fields.

ENDCLASS.

CLASS lhc_expense IMPLEMENTATION.

  METHOD check_mandatory_fields.
    DATA permission_expense TYPE STRUCTURE FOR PERMISSIONS REQUEST zak_r_expense.
    DATA reported_zak_r_expense_li LIKE LINE OF reported-expense.

    DATA(description_permission_expense) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref(
                                                                      REF #( permission_expense-%field ) ) ).
    DATA(components_permission_expense) = description_permission_expense->get_components( ).

    LOOP AT components_permission_expense INTO DATA(component_permission_expense).
      permission_expense-%field-(component_permission_expense-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    " Get current field values
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Expense
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_expenses).

    LOOP AT lt_expenses INTO DATA(ls_expense).

      GET PERMISSIONS ONLY INSTANCE FEATURES ENTITY ZAK_R_Expense
          FROM VALUE #( ( uuid = ls_expense-uuid ) )
          REQUEST permission_expense
          RESULT DATA(permission_result).

      LOOP AT components_permission_expense INTO component_permission_expense.
        " Permission result for instances (field ( features : instance ) CancelReason;) is stored in an internal table.
        " So we have to retrieve the information for the current entity
        "  whereas the global information ( field ( mandatory ) DeadlineDate; ) is stored in a structure.

        IF NOT (     permission_result-global-%field-(component_permission_expense-name)  = if_abap_behv=>fc-f-mandatory
                 AND ls_expense-(component_permission_expense-name) IS INITIAL ).
          CONTINUE.
        ENDIF.

        APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expense.

        " Since %element-(component_permission_request-name) = if_abap_behv=>mk-on could not be added using a VALUE statement
        "  add the value via assigning value to the field of a structure

        CLEAR reported_zak_r_expense_li.
        reported_zak_r_expense_li-%tky = ls_expense-%tky.
        reported_zak_r_expense_li-%element-(component_permission_expense-name) = if_abap_behv=>mk-on.
        reported_zak_r_expense_li-%msg = new_message( id       = 'ZMSG_TRIP'
                                                   number   = 002
                                                   severity = if_Abap_behv_message=>severity-error
                                                   v1       = |{ ls_expense-uuid }|
                                                   v2       = |{ component_permission_expense-name }| ).

        APPEND reported_zak_r_expense_li TO reported-expense.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zak_r_trip DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Trip
        RESULT result,
      check_mandatory_fields FOR VALIDATE ON SAVE
       keys FOR Trip~check_mandatory_fields,
      start_prior_to_end_date FOR VALIDATE ON SAVE
            keys FOR Trip~start_prior_to_end_date.
ENDCLASS.

CLASS lhc_zak_r_trip IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD check_mandatory_fields.
    DATA permission_trip TYPE STRUCTURE FOR PERMISSIONS REQUEST zak_r_trip.
    DATA reported_zak_r_trip_li LIKE LINE OF reported-trip.

    DATA(description_permission_trip) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref(
                                                                      REF #( permission_trip-%field ) ) ).
    DATA(components_permission_trip) = description_permission_trip->get_components( ).

    LOOP AT components_permission_trip INTO DATA(component_permission_trip).
      permission_trip-%field-(component_permission_trip-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    " Get current field values
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Trip
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_trips).

    LOOP AT lt_trips INTO DATA(ls_trip).

      GET PERMISSIONS ONLY INSTANCE FEATURES ENTITY ZAK_R_Trip
          FROM VALUE #( ( uuid = ls_trip-uuid ) )
          REQUEST permission_trip
          RESULT DATA(permission_result).

      LOOP AT components_permission_trip INTO component_permission_trip.
        " Permission result for instances (field ( features : instance ) CancelReason;) is stored in an internal table.
        " So we have to retrieve the information for the current entity
        "  whereas the global information ( field ( mandatory ) DeadlineDate; ) is stored in a structure.

        IF NOT (     permission_result-global-%field-(component_permission_trip-name)  = if_abap_behv=>fc-f-mandatory
                 AND ls_trip-(component_permission_trip-name) IS INITIAL ).
          CONTINUE.
        ENDIF.

        APPEND VALUE #( %tky = ls_trip-%tky ) TO failed-trip.

        " Since %element-(component_permission_request-name) = if_abap_behv=>mk-on could not be added using a VALUE statement
        "  add the value via assigning value to the field of a structure

        CLEAR reported_zak_r_trip_li.
        reported_zak_r_trip_li-%tky = ls_trip-%tky.
        reported_zak_r_trip_li-%element-(component_permission_trip-name) = if_abap_behv=>mk-on.
        reported_zak_r_trip_li-%msg = new_message( id       = 'ZMSG_TRIP'
                                                   number   = 001
                                                   severity = if_Abap_behv_message=>severity-error
                                                   v1       = |{ ls_trip-uuid }|
                                                   v2       = |{ component_permission_trip-name }| ).

        APPEND reported_zak_r_trip_li TO reported-trip.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD start_prior_to_end_date.
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Trip
         FIELDS ( StartDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_trips).

    LOOP AT lt_trips INTO DATA(ls_trip).
      IF ls_trip-StartDate <= ls_trip-EndDate.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = ls_trip-%tky ) TO failed-trip.

      APPEND VALUE #( %tky = ls_trip-%tky
                      %element-EndDate = if_abap_behv=>mk-on
                      %msg = new_message( id       = 'ZMSG_TRIP'
                                          number   = 003
                                          severity = if_Abap_behv_message=>severity-error
                                          v1       = |{ ls_trip-uuid }| ) ) TO reported-trip.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
