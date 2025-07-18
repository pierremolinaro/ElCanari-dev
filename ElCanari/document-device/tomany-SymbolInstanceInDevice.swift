//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    ReadOnlyArrayOf_SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

class ReadOnlyArrayOf_SymbolInstanceInDevice : EBReadOnlyAbstractArrayProperty <SymbolInstanceInDevice> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <SymbolInstanceInDevice>,                            
                                 addedSet inAddedSet : EBReferenceSet <SymbolInstanceInDevice>) {
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
  //--- Remove observers from removed objects
    for managedObject in inRemovedSet.values {
      if let relay = self.mObserversOf_mInstanceName { // Stored property
        managedObject.mInstanceName_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_mX { // Stored property
        managedObject.mX_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_mY { // Stored property
        managedObject.mY_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_symbolQualifiedName { // Transient property
        managedObject.symbolQualifiedName_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_symbolTypeName { // Transient property
        managedObject.symbolTypeName_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_pinSymbolQualifiedNames { // Transient property
        managedObject.pinSymbolQualifiedNames_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_unconnectedPins { // Transient property
        managedObject.unconnectedPins_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_objectDisplay { // Transient property
        managedObject.objectDisplay_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_selectionDisplay { // Transient property
        managedObject.selectionDisplay_property.stopsBeingObserved (by: relay)
      }
    }
  //--- Add observers to added objects
    for managedObject in inAddedSet.values {
      if let relay = self.mObserversOf_mInstanceName { // Stored property
        managedObject.mInstanceName_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_mX { // Stored property
        managedObject.mX_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_mY { // Stored property
        managedObject.mY_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_symbolQualifiedName { // Transient property
        managedObject.symbolQualifiedName_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_symbolTypeName { // Transient property
        managedObject.symbolTypeName_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_pinSymbolQualifiedNames { // Transient property
        managedObject.pinSymbolQualifiedNames_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_unconnectedPins { // Transient property
        managedObject.unconnectedPins_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_objectDisplay { // Transient property
        managedObject.objectDisplay_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_selectionDisplay { // Transient property
        managedObject.selectionDisplay_property.startsBeingObserved (by: relay)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'mInstanceName' stored property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mInstanceName : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mInstanceName_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mInstanceName {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.mInstanceName_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_mInstanceName = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mInstanceName_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mInstanceName?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'mX' stored property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mX : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mX_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mX {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.mX_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_mX = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mX_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mX?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'mY' stored property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mY : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mY_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mY {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.mY_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_mY = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mY_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mY?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'symbolQualifiedName' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_symbolQualifiedName : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_symbolQualifiedName_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_symbolQualifiedName {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.symbolQualifiedName_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_symbolQualifiedName = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_symbolQualifiedName_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_symbolQualifiedName?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'symbolTypeName' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_symbolTypeName : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_symbolTypeName_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_symbolTypeName {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.symbolTypeName_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_symbolTypeName = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_symbolTypeName_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_symbolTypeName?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'pinSymbolQualifiedNames' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_pinSymbolQualifiedNames : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_pinSymbolQualifiedNames_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_pinSymbolQualifiedNames {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.pinSymbolQualifiedNames_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_pinSymbolQualifiedNames = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_pinSymbolQualifiedNames_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_pinSymbolQualifiedNames?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'unconnectedPins' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_unconnectedPins : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_unconnectedPins_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_unconnectedPins {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.unconnectedPins_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_unconnectedPins = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_unconnectedPins_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_unconnectedPins?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'objectDisplay' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_objectDisplay : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_objectDisplay_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_objectDisplay {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.objectDisplay_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_objectDisplay = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_objectDisplay_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_objectDisplay?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'selectionDisplay' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_selectionDisplay : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_selectionDisplay_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_selectionDisplay {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.selectionDisplay_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_selectionDisplay = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_selectionDisplay_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_selectionDisplay?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    TransientArrayOf SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

// TransientArrayOf_SymbolInstanceInDevice is useless.

//--------------------------------------------------------------------------------------------------
//    TransientArrayOfSuperOf SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

// TransientArrayOfSuperOf_SymbolInstanceInDevice is useless.

//--------------------------------------------------------------------------------------------------
//    To many relationship read write: SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

class ReadWriteArrayOf_SymbolInstanceInDevice : ReadOnlyArrayOf_SymbolInstanceInDevice {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setProp (_ value :  EBReferenceArray <SymbolInstanceInDevice>) { } // Abstract method

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    Proxy: ProxyArrayOf_SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

// ProxyArrayOf_SymbolInstanceInDevice is useless.

//--------------------------------------------------------------------------------------------------
//    StandAlone Array: SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

class StandAloneArrayOf_SymbolInstanceInDevice : ReadWriteArrayOf_SymbolInstanceInDevice { // , EBSignatureObserverProtocol, EBDocumentStorablePropertyAndRelationshipProtocol, Sendable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override init () {
    self.mUsedForSignature = false
    self.mKey = ""
    super.init ()
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
/*  private final let mKey : String
  final var key : String { return self.mKey } */
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  func initialize (fromValueDictionary inDictionary : [String : Any],
                   managedObjectArray inManagedObjectArray : [EBManagedObject]) {
    if let objectSavingIndexArray = inDictionary [self.mKey] as? [Int] {
      var objectArray = EBReferenceArray <SymbolInstanceInDevice> ()
      for idx in objectSavingIndexArray {
        objectArray.append (inManagedObjectArray [idx] as! SymbolInstanceInDevice)
      }
      self.setProp (objectArray)
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inRawObjectArray : [RawObject]) {
    var objectArray = EBReferenceArray <SymbolInstanceInDevice> ()
    let indexArray = inData.base62EncodedIntArray (fromRange: inRange)
    for idx in indexArray {
      objectArray.append (inRawObjectArray [idx].object as! SymbolInstanceInDevice)
    }
    self.setProp (objectArray)
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  func store (inDictionary ioDictionary : inout [String : Any]) {
    if self.mInternalArrayValue.count > 0 {
      var array = [Int] ()
      for object in self.mInternalArrayValue.values {
        array.append (object.savingIndex)
      }
      ioDictionary [self.mKey] = array
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  func enterRelationshipObjects (intoArray ioArray : inout [EBManagedObject]) {
    if self.mInternalArrayValue.count > 0 {
      for object in self.mInternalArrayValue.values {
        ioArray.append (object)
      }
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  func appendValueTo (data ioData : inout Data) {
    enterToManyRelationshipObjectIndexes (from: self.propval.values, into: &ioData)
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Signature ?
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final private let mUsedForSignature : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Undo manager
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  weak final var undoManager : UndoManager? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Opposite relationship management
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mSetOppositeRelationship : Optional < (_ inManagedObject : SymbolInstanceInDevice) -> Void > = nil
  private final var mResetOppositeRelationship : Optional < (_ inManagedObject : SymbolInstanceInDevice) -> Void > = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : SymbolInstanceInDevice) -> Void,
                                               resetter inResetter : @escaping (_ inManagedObject : SymbolInstanceInDevice) -> Void) {
    self.mSetOppositeRelationship = inSetter
    self.mResetOppositeRelationship = inResetter
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Model will change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func notifyModelDidChangeFrom (oldValue inOldValue : EBReferenceArray <SymbolInstanceInDevice>) {
  //--- Register old value in undo manager
    self.undoManager?.registerUndo (withTarget: self) { selfTarget in
      selfTarget.setProp (inOldValue) // Ok in Swift 6.2
      // MainActor.assumeIsolated { selfTarget.setProp (inOldValue) }
    }
  //---
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Model did change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func notifyModelDidChange () {
  //--- Notify observers
    self.observedObjectDidChange ()
  //---
    super.notifyModelDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Update observers
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <SymbolInstanceInDevice>,
                                 addedSet inAddedSet : EBReferenceSet <SymbolInstanceInDevice>) {
    for managedObject in inRemovedSet.values {
      self.mResetOppositeRelationship? (managedObject)
    }
    for managedObject in inAddedSet.values {
      self.mSetOppositeRelationship? (managedObject)
    }
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final var selection : EBSelection < [SymbolInstanceInDevice] > {
    return .single (self.mInternalArrayValue.values)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func setProp (_ inValue : EBReferenceArray <SymbolInstanceInDevice>) {
    self.mInternalArrayValue = inValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override var propval : EBReferenceArray <SymbolInstanceInDevice> {
    return self.mInternalArrayValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func remove (_ inObject : SymbolInstanceInDevice) {
    if let idx = self.mInternalArrayValue.firstIndex (of: inObject) {
      self.mInternalArrayValue.remove (at: idx)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func add (_ inObject : SymbolInstanceInDevice) {
    if !self.internalSetValue.contains (inObject) {
      self.mInternalArrayValue.append (inObject)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   signature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private weak final var mSignatureObserver : (any EBSignatureObserverProtocol)? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 // private final var mSignatureCache : UInt32? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func setSignatureObserver (observer inObserver : (any EBSignatureObserverProtocol)?) {
    self.mSignatureObserver?.clearSignatureCache ()
    self.mSignatureObserver = inObserver
    inObserver?.clearSignatureCache ()
    self.clearSignatureCache ()
 } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func signature () -> UInt32 {
    let computedSignature : UInt32
    if let s = self.mSignatureCache {
      computedSignature = s
    }else{
      computedSignature = self.computeSignature ()
      self.mSignatureCache = computedSignature
    }
    return computedSignature
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final private func computeSignature () -> UInt32 {
    var crc : UInt32 = 0
    for object in self.mInternalArrayValue.values {
      crc.accumulate (u32: object.signature ())
    }
    return crc
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func clearSignatureCache () {
    if self.mSignatureCache != nil {
      self.mSignatureCache = nil
      self.mSignatureObserver?.clearSignatureCache ()
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    Stored Array: SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

class StoredArrayOf_SymbolInstanceInDevice : StandAloneArrayOf_SymbolInstanceInDevice, EBSignatureObserverProtocol, EBDocumentStorablePropertyAndRelationshipProtocol, Sendable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (usedForSignature inUsedForSignature : Bool, key inKey : String) {
    self.mUsedForSignature = inUsedForSignature
    self.key = inKey
    super.init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  final let key : String
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func initialize (fromValueDictionary inDictionary : [String : Any],
                   managedObjectArray inManagedObjectArray : [EBManagedObject]) {
    if let objectSavingIndexArray = inDictionary [self.key] as? [Int] {
      var objectArray = EBReferenceArray <SymbolInstanceInDevice> ()
      for idx in objectSavingIndexArray {
        objectArray.append (inManagedObjectArray [idx] as! SymbolInstanceInDevice)
      }
      self.setProp (objectArray)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inRawObjectArray : [RawObject]) {
    var objectArray = EBReferenceArray <SymbolInstanceInDevice> ()
    let indexArray = inData.base62EncodedIntArray (fromRange: inRange)
    for idx in indexArray {
      objectArray.append (inRawObjectArray [idx].object as! SymbolInstanceInDevice)
    }
    self.setProp (objectArray)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func store (inDictionary ioDictionary : inout [String : Any]) {
    if self.mInternalArrayValue.count > 0 {
      var array = [Int] ()
      for object in self.mInternalArrayValue.values {
        array.append (object.savingIndex)
      }
      ioDictionary [self.key] = array
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enterRelationshipObjects (intoArray ioArray : inout [EBManagedObject]) {
    if self.mInternalArrayValue.count > 0 {
      for object in self.mInternalArrayValue.values {
        ioArray.append (object)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendValueTo (data ioData : inout Data) {
    enterToManyRelationshipObjectIndexes (from: self.propval.values, into: &ioData)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Signature ?
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final private let mUsedForSignature : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Undo manager
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  weak final var undoManager : UndoManager? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Opposite relationship management
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private final var mSetOppositeRelationship : Optional < (_ inManagedObject : SymbolInstanceInDevice) -> Void > = nil
//  private final var mResetOppositeRelationship : Optional < (_ inManagedObject : SymbolInstanceInDevice) -> Void > = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : SymbolInstanceInDevice) -> Void,
                                               resetter inResetter : @escaping (_ inManagedObject : SymbolInstanceInDevice) -> Void) {
    self.mSetOppositeRelationship = inSetter
    self.mResetOppositeRelationship = inResetter
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Model will change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override func notifyModelDidChangeFrom (oldValue inOldValue : EBReferenceArray <SymbolInstanceInDevice>) {
  //--- Register old value in undo manager
    self.undoManager?.registerUndo (withTarget: self) { selfTarget in
      selfTarget.setProp (inOldValue) // Ok in Swift 6.2
      // MainActor.assumeIsolated { selfTarget.setProp (inOldValue) }
    }
  //---
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Model did change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override func notifyModelDidChange () {
  //--- Notify observers
    self.observedObjectDidChange ()
  //---
    super.notifyModelDidChange ()
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Update observers
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <SymbolInstanceInDevice>,
                                 addedSet inAddedSet : EBReferenceSet <SymbolInstanceInDevice>) {
    for managedObject in inRemovedSet.values {
      if self.mUsedForSignature {
        managedObject.setSignatureObserver (observer: nil)
      }
   //    self.mResetOppositeRelationship? (managedObject) // Done in super method
    }
    for managedObject in inAddedSet.values {
      if self.mUsedForSignature {
        managedObject.setSignatureObserver (observer: self)
      }
   //   self.mSetOppositeRelationship? (managedObject) // Done in super method
    }
  //---
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
 } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <SymbolInstanceInDevice>,
                                 addedSet inAddedSet : EBReferenceSet <SymbolInstanceInDevice>) {
    if self.mUsedForSignature {
      for managedObject in inRemovedSet.values {
        managedObject.setSignatureObserver (observer: nil)
      }
      for managedObject in inAddedSet.values {
        managedObject.setSignatureObserver (observer: self)
      }
    }
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override final var selection : EBSelection < [SymbolInstanceInDevice] > {
    return .single (self.mInternalArrayValue.values)
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override func setProp (_ inValue : EBReferenceArray <SymbolInstanceInDevice>) {
    self.mInternalArrayValue = inValue
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final override var propval : EBReferenceArray <SymbolInstanceInDevice> {
    return self.mInternalArrayValue
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func remove (_ inObject : SymbolInstanceInDevice) {
    if let idx = self.mInternalArrayValue.firstIndex (of: inObject) {
      self.mInternalArrayValue.remove (at: idx)
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func add (_ inObject : SymbolInstanceInDevice) {
    if !self.internalSetValue.contains (inObject) {
      self.mInternalArrayValue.append (inObject)
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   signature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak final var mSignatureObserver : (any EBSignatureObserverProtocol)? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mSignatureCache : UInt32? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setSignatureObserver (observer inObserver : (any EBSignatureObserverProtocol)?) {
    self.mSignatureObserver?.clearSignatureCache ()
    self.mSignatureObserver = inObserver
    inObserver?.clearSignatureCache ()
    self.clearSignatureCache ()
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func signature () -> UInt32 {
    let computedSignature : UInt32
    if let s = self.mSignatureCache {
      computedSignature = s
    }else{
      computedSignature = self.computeSignature ()
      self.mSignatureCache = computedSignature
    }
    return computedSignature
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final private func computeSignature () -> UInt32 {
    var crc : UInt32 = 0
    for object in self.mInternalArrayValue.values {
      crc.accumulate (u32: object.signature ())
    }
    return crc
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func clearSignatureCache () {
    if self.mSignatureCache != nil {
      self.mSignatureCache = nil
      self.mSignatureObserver?.clearSignatureCache ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    Preferences array: SymbolInstanceInDevice
//--------------------------------------------------------------------------------------------------

// PreferencesArrayOf_SymbolInstanceInDevice is useless.

//--------------------------------------------------------------------------------------------------

