@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define view entity ZAK_C_EXPENSE
  as projection on ZAK_R_EXPENSE

  association [1..1] to ZAK_R_EXPENSE as _BaseEntity on $projection.UUID = _BaseEntity.UUID

{
  key UUID,

      ParentUUID,
      TransactionType,
      Category,

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
