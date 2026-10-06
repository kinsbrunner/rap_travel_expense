@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Trip Type value help'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZAK_I_TripType_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE(
                   p_domain_name : 'ZAK_TRIP_TYPE') as values

    inner join   DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                   p_domain_name : 'ZAK_TRIP_TYPE') as texts
      on  values.domain_name = texts.domain_name
      and values.value_low   = texts.value_low
      and texts.language     = $session.system_language

{
      @ObjectModel.text.element: [ 'TripTypeText' ]
  key values.value_low as TripTypeCode,

      texts.text       as TripTypeText
}
