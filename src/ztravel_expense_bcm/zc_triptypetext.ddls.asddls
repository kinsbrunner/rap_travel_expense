@EndUserText.label: 'Maintain Trip Type text'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZC_TripTypeText
  as projection on ZI_TripTypeText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_LanguageVH', 
      element: 'Language'
    }, 
    useForValidation: true
  } ]
  key Langu,
  key TripType,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _TripType : redirected to parent ZC_TripType,
  _TripTypeTableAll : redirected to ZC_TripTypeTable_S
}
