//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    ReadOnlyArrayOf_DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

class ReadOnlyArrayOf_DevicePadAssignmentInProject : EBReadOnlyAbstractArrayProperty <DevicePadAssignmentInProject> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <DevicePadAssignmentInProject>,                            
                                 addedSet inAddedSet : EBReferenceSet <DevicePadAssignmentInProject>) {
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
  //--- Remove observers from removed objects
    for managedObject in inRemovedSet.values {
      if let relay = self.mObserversOf_mPadName { // Stored property
        managedObject.mPadName_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_pinPadAssignment { // Transient property
        managedObject.pinPadAssignment_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_descriptor { // Transient property
        managedObject.descriptor_property.stopsBeingObserved (by: relay)
      }
    }
  //--- Add observers to added objects
    for managedObject in inAddedSet.values {
      if let relay = self.mObserversOf_mPadName { // Stored property
        managedObject.mPadName_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_pinPadAssignment { // Transient property
        managedObject.pinPadAssignment_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_descriptor { // Transient property
        managedObject.descriptor_property.startsBeingObserved (by: relay)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'mPadName' stored property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mPadName : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mPadName_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mPadName {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.mPadName_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_mPadName = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mPadName_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mPadName?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'pinPadAssignment' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_pinPadAssignment : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_pinPadAssignment_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_pinPadAssignment {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.pinPadAssignment_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_pinPadAssignment = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_pinPadAssignment_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_pinPadAssignment?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'descriptor' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_descriptor : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_descriptor_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_descriptor {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.descriptor_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_descriptor = relay
    }
    relay.startsBeingObserved (by:  inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_descriptor_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_descriptor?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    TransientArrayOf DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

// TransientArrayOf_DevicePadAssignmentInProject is useless.

//--------------------------------------------------------------------------------------------------
//    TransientArrayOfSuperOf DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

// TransientArrayOfSuperOf_DevicePadAssignmentInProject is useless.

//--------------------------------------------------------------------------------------------------
//    To many relationship read write: DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

class ReadWriteArrayOf_DevicePadAssignmentInProject : ReadOnlyArrayOf_DevicePadAssignmentInProject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setProp (_ value :  EBReferenceArray <DevicePadAssignmentInProject>) { } // Abstract method

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    Proxy: ProxyArrayOf_DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

// ProxyArrayOf_DevicePadAssignmentInProject is useless.

//--------------------------------------------------------------------------------------------------
//    StandAlone Array: DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

class StandAloneArrayOf_DevicePadAssignmentInProject : ReadWriteArrayOf_DevicePadAssignmentInProject { // , EBSignatureObserverProtocol, EBDocumentStorablePropertyAndRelationshipProtocol, Sendable {

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
      var objectArray = EBReferenceArray <DevicePadAssignmentInProject> ()
      for idx in objectSavingIndexArray {
        objectArray.append (inManagedObjectArray [idx] as! DevicePadAssignmentInProject)
      }
      self.setProp (objectArray)
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inRawObjectArray : [RawObject]) {
    var objectArray = EBReferenceArray <DevicePadAssignmentInProject> ()
    let indexArray = inData.base62EncodedIntArray (fromRange: inRange)
    for idx in indexArray {
      objectArray.append (inRawObjectArray [idx].object as! DevicePadAssignmentInProject)
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
  // Model will change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func notifyModelDidChangeFrom (oldValue inOldValue : EBReferenceArray <DevicePadAssignmentInProject>) {
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


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final var selection : EBSelection < [DevicePadAssignmentInProject] > {
    return .single (self.mInternalArrayValue.values)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func setProp (_ inValue : EBReferenceArray <DevicePadAssignmentInProject>) {
    self.mInternalArrayValue = inValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override var propval : EBReferenceArray <DevicePadAssignmentInProject> {
    return self.mInternalArrayValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func remove (_ inObject : DevicePadAssignmentInProject) {
    if let idx = self.mInternalArrayValue.firstIndex (of: inObject) {
      self.mInternalArrayValue.remove (at: idx)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func add (_ inObject : DevicePadAssignmentInProject) {
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
//    Stored Array: DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

class StoredArrayOf_DevicePadAssignmentInProject : StandAloneArrayOf_DevicePadAssignmentInProject, EBSignatureObserverProtocol, EBDocumentStorablePropertyAndRelationshipProtocol, Sendable {

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
      var objectArray = EBReferenceArray <DevicePadAssignmentInProject> ()
      for idx in objectSavingIndexArray {
        objectArray.append (inManagedObjectArray [idx] as! DevicePadAssignmentInProject)
      }
      self.setProp (objectArray)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inRawObjectArray : [RawObject]) {
    var objectArray = EBReferenceArray <DevicePadAssignmentInProject> ()
    let indexArray = inData.base62EncodedIntArray (fromRange: inRange)
    for idx in indexArray {
      objectArray.append (inRawObjectArray [idx].object as! DevicePadAssignmentInProject)
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
  // Model will change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override func notifyModelDidChangeFrom (oldValue inOldValue : EBReferenceArray <DevicePadAssignmentInProject>) {
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

/*  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <DevicePadAssignmentInProject>,
                                 addedSet inAddedSet : EBReferenceSet <DevicePadAssignmentInProject>) {
    for managedObject in inRemovedSet.values {
      if self.mUsedForSignature {
        managedObject.setSignatureObserver (observer: nil)
      }
    }
    for managedObject in inAddedSet.values {
      if self.mUsedForSignature {
        managedObject.setSignatureObserver (observer: self)
      }
    }
  //---
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
 } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <DevicePadAssignmentInProject>,
                                 addedSet inAddedSet : EBReferenceSet <DevicePadAssignmentInProject>) {
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

/*  override final var selection : EBSelection < [DevicePadAssignmentInProject] > {
    return .single (self.mInternalArrayValue.values)
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  override func setProp (_ inValue : EBReferenceArray <DevicePadAssignmentInProject>) {
    self.mInternalArrayValue = inValue
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final override var propval : EBReferenceArray <DevicePadAssignmentInProject> {
    return self.mInternalArrayValue
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func remove (_ inObject : DevicePadAssignmentInProject) {
    if let idx = self.mInternalArrayValue.firstIndex (of: inObject) {
      self.mInternalArrayValue.remove (at: idx)
    }
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*  final func add (_ inObject : DevicePadAssignmentInProject) {
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
//    Preferences array: DevicePadAssignmentInProject
//--------------------------------------------------------------------------------------------------

// PreferencesArrayOf_DevicePadAssignmentInProject is useless.

//--------------------------------------------------------------------------------------------------

