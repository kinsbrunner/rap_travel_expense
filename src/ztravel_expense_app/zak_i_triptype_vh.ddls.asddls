@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Trip Type value help'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZAK_I_TripType_VH
  as select from    zak_triptype   as types

    left outer join zak_triptype_t as texts
      on  texts.trip_type = types.trip_type
      and texts.langu     = $session.system_language

{
      @ObjectModel.text.element: [ 'TripTypeText' ]
  key types.trip_type   as TripTypeCode,

      @Semantics.text: true
      texts.description as TripTypeText
}
