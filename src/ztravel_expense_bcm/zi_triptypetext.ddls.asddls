@EndUserText.label: 'Trip Type text'
@AccessControl.authorizationCheck: #MANDATORY
@ObjectModel.dataCategory: #TEXT
define view entity ZI_TripTypeText
  as select from ZAK_TRIPTYPE_T
  association [1..1] to ZI_TripTypeTable_S as _TripTypeTableAll on $projection.SingletonID = _TripTypeTableAll.SingletonID
  association to parent ZI_TripType as _TripType on $projection.TripType = _TripType.TripType
  association [0..*] to I_LanguageText as _LanguageText on $projection.Langu = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key LANGU as Langu,
  key TRIP_TYPE as TripType,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _TripTypeTableAll,
  _TripType,
  _LanguageText
}
