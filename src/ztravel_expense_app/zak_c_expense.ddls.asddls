@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZAK_C_EXPENSE
  as projection on ZAK_R_EXPENSE
  association [1..1] to ZAK_R_EXPENSE as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  TransactionType,
  Category,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
  Currency,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  Price,
  Description,
  ExpenseDate,
  TicketImage,
  _Trip : redirected to parent ZAK_C_TRIP,
  _BaseEntity
}
