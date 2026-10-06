@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

@ObjectModel.sapObjectNodeType.name: 'ZAK_Trip'

define root view entity ZAK_R_TRIP
  as select from zak_trip as Trip

  composition [1..*] of ZAK_R_EXPENSE as _Expense
  association [1..1] to ZAK_I_TripType_VH as _TripType on Trip.trip_type = _TripType.TripTypeCode
  association [1..1] to ZAK_I_Status_VH as _Status on Trip.status = _Status.StatusCode
  
{
  key uuid                  as UUID,

      title                 as Title,
      trip_type             as TripType,
      status                as Status,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_CurrencyStdVH', element: 'Currency' },
                                            useForValidation: true } ]
      currency              as Currency,

      @Semantics.amount.currencyCode: 'Currency'
      total                 as Total,

      start_date            as StartDate,
      end_date              as EndDate,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Expense,
      _TripType,
      _Status
}
