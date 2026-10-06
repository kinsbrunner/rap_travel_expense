@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Status value help'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZAK_I_Status_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE(
                   p_domain_name : 'ZAK_STATUS') as values

    inner join   DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                   p_domain_name : 'ZAK_STATUS') as texts
      on  values.domain_name = texts.domain_name
      and values.value_low   = texts.value_low
      and texts.language     = $session.system_language

{
      @ObjectModel.text.element: [ 'StatusText' ]
  key values.value_low as StatusCode,

      texts.text       as StatusText
}
