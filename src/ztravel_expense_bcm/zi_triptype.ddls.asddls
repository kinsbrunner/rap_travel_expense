@EndUserText.label: 'Trip Type'
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZI_TripType
  as select from ZAK_TRIPTYPE
  association to parent ZI_TripTypeTable_S as _TripTypeTableAll on $projection.SingletonID = _TripTypeTableAll.SingletonID
  composition [0..*] of ZI_TripTypeText as _TripTypeText
{
  key TRIP_TYPE as TripType,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _TripTypeTableAll,
  _TripTypeText
}
