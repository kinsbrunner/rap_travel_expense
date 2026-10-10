CLASS lhc_expense DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS check_mandatory_fields FOR VALIDATE ON SAVE
      keys FOR Expense~check_mandatory_fields.
    METHODS update_totals FOR DETERMINE ON MODIFY
      keys FOR Expense~update_totals.
    METHODS check_amount_is_possitive FOR VALIDATE ON SAVE
      keys FOR Expense~check_amount_is_possitive.

    METHODS check_expense_date_within_trip FOR VALIDATE ON SAVE
      keys FOR Expense~check_expense_date_within_trip.

ENDCLASS.

CLASS lhc_expense IMPLEMENTATION.
  METHOD check_mandatory_fields.
    DATA permission_expense        TYPE STRUCTURE FOR PERMISSIONS REQUEST zak_r_expense.
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
         RESULT DATA(expenses).

    LOOP AT expenses INTO DATA(expense).
      " Invalidate state messages of a previous run of this validation
      APPEND VALUE #( %tky        = expense-%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-expense.

      GET PERMISSIONS ONLY INSTANCE FEATURES ENTITY ZAK_R_Expense
          FROM VALUE #( ( uuid = expense-uuid ) )
          REQUEST permission_expense
          RESULT DATA(permission_result).

      LOOP AT components_permission_expense INTO component_permission_expense.
        " Permission result for instances (field ( features : instance ) CancelReason;) is stored in an internal table.
        " So we have to retrieve the information for the current entity
        "  whereas the global information ( field ( mandatory ) DeadlineDate; ) is stored in a structure.

        IF NOT (     permission_result-global-%field-(component_permission_expense-name)  = if_abap_behv=>fc-f-mandatory
                 AND expense-(component_permission_expense-name) IS INITIAL ).
          CONTINUE.
        ENDIF.

        APPEND VALUE #( %tky = expense-%tky ) TO failed-expense.

        " Since %element-(component_permission_request-name) = if_abap_behv=>mk-on could not be added using a VALUE statement
        "  add the value via assigning value to the field of a structure

        CLEAR reported_zak_r_expense_li.
        reported_zak_r_expense_li-%tky        = expense-%tky.
        reported_zak_r_expense_li-%state_area = 'VALIDATE_MANDATORY'.
        reported_zak_r_expense_li-%path-trip-%is_draft = expense-%is_draft.
        reported_zak_r_expense_li-%path-trip-uuid      = expense-ParentUUID.
        reported_zak_r_expense_li-%element-(component_permission_expense-name) = if_abap_behv=>mk-on.
        reported_zak_r_expense_li-%msg = new_message( id       = 'ZMSG_TRIP'
                                                      number   = 002
                                                      severity = if_Abap_behv_message=>severity-error
                                                      v1       = |{ expense-uuid }|
                                                      v2       = |{ component_permission_expense-name }| ).

        APPEND reported_zak_r_expense_li TO reported-expense.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_totals.
    DATA trips_update TYPE TABLE FOR UPDATE zak_r_trip\\Trip.

    " Parent trips of the created/changed/deleted expenses (draft-aware via %tky).
    " Read by association so that deleted expenses still resolve their parent.
    READ ENTITIES OF zak_r_trip IN LOCAL MODE
         ENTITY Expense BY \_Trip
         FIELDS ( Total Currency )
         WITH CORRESPONDING #( keys )
         RESULT DATA(trips).

    IF trips IS INITIAL.
      " Delete: the expense is no longer readable via EML, get its parent from the draft table
      SELECT FROM zak_expense_d
        FIELDS DISTINCT parentuuid
        FOR ALL ENTRIES IN @keys
        WHERE uuid = @keys-uuid
        INTO TABLE @DATA(parents).

      trips = VALUE #( FOR parent IN parents
                       ( %is_draft = if_abap_behv=>mk-on
                         uuid      = parent-parentuuid ) ).
      IF trips IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    SORT trips BY %tky.
    DELETE ADJACENT DUPLICATES FROM trips COMPARING %tky.
    IF trips IS INITIAL.
      RETURN.
    ENDIF.

    " All current expenses of those trips in one read (deleted ones are not returned)
    READ ENTITIES OF zak_r_trip IN LOCAL MODE
         ENTITY Trip BY \_Expense
         FIELDS ( ParentUUID Price Currency ExpenseDate )
         WITH CORRESPONDING #( trips )
         RESULT DATA(expenses).

    LOOP AT trips INTO DATA(trip).
      DATA(total) = VALUE zak_r_trip-Total( ).

      LOOP AT expenses INTO DATA(expense)
           WHERE     ParentUUID = trip-uuid
                 AND %is_draft  = trip-%is_draft.

        total += expense-Price.

      ENDLOOP.

      APPEND VALUE #( %tky           = trip-%tky
                      Total          = total
                      %control-Total = if_abap_behv=>mk-on )
             TO trips_update.
    ENDLOOP.

    IF trips_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zak_r_trip IN LOCAL MODE
           ENTITY Trip
           UPDATE FROM trips_update
           REPORTED DATA(update_reported).

    reported-trip = CORRESPONDING #( DEEP update_reported-trip ).
  ENDMETHOD.

  METHOD check_amount_is_possitive.
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Expense
         FIELDS ( ParentUuid Price )
         WITH CORRESPONDING #( keys )
         RESULT DATA(expenses).

    LOOP AT expenses INTO DATA(expense).
      " Invalidate state messages of a previous run of this validation
      APPEND VALUE #( %tky                 = expense-%tky
                      %state_area          = 'VALIDATE_PRICE' ) TO reported-expense.

      IF expense-Price > 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = expense-%tky ) TO failed-expense.

      APPEND VALUE #( %tky                 = expense-%tky
                      %state_area          = 'VALIDATE_PRICE'
                      %path-trip-%is_draft = expense-%is_draft
                      %path-trip-uuid      = expense-ParentUUID
                      %element-Price       = if_abap_behv=>mk-on
                      %msg                 = new_message( id       = 'ZMSG_TRIP'
                                                          number   = 005
                                                          severity = if_Abap_behv_message=>severity-error ) ) TO reported-expense.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_expense_date_within_trip.
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Expense
         FIELDS ( ParentUUID ExpenseDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(expenses).

    " Parent trips of all validated expenses in one read (draft-aware via %tky);
    " LINK maps each expense (source) to its trip (target)
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Expense BY \_Trip
         FIELDS ( StartDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(trips)
         LINK DATA(links).

    LOOP AT expenses INTO DATA(expense).
      " Invalidate state messages of a previous run of this validation
      APPEND VALUE #( %tky                 = expense-%tky
                      %state_area          = 'VALIDATE_EXPENSE_DATE' ) TO reported-expense.

      IF expense-ExpenseDate IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE links INTO DATA(link) WITH KEY id COMPONENTS source-%tky = expense-%tky.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " Missing trip dates are reported by the trip's own mandatory-field validation
      READ TABLE trips INTO DATA(trip) WITH KEY id COMPONENTS %tky = link-target-%tky.
      IF    sy-subrc       <> 0
         OR trip-StartDate IS INITIAL
         OR trip-EndDate   IS INITIAL.
        CONTINUE.
      ENDIF.

      IF expense-ExpenseDate BETWEEN trip-StartDate AND trip-EndDate.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = expense-%tky ) TO failed-expense.

      APPEND VALUE #( %tky                 = expense-%tky
                      %state_area          = 'VALIDATE_EXPENSE_DATE'
                      %path-trip-%is_draft = expense-%is_draft
                      %path-trip-uuid      = expense-ParentUUID
                      %element-ExpenseDate = if_abap_behv=>mk-on
                      %msg                 = new_message( id       = 'ZMSG_TRIP'
                                                          number   = 004
                                                          severity = if_abap_behv_message=>severity-error ) ) TO reported-expense.
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
      check_start_prior_to_end_date FOR VALIDATE ON SAVE
            keys FOR Trip~check_start_prior_to_end_date,
      set_initial_status FOR DETERMINE ON SAVE
            keys FOR Trip~set_initial_status,
      get_instance_features FOR INSTANCE FEATURES
            keys REQUEST requested_features FOR Trip RESULT result.
ENDCLASS.

CLASS lhc_zak_r_trip IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD check_mandatory_fields.
    DATA permission_trip        TYPE STRUCTURE FOR PERMISSIONS REQUEST zak_r_trip.
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
         RESULT DATA(trips).

    LOOP AT trips INTO DATA(trip).

      " Invalidate state messages of a previous run of this validation
      APPEND VALUE #( %tky        = trip-%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-trip.

      GET PERMISSIONS ONLY INSTANCE FEATURES ENTITY ZAK_R_Trip
          FROM VALUE #( ( uuid = trip-uuid ) )
          REQUEST permission_trip
          RESULT DATA(permission_result).

      LOOP AT components_permission_trip INTO component_permission_trip.
        " Permission result for instances (field ( features : instance ) CancelReason;) is stored in an internal table.
        " So we have to retrieve the information for the current entity
        "  whereas the global information ( field ( mandatory ) DeadlineDate; ) is stored in a structure.

        IF NOT (     permission_result-global-%field-(component_permission_trip-name)  = if_abap_behv=>fc-f-mandatory
                 AND trip-(component_permission_trip-name) IS INITIAL ).
          CONTINUE.
        ENDIF.

        APPEND VALUE #( %tky = trip-%tky ) TO failed-trip.

        " Since %element-(component_permission_request-name) = if_abap_behv=>mk-on could not be added using a VALUE statement
        "  add the value via assigning value to the field of a structure

        CLEAR reported_zak_r_trip_li.
        reported_zak_r_trip_li-%tky        = trip-%tky.
        reported_zak_r_trip_li-%state_area = 'VALIDATE_MANDATORY'.
        reported_zak_r_trip_li-%element-(component_permission_trip-name) = if_abap_behv=>mk-on.
        reported_zak_r_trip_li-%msg = new_message( id       = 'ZMSG_TRIP'
                                                   number   = 001
                                                   severity = if_Abap_behv_message=>severity-error
                                                   v1       = |{ trip-uuid }|
                                                   v2       = |{ component_permission_trip-name }| ).

        APPEND reported_zak_r_trip_li TO reported-trip.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_start_prior_to_end_date.
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Trip
         FIELDS ( StartDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(trips).

    LOOP AT trips INTO DATA(trip).
      " Invalidate state messages of a previous run of this validation
      APPEND VALUE #( %tky        = trip-%tky
                      %state_area = 'VALIDATE_DATES' ) TO reported-trip.

      " Missing dates are reported by check_mandatory_fields
      IF    trip-StartDate IS INITIAL
         OR trip-EndDate   IS INITIAL
         OR trip-StartDate <= trip-EndDate.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = trip-%tky ) TO failed-trip.

      APPEND VALUE #( %tky               = trip-%tky
                      %state_area        = 'VALIDATE_DATES'
                      %element-StartDate = if_abap_behv=>mk-on
                      %element-EndDate   = if_abap_behv=>mk-on
                      %msg               = new_message( id       = 'ZMSG_TRIP'
                                                        number   = 003
                                                        severity = if_Abap_behv_message=>severity-error
                                                        v1       = |{ trip-uuid }| ) ) TO reported-trip.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_initial_status.
    MODIFY ENTITIES OF ZAK_R_Trip IN LOCAL MODE
      ENTITY Trip
      UPDATE
      FIELDS ( Status )
      WITH VALUE #( FOR key IN keys
                      ( %key   = key-%key
                        Status = zak_if_trip=>co_status-initial ) )
      REPORTED DATA(ls_reported).
  ENDMETHOD.

  METHOD get_instance_features.
    " Get the root node. In a Fiori Elements UI this will be just one entry. But, when being called via EML or as an API,
    "  several instances of Trip can be requested.
    READ ENTITIES OF ZAK_R_Trip IN LOCAL MODE
         ENTITY Trip
         FIELDS ( Status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(trips).

    " Loop the nodes and set the Mandatory field either to read-only or mandatory based on the
    "  value of Status field
    LOOP AT trips INTO DATA(trip).
      APPEND VALUE #(
          %tky            = trip-%tky
          " This is for preventing Status from being set during Create
          %field-Status   = COND #( WHEN trip-status IS INITIAL
                                    THEN if_abap_behv=>fc-f-read_only
                                    ELSE if_abap_behv=>fc-f-unrestricted )

          " This is for preventing Title from being set after Create
          %field-Title    = COND #( WHEN trip-status IS INITIAL
                                    THEN if_abap_behv=>fc-f-mandatory
                                    ELSE if_abap_behv=>fc-f-read_only )

          " This is for disabling the edit of header fields, for a Reimbursed trip
          %update         = COND #( WHEN trip-status = zak_if_trip=>co_status-reimbursed OR trip-status = zak_if_trip=>co_status-cancelled OR trip-status = zak_if_trip=>co_status-accepted
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

          " This is for disabling the create button of child nodes, for a Reimbursed trip
          %assoc-_Expense = COND #( WHEN trip-status = zak_if_trip=>co_status-reimbursed OR trip-status = zak_if_trip=>co_status-cancelled OR trip-status = zak_if_trip=>co_status-accepted
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

          " This is for disabling the draft edit button, for a Reimbursed trip
          %action-Edit    = COND #( WHEN trip-status = zak_if_trip=>co_status-reimbursed OR trip-status = zak_if_trip=>co_status-cancelled OR trip-status = zak_if_trip=>co_status-accepted
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

          " This is for disabling the delete for a Reimbursed trip
          %delete         = COND #( WHEN trip-status = zak_if_trip=>co_status-reimbursed OR trip-status = zak_if_trip=>co_status-accepted
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled ) )
             TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
