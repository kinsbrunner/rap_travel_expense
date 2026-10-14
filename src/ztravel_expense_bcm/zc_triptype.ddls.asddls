@EndUserText.label: 'Maintain Trip Type'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZC_TripType
  as projection on ZI_TripType
{
  key TripType,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _TripTypeTableAll : redirected to parent ZC_TripTypeTable_S,
  _TripTypeText : redirected to composition child ZC_TripTypeText,
  _TripTypeText.Description : localized
}
