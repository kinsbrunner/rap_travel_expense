@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Category value help'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZAK_I_Category_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE(
                   p_domain_name : 'ZAK_CATEGORY') as values

    inner join   DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                   p_domain_name : 'ZAK_CATEGORY') as texts
      on  values.domain_name = texts.domain_name
      and values.value_low   = texts.value_low
      and texts.language     = $session.system_language

{
      @ObjectModel.text.element: [ 'CategoryText' ]
  key values.value_low as CategoryCode,

      texts.text       as CategoryText
}
