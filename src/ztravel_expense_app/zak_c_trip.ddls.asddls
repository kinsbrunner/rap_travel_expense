@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZAK_Trip'
}
@OData.entityType.name: 'Trip_Type'
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZAK_C_TRIP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZAK_R_TRIP
  association [1..1] to ZAK_R_TRIP as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  Title,
  TripType,
  Status,
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
  Total,
  StartDate,
  EndDate,
  @Semantics: {
    User.Createdby: true
  }
  LocalCreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  LocalCreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _Expense : redirected to composition child ZAK_C_EXPENSE,
  _BaseEntity
}
