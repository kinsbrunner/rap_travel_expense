INTERFACE zak_if_trip
  PUBLIC.

  CONSTANTS: BEGIN OF co_status,
               initial    TYPE zak_status VALUE '10',
               awaiting   TYPE zak_status VALUE '20',
               accepted   TYPE zak_status VALUE '30',
               rejected   TYPE zak_status VALUE '40',
               reimbursed TYPE zak_status VALUE '50',
               cancelled  TYPE zak_status VALUE '60',
             END OF co_status.

ENDINTERFACE.
