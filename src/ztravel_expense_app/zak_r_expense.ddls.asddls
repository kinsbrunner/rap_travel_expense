@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZAK_R_EXPENSE
  as select from ZAK_EXPENSE as Expense
  association to parent ZAK_R_TRIP as _Trip on $projection.ParentUuid = _Trip.Uuid
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  transaction_type as TransactionType,
  category as Category,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency as Currency,
  @Semantics.amount.currencyCode: 'Currency'
  price as Price,
  description as Description,
  expense_date as ExpenseDate,
  ticket_image as TicketImage,
  _Trip
}
