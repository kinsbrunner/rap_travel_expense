@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define view entity ZAK_R_EXPENSE
  as select from zak_expense as Expense

  association to parent ZAK_R_TRIP as _Trip on $projection.ParentUUID = _Trip.UUID

{
  key uuid              as UUID,

      parent_uuid       as ParentUUID,
      transaction_type  as TransactionType,
      category          as Category,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_CurrencyStdVH', element: 'Currency' },
                                            useForValidation: true } ]
      currency          as Currency,

      @Semantics.amount.currencyCode: 'Currency'
      price             as Price,

      description       as Description,
      expense_date      as ExpenseDate,
      ticket_attachment as TicketAttachement,
      ticket_mimetype   as TicketMimetype,
      ticket_filename   as TicketFilename,

      _Trip
}
