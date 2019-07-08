//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadOnlyArrayOf_PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadOnlyArrayOf_PadRepresentant : ReadOnlyAbstractArrayProperty <PadRepresentant> {

  //····················································································································

  internal override func updateObservers (removedSet inRemovedSet : Set <PadRepresentant>, addedSet inAddedSet : Set <PadRepresentant>) {
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
  //--- Remove observers from removed objects
    self.removeEBObserversOf_mComponentPadName_fromElementsOfSet (inRemovedSet) // Stored property
    self.removeEBObserversOf_mPadIndex_fromElementsOfSet (inRemovedSet) // Stored property
    self.removeEBObserversOf_side_fromElementsOfSet (inRemovedSet) // Transient property
    self.removeEBObserversOf_issues_fromElementsOfSet (inRemovedSet) // Transient property
  //--- Add observers to added objects
    self.addEBObserversOf_mComponentPadName_toElementsOfSet (inAddedSet) // Stored property
    self.addEBObserversOf_mPadIndex_toElementsOfSet (inAddedSet) // Stored property
    self.addEBObserversOf_side_toElementsOfSet (inAddedSet) // Transient property
    self.addEBObserversOf_issues_toElementsOfSet (inAddedSet) // Transient property
  }

  //····················································································································
  //   Observers of 'mComponentPadName' stored property
  //····················································································································

  private var mObserversOf_mComponentPadName = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_mComponentPadName (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_mComponentPadName.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.mComponentPadName_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_mComponentPadName (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_mComponentPadName.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.mComponentPadName_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_mComponentPadName_toElementsOfSet (_ inSet : Set<PadRepresentant>) {
    for managedObject in inSet {
      self.mObserversOf_mComponentPadName.apply { (_ observer : EBEvent) in
        managedObject.mComponentPadName_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_mComponentPadName_fromElementsOfSet (_ inSet : Set<PadRepresentant>) {
    self.mObserversOf_mComponentPadName.apply { (_ observer : EBEvent) in
      observer.postEvent ()
      for managedObject in inSet {
        managedObject.mComponentPadName_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'mPadIndex' stored property
  //····················································································································

  private var mObserversOf_mPadIndex = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_mPadIndex (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_mPadIndex.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.mPadIndex_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_mPadIndex (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_mPadIndex.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.mPadIndex_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_mPadIndex_toElementsOfSet (_ inSet : Set<PadRepresentant>) {
    for managedObject in inSet {
      self.mObserversOf_mPadIndex.apply { (_ observer : EBEvent) in
        managedObject.mPadIndex_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_mPadIndex_fromElementsOfSet (_ inSet : Set<PadRepresentant>) {
    self.mObserversOf_mPadIndex.apply { (_ observer : EBEvent) in
      observer.postEvent ()
      for managedObject in inSet {
        managedObject.mPadIndex_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'side' transient property
  //····················································································································

  private var mObserversOf_side = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_side (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_side.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.side_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_side (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_side.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.side_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_side_toElementsOfSet (_ inSet : Set<PadRepresentant>) {
    for managedObject in inSet {
      self.mObserversOf_side.apply { (_ observer : EBEvent) in
        managedObject.side_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_side_fromElementsOfSet (_ inSet : Set<PadRepresentant>) {
    for managedObject in inSet {
      self.mObserversOf_side.apply { (_ observer : EBEvent) in
        managedObject.side_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'issues' transient property
  //····················································································································

  private var mObserversOf_issues = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_issues (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_issues.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.issues_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_issues (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_issues.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.issues_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_issues_toElementsOfSet (_ inSet : Set<PadRepresentant>) {
    for managedObject in inSet {
      self.mObserversOf_issues.apply { (_ observer : EBEvent) in
        managedObject.issues_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_issues_fromElementsOfSet (_ inSet : Set<PadRepresentant>) {
    for managedObject in inSet {
      self.mObserversOf_issues.apply { (_ observer : EBEvent) in
        managedObject.issues_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    TransientArrayOf PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class TransientArrayOf_PadRepresentant : ReadOnlyArrayOf_PadRepresentant {

  //····················································································································
  //   Sort
  //····················································································································

  private var mIsOrderedBefore : Optional < (_ left : PadRepresentant, _ right : PadRepresentant) -> Bool > = nil 
  private var mSortObserver : EBModelNotifierEvent? = nil

  //····················································································································
  //   Data provider
  //····················································································································

  private var mDataProvider : ReadOnlyArrayOf_PadRepresentant? = nil
  private var mTransientKind : PropertyKind = .empty

 
  func setDataProvider (_ inProvider : ReadOnlyArrayOf_PadRepresentant,
                        sortCallback inSortCallBack : Optional < (_ left : PadRepresentant, _ right : PadRepresentant) -> Bool >,
                        addSortObserversCallback inAddSortObserversCallback : (EBModelNotifierEvent) -> Void,
                        removeSortObserversCallback inRemoveSortObserversCallback : @escaping (EBModelNotifierEvent) -> Void) {
    if self.mDataProvider !== inProvider {
      self.mSortObserver?.removeSortObservers ()
      self.mSortObserver = nil
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mIsOrderedBefore = inSortCallBack
      self.mDataProvider?.attachClient (self)
      if inSortCallBack != nil {
        self.mSortObserver = EBModelNotifierEvent (
          self,
          addSortObserversCallback: inAddSortObserversCallback,
          removeSortObserversCallback: inRemoveSortObserversCallback
        )
      }else{
        self.mInternalArrayValue = []
      }
    }
  }

  //····················································································································

  func resetDataProvider () {
    if self.mDataProvider != nil {
      self.mSortObserver = nil
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = nil
      self.mIsOrderedBefore = nil
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newArray : [PadRepresentant] 
    if let dataProvider = self.mDataProvider {
      switch dataProvider.prop {
      case .empty :
        newArray = []
        self.mTransientKind = .empty
      case .single (let v) :
        if let sortFunction = self.mIsOrderedBefore {
          newArray = v.sorted { sortFunction ($0, $1) }
        }else{
          newArray = v
        }
        self.mTransientKind = .single
       case .multiple :
        newArray = []
        self.mTransientKind = .multiple
      }
    }else{
      newArray = []
      self.mTransientKind = .empty
    }
    self.mInternalArrayValue = newArray
    super.notifyModelDidChange ()
  }

  //····················································································································

  override var prop : EBSelection < [PadRepresentant] > {
    switch self.mTransientKind {
    case .empty :
      return .empty
    case .single :
      return .single (self.mInternalArrayValue)
    case .multiple :
      return .multiple
    }
  }

  //····················································································································

  override var propval : [PadRepresentant] { return self.mInternalArrayValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    TransientArrayOfSuperOf PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class TransientArrayOfSuperOf_PadRepresentant <SUPER : EBManagedObject> : ReadOnlyArrayOf_PadRepresentant {

  //····················································································································
  //   Data provider
  //····················································································································

  private var mDataProvider : ReadOnlyAbstractArrayProperty <SUPER>? = nil
  private var mTransientKind : PropertyKind = .empty

  //····················································································································

  func setDataProvider (_ inProvider : ReadOnlyAbstractArrayProperty <SUPER>?) {
    if self.mDataProvider !== inProvider {
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mDataProvider?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    var newModelArray : [SUPER] 
    if let dataProvider = self.mDataProvider {
      switch dataProvider.prop {
      case .empty :
        newModelArray = []
        self.mTransientKind = .empty
      case .single (let v) :
        newModelArray = v
        self.mTransientKind = .single
       case .multiple :
        newModelArray = []
        self.mTransientKind = .multiple
      }
    }else{
      newModelArray = []
      self.mTransientKind = .empty
    }
    var newArray = [PadRepresentant] ()
    for superObject in newModelArray {
      if let object = superObject as? PadRepresentant {
        newArray.append (object)
      }
    }
    self.mInternalArrayValue = newArray
    super.notifyModelDidChange ()
  }

  //····················································································································

  override var prop : EBSelection < [PadRepresentant] > {
    switch self.mTransientKind {
    case .empty :
      return .empty
    case .single :
      return .single (self.mInternalArrayValue)
    case .multiple :
      return .multiple
    }
  }

  //····················································································································

  override var propval : [PadRepresentant] { return self.mInternalArrayValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    To many relationship read write: PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadWriteArrayOf_PadRepresentant : ReadOnlyArrayOf_PadRepresentant {

  //····················································································································
 
  func setProp (_ value :  [PadRepresentant]) { } // Abstract method
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Proxy: ProxyArrayOf_PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class ProxyArrayOf_PadRepresentant : ReadWriteArrayOf_PadRepresentant {

  //····················································································································

  private var mModel : ReadWriteArrayOf_PadRepresentant? = nil

  //····················································································································

  func setModel (_ inModel : ReadWriteArrayOf_PadRepresentant?) {
    if self.mModel !== inModel {
      self.mModel?.detachClient (self)
      self.mModel = inModel
      self.mModel?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newModelArray : [PadRepresentant]
    if let model = self.mModel {
      switch model.prop {
      case .empty :
        newModelArray = []
      case .single (let v) :
        newModelArray = v
       case .multiple :
        newModelArray = []
      }
    }else{
      newModelArray = []
    }
    self.mInternalArrayValue = newModelArray
    super.notifyModelDidChange ()
  }

  //····················································································································

  override func setProp (_ inArrayValue : [PadRepresentant]) {
    self.mModel?.setProp (inArrayValue)
  }

  //····················································································································

  override var prop : EBSelection < [PadRepresentant] > {
    if let model = self.mModel {
      return model.prop
    }else{
      return .empty
    }
  }

  //····················································································································

  override var propval : [PadRepresentant] {
    if let model = self.mModel {
      switch model.prop {
      case .empty, .multiple :
        return []
      case .single (let v) :
        return v
      }
    }else{
      return []
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    To many relationship: PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class StoredArrayOf_PadRepresentant : ReadWriteArrayOf_PadRepresentant, EBSignatureObserverProtocol {

  //····················································································································
  //   Undo manager
  //····················································································································

  weak var ebUndoManager : EBUndoManager? = nil // SOULD BE WEAK

  //····················································································································
  //   Opposite relationship management
  //····················································································································

  private var mSetOppositeRelationship : Optional < (_ inManagedObject : PadRepresentant) -> Void > = nil
  private var mResetOppositeRelationship : Optional < (_ inManagedObject : PadRepresentant) -> Void > = nil

  //····················································································································

  func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : PadRepresentant) -> Void,
                                         resetter inResetter : @escaping (_ inManagedObject : PadRepresentant) -> Void) {
    self.mSetOppositeRelationship = inSetter
    self.mResetOppositeRelationship = inResetter
  }
  
  //····················································································································

  var mValueExplorer : NSPopUpButton? {
    didSet {
      if let unwrappedExplorer = self.mValueExplorer {
        switch prop {
        case .empty, .multiple :
          break ;
        case .single (let v) :
          updateManagedObjectToManyRelationshipDisplay (objectArray: v, popUpButton: unwrappedExplorer)
        }
      }
    }
  }

  //····················································································································
  // Model will change 
  //····················································································································

  override func notifyModelDidChangeFrom (oldValue inOldValue : [PadRepresentant]) {
  //--- Register old value in undo manager
    self.ebUndoManager?.registerUndo (withTarget: self, selector:#selector(performUndo(_:)), object: inOldValue)
  //---
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  }
 
  //····················································································································

  @objc func performUndo (_ oldValue : [PadRepresentant]) {
    self.mInternalArrayValue = oldValue
  }
 
  //····················································································································
  // Model did change 
  //····················································································································

  override func notifyModelDidChange () {
  //--- Update explorer
    if let valueExplorer = self.mValueExplorer {
      updateManagedObjectToManyRelationshipDisplay (objectArray: self.mInternalArrayValue, popUpButton: valueExplorer)
    }
  //--- Notify observers
    self.postEvent ()
    self.clearSignatureCache ()
  //---
    super.notifyModelDidChange ()
  }

  //····················································································································
  // Update observers 
  //····················································································································

  internal override func updateObservers (removedSet inRemovedSet : Set <PadRepresentant>, addedSet inAddedSet : Set <PadRepresentant>) {
    for managedObject in inRemovedSet {
      managedObject.setSignatureObserver (observer: nil)
      self.mResetOppositeRelationship? (managedObject)
    }
  //---
    for managedObject in inAddedSet {
      managedObject.setSignatureObserver (observer: self)
      self.mSetOppositeRelationship? (managedObject)
    }
  //---
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
 }
 
  //····················································································································

  override var prop : EBSelection < [PadRepresentant] > { return .single (self.mInternalArrayValue) }

  //····················································································································

  override func setProp (_ inValue : [PadRepresentant]) { self.mInternalArrayValue = inValue }

  //····················································································································

  override var propval : [PadRepresentant] { return self.mInternalArrayValue }

  //····················································································································

  func remove (_ object : PadRepresentant) {
    if let idx = self.mInternalArrayValue.firstIndex (of: object) {
      self.mInternalArrayValue.remove (at: idx)
    }
  }
  
  //····················································································································

  func add (_ object : PadRepresentant) {
    if !self.internalSetValue.contains (object) {
      self.mInternalArrayValue.append (object)
    }
  }
  
  //····················································································································
  //   signature
  //····················································································································

  private weak var mSignatureObserver : EBSignatureObserverProtocol? = nil // SOULD BE WEAK

  //····················································································································

  private var mSignatureCache : UInt32? = nil

  //····················································································································

  final func setSignatureObserver (observer : EBSignatureObserverProtocol?) {
    self.mSignatureObserver = observer
    for object in self.mInternalArrayValue {
      object.setSignatureObserver (observer: observer)
    }
  }

  //····················································································································

  final func signature () -> UInt32 {
    let computedSignature : UInt32
    if let s = self.mSignatureCache {
      computedSignature = s
    }else{
      computedSignature = computeSignature ()
      self.mSignatureCache = computedSignature
    }
    return computedSignature
  }
  
  //····················································································································

  final func computeSignature () -> UInt32 {
    var crc : UInt32 = 0
    for object in self.mInternalArrayValue {
      crc.accumulateUInt32 (object.signature ())
    }
    return crc
  }

  //····················································································································

  final func clearSignatureCache () {
    if self.mSignatureCache != nil {
      self.mSignatureCache = nil
      self.mSignatureObserver?.clearSignatureCache ()
    }
  }

  //····················································································································
 
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Preferences array: PadRepresentant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class PreferencesArrayOf_PadRepresentant : StoredArrayOf_PadRepresentant {

  //····················································································································

  private let mPrefKey : String
  private let mObserverForWritingPreferences = EBOutletEvent ()
  
  //····················································································································

  init (prefKey : String) {
    self.mPrefKey = prefKey
    super.init ()
    if let array = UserDefaults.standard.array (forKey: prefKey) as? [NSDictionary] {
      var objectArray = [PadRepresentant] ()
      for dictionary in array {
        if let object = newInstanceOfEntityNamed (self.ebUndoManager, "PadRepresentant") as? PadRepresentant {
          object.setUpAtomicPropertiesWithDictionary (dictionary)
          objectArray.append (object)
        }
      }
      self.setProp (objectArray)
    }
    self.addEBObserverOf_mComponentPadName (self.mObserverForWritingPreferences)
    self.addEBObserverOf_mPadIndex (self.mObserverForWritingPreferences)
    self.mObserverForWritingPreferences.mEventCallBack = { [weak self] in self?.writeInPreferences () }
 }

  //····················································································································
 
  private func writeInPreferences () {
    var dictionaryArray = [NSDictionary] ()
    for object in self.mInternalArrayValue {
      let d = NSMutableDictionary ()
      object.saveIntoDictionary (d)
      d [ENTITY_KEY] = nil // Remove entity key, not used in preferences
      dictionaryArray.append (d)
    }
    UserDefaults.standard.set (dictionaryArray, forKey: self.mPrefKey)
  }

  //····················································································································
 
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
