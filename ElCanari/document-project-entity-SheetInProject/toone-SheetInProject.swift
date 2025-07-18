//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    ReadOnlyObject_SheetInProject
//--------------------------------------------------------------------------------------------------

class ReadOnlyObject_SheetInProject : EBReadOnlyAbstractObjectProperty <SheetInProject> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func notifyModelDidChangeFrom (oldValue inOldValue : SheetInProject?) {
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  //--- Remove observers from removed objects
    if let oldValue = inOldValue {
      oldValue.mSheetTitle_property.stopsBeingObserved (by: self.mSheetTitle_property) // Stored property
      oldValue.schematicIssues_property.stopsBeingObserved (by: self.schematicIssues_property) // Transient property
      oldValue.issues_property.stopsBeingObserved (by: self.issues_property) // Transient property
      oldValue.connectedPoints_property.stopsBeingObserved (by: self.connectedPoints_property) // Transient property
      oldValue.schematicConnexionWarnings_property.stopsBeingObserved (by: self.schematicConnexionWarnings_property) // Transient property
      oldValue.schematicConnexionErrors_property.stopsBeingObserved (by: self.schematicConnexionErrors_property) // Transient property
      oldValue.sheetDescriptor_property.stopsBeingObserved (by: self.sheetDescriptor_property) // Transient property
      if let relay = self.mObserversOf_mObjects { // to Many
        oldValue.mObjects_property.stopsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_mPoints { // to Many
        oldValue.mPoints_property.stopsBeingObserved (by: relay)
      }
    }
  //--- Add observers to added objects
    if let newValue = self.mWeakInternalValue {
      newValue.mSheetTitle_property.startsBeingObserved (by: self.mSheetTitle_property) // Stored property
      newValue.schematicIssues_property.startsBeingObserved (by: self.schematicIssues_property) // Transient property
      newValue.issues_property.startsBeingObserved (by: self.issues_property) // Transient property
      newValue.connectedPoints_property.startsBeingObserved (by: self.connectedPoints_property) // Transient property
      newValue.schematicConnexionWarnings_property.startsBeingObserved (by: self.schematicConnexionWarnings_property) // Transient property
      newValue.schematicConnexionErrors_property.startsBeingObserved (by: self.schematicConnexionErrors_property) // Transient property
      newValue.sheetDescriptor_property.startsBeingObserved (by: self.sheetDescriptor_property) // Transient property
      if let relay = self.mObserversOf_mObjects { // to Many
        newValue.mObjects_property.startsBeingObserved (by: relay)
      }
      if let relay = self.mObserversOf_mPoints { // to Many
        newValue.mPoints_property.startsBeingObserved (by: relay)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'mSheetTitle' stored property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let mSheetTitle_property = EBTransientProperty <String?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'schematicIssues' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let schematicIssues_property = EBTransientProperty <GraphicViewTooltipArray?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'issues' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let issues_property = EBTransientProperty <CanariIssueArray?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'connectedPoints' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let connectedPoints_property = EBTransientProperty <EBShape?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'schematicConnexionWarnings' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let schematicConnexionWarnings_property = EBTransientProperty <Int?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'schematicConnexionErrors' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let schematicConnexionErrors_property = EBTransientProperty <Int?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observers of 'sheetDescriptor' transient property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final let sheetDescriptor_property = EBTransientProperty <SchematicSheetDescriptor?> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observable toMany property: mObjects
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mObjects : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mObjects_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mObjects {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.mWeakInternalValue?.mObjects_property.startsBeingObserved (by: relay)
      self.mObserversOf_mObjects = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mObjects_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mObjects?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Observable toMany property: mPoints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mPoints : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mPoints_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mPoints {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.mWeakInternalValue?.mPoints_property.startsBeingObserved (by: relay)
      self.mObserversOf_mPoints = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mPoints_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mPoints?.stopsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
  //--- Configure mSheetTitle simple stored property
    self.mSheetTitle_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.mSheetTitle_property.optionalSelection ?? .single (nil)
    }
  //--- Configure schematicIssues transient property
    self.schematicIssues_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.schematicIssues_property.optionalSelection ?? .single (nil)
    }
  //--- Configure issues transient property
    self.issues_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.issues_property.optionalSelection ?? .single (nil)
    }
  //--- Configure connectedPoints transient property
    self.connectedPoints_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.connectedPoints_property.optionalSelection ?? .single (nil)
    }
  //--- Configure schematicConnexionWarnings transient property
    self.schematicConnexionWarnings_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.schematicConnexionWarnings_property.optionalSelection ?? .single (nil)
    }
  //--- Configure schematicConnexionErrors transient property
    self.schematicConnexionErrors_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.schematicConnexionErrors_property.optionalSelection ?? .single (nil)
    }
  //--- Configure sheetDescriptor transient property
    self.sheetDescriptor_property.mReadModelFunction = { [weak self] in
      return self?.mWeakInternalValue?.sheetDescriptor_property.optionalSelection ?? .single (nil)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    StoredObject_SheetInProject
//--------------------------------------------------------------------------------------------------

final class StoredObject_SheetInProject : ReadOnlyObject_SheetInProject, EBSignatureObserverProtocol, EBDocumentStorablePropertyAndRelationshipProtocol {

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (usedForSignature inUsedForSignature : Bool, strongRef inStrongReference : Bool, key inKey : String) {
    self.mUsedForSignature = inUsedForSignature
    self.mIsStrongReference = inStrongReference
    self.mKey = inKey
    super.init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mKey : String
  var key : String { return self.mKey }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func initialize (fromValueDictionary inDictionary : [String : Any],
                   managedObjectArray inManagedObjectArray : [EBManagedObject]) {
    if let objectSavingIndex = inDictionary [self.mKey] as? Int {
      let object = inManagedObjectArray [objectSavingIndex] as! SheetInProject
      self.setProp (object)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inRawObjectArray : [RawObject]) {
    if let idx = inData.base62EncodedInt (range: inRange) {
      let object = inRawObjectArray [idx].object as! SheetInProject
      self.setProp (object)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func store (inDictionary ioDictionary : inout [String : Any]) {
    if let idx = self.mWeakInternalValue?.savingIndex {
      ioDictionary [self.mKey] = idx
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enterRelationshipObjects (intoArray ioArray : inout [EBManagedObject]) {
    if let object = self.mWeakInternalValue {
      ioArray.append (object)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendValueTo (data ioData : inout Data) {
    if let object = self.propval {
      ioData.append (base62Encoded: object.savingIndex)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Signature ?
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mUsedForSignature : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Undo manager
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  weak var undoManager : UndoManager? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Opposite relationship management
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSetOppositeRelationship : Optional < (_ inManagedObject : SheetInProject) -> Void > = nil
  private var mResetOppositeRelationship : Optional < (_ inManagedObject : SheetInProject) -> Void > = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : SheetInProject) -> Void,
                                         resetter inResetter : @escaping (_ inManagedObject : SheetInProject) -> Void) {
    self.mSetOppositeRelationship = inSetter
    self.mResetOppositeRelationship = inResetter
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Model will change
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func notifyModelDidChangeFrom (oldValue inOldValue : SheetInProject?) {
  //--- Register old value in undo manager
    self.undoManager?.registerUndo (withTarget: self) { selfTarget in
      selfTarget.setProp (inOldValue) // Ok in Swift 6.2
      // MainActor.assumeIsolated { selfTarget.setProp (inOldValue) }
    }
  //---
    if let object = inOldValue {
      if self.mUsedForSignature {
        object.setSignatureObserver (observer: nil)
      }
      self.mResetOppositeRelationship? (object)
    }
  //---
    if let object = self.mWeakInternalValue {
      if self.mUsedForSignature {
        object.setSignatureObserver (observer: self)
      }
      self.mSetOppositeRelationship? (object)
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
    self.clearSignatureCache ()
  //---
    super.notifyModelDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var selection : EBSelection < SheetInProject? > {
    if let object = self.mWeakInternalValue {
      return .single (object)
    }else{
      return .empty
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var propval : SheetInProject? { return self.mWeakInternalValue }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   setProp
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mIsStrongReference : Bool
  private var mStrongInternalValue : EBManagedObject? = nil // Only used for retaining

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setProp (_ inValue : SheetInProject?) {
    self.mWeakInternalValue = inValue
    if self.mIsStrongReference {
      self.mStrongInternalValue = inValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   signature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mSignatureObserver : (any EBSignatureObserverProtocol)? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSignatureCache : UInt32? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setSignatureObserver (observer inObserver : (any EBSignatureObserverProtocol)?) {
    self.mSignatureObserver?.clearSignatureCache ()
    self.mSignatureObserver = inObserver
    inObserver?.clearSignatureCache ()
    self.clearSignatureCache ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func signature () -> UInt32 {
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
    if let object = self.mWeakInternalValue {
      crc.accumulate (u32: object.signature ())
    }
    return crc
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func clearSignatureCache () {
    if self.mSignatureCache != nil {
      self.mSignatureCache = nil
      self.mSignatureObserver?.clearSignatureCache ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

