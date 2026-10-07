@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: 'Expenses'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define view entity ZAK_C_EXPENSE
  as projection on ZAK_R_EXPENSE

  association [1..1] to ZAK_R_EXPENSE as _BaseEntity on $projection.UUID = _BaseEntity.UUID

{
  key UUID,

      ParentUUID,

      @ObjectModel.text.element: ['TransactionTypeText'] 
      @Consumption.valueHelpDefinition: [ { entity: { element: 'TransactionTypeCode', name: 'ZAK_I_TransactionType_VH' },
                                            useForValidation: true } ]
      TransactionType,
      _TType.TransactionTypeText as TransactionTypeText,
      
      @ObjectModel.text.element: ['CategoryText'] 
      @Consumption.valueHelpDefinition: [ { entity: { element: 'CategoryCode', name: 'ZAK_I_Category_VH' },
                                            useForValidation: true } ]
      Category,
      _Category.CategoryText as CategoryText,

      @Consumption.valueHelpDefinition: [ { entity: { element: 'Currency', name: 'I_CurrencyStdVH' },
                                            useForValidation: true } ]
      Currency,

      @Semantics.amount.currencyCode: 'Currency'
      Price,

      Description,
      ExpenseDate,

      @Semantics.largeObject: { mimeType: 'TicketMimeType',
                                fileName: 'TicketFilename',
                                acceptableMimeTypes: [ 'image/*' ],
                                contentDispositionPreference: #ATTACHMENT }
      TicketAttachement,

      @Semantics.mimeType: true
      TicketMimetype,

      TicketFilename,
      _Trip : redirected to parent ZAK_C_TRIP,

      _BaseEntity
}
