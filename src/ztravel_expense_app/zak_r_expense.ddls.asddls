@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define view entity ZAK_R_EXPENSE
  as select from zak_expense as Expense

  association to parent ZAK_R_TRIP as _Trip on $projection.ParentUUID = _Trip.UUID
  association [1..1] to ZAK_I_Category_VH as _Category on Expense.category = _Category.CategoryCode
  association [1..1] to ZAK_I_TransactionType_VH as _TType on Expense.transaction_type = _TType.TransactionTypeCode

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

      _Trip,
      _Category,
      _TType
}
