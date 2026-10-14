@EndUserText.label: 'Trip Type table Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Semantics.valueRange.maximum: '1'
define root view entity ZI_TripTypeTable_S
  as select from I_Language
    left outer join ZAK_TRIPTYPE on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_TripType as _TripType
{
  key 1 as SingletonID,
  _TripType,
  max( ZAK_TRIPTYPE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
