@EndUserText.label: 'Maintain Trip Type table Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: {
  headerInfo: {
    typeName: 'TripTypeTableAll'
  }
}
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity ZC_TripTypeTable_S
  provider contract TRANSACTIONAL_QUERY
  as projection on ZI_TripTypeTable_S
{
  @UI.facet: [ {
    id: 'TripType', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Trip Type', 
    position: 1 , 
    targetElement: '_TripType'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key SingletonID,
  @UI.hidden: true
  LastChangedAtMax,
  @ObjectModel.text.element: [ 'TransportRequestDescription' ]
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  TransportRequestID,
  @UI.hidden: true
  _ABAPTransportRequestText.TransportRequestDescription : localized,
  _TripType : redirected to composition child ZC_TripType
}
