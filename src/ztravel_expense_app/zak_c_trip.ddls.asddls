@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

@OData.entityType.name: 'Trip_Type'

@ObjectModel.sapObjectNodeType.name: 'ZAK_Trip'

define root view entity ZAK_C_TRIP
  provider contract transactional_query
  as projection on ZAK_R_TRIP

  association [1..1] to ZAK_R_TRIP as _BaseEntity on $projection.UUID = _BaseEntity.UUID

{
  key UUID,

      Title,
      @ObjectModel.text.element: ['TripTypeText'] 
      @Consumption.valueHelpDefinition: [ { entity: { element: 'TripTypeCode', name: 'ZAK_I_TripType_VH' },
                                            useForValidation: true } ]
      TripType,
      _TripType.TripTypeText as TripTypeText,

      @ObjectModel.text.element: ['StatusText'] 
      @Consumption.valueHelpDefinition: [ { entity: { element: 'StatusCode', name: 'ZAK_I_Status_VH' },
                                            useForValidation: true } ]
      Status,
      _Status.StatusText as StatusText,

      @Consumption.valueHelpDefinition: [ { entity: { element: 'Currency', name: 'I_CurrencyStdVH' },
                                            useForValidation: true } ]
      Currency,

      @Semantics.amount.currencyCode: 'Currency'
      Total,

      StartDate,
      EndDate,

      @Semantics.user.createdBy: true
      LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      _Expense : redirected to composition child ZAK_C_EXPENSE,

      _BaseEntity
}
