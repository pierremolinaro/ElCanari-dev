//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadOnlyArrayOf_SymbolPinInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadOnlyArrayOf_SymbolPinInstanceInDevice : ReadOnlyAbstractArrayProperty <SymbolPinInstanceInDevice> {

  //····················································································································

  internal override func updateObservers (removedSet inRemovedSet : Set <SymbolPinInstanceInDevice>, addedSet inAddedSet : Set <SymbolPinInstanceInDevice>) {
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
  //--- Remove observers from removed objects
    self.removeEBObserversOf_pinName_fromElementsOfSet (inRemovedSet) // Transient property
    self.removeEBObserversOf_symbolName_fromElementsOfSet (inRemovedSet) // Transient property
    self.removeEBObserversOf_pinQualifiedName_fromElementsOfSet (inRemovedSet) // Transient property
    self.removeEBObserversOf_isConnected_fromElementsOfSet (inRemovedSet) // Transient property
    self.removeEBObserversOf_numberShape_fromElementsOfSet (inRemovedSet) // Transient property
  //--- Add observers to added objects
    self.addEBObserversOf_pinName_toElementsOfSet (inAddedSet) // Transient property
    self.addEBObserversOf_symbolName_toElementsOfSet (inAddedSet) // Transient property
    self.addEBObserversOf_pinQualifiedName_toElementsOfSet (inAddedSet) // Transient property
    self.addEBObserversOf_isConnected_toElementsOfSet (inAddedSet) // Transient property
    self.addEBObserversOf_numberShape_toElementsOfSet (inAddedSet) // Transient property
  }

  //····················································································································
  //   Observers of 'pinName' transient property
  //····················································································································

  private var mObserversOf_pinName = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_pinName (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_pinName.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.pinName_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_pinName (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_pinName.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.pinName_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_pinName_toElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_pinName.apply { (_ observer : EBEvent) in
        managedObject.pinName_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_pinName_fromElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_pinName.apply { (_ observer : EBEvent) in
        managedObject.pinName_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'symbolName' transient property
  //····················································································································

  private var mObserversOf_symbolName = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_symbolName (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_symbolName.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.symbolName_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_symbolName (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_symbolName.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.symbolName_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_symbolName_toElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_symbolName.apply { (_ observer : EBEvent) in
        managedObject.symbolName_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_symbolName_fromElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_symbolName.apply { (_ observer : EBEvent) in
        managedObject.symbolName_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'pinQualifiedName' transient property
  //····················································································································

  private var mObserversOf_pinQualifiedName = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_pinQualifiedName (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_pinQualifiedName.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.pinQualifiedName_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_pinQualifiedName (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_pinQualifiedName.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.pinQualifiedName_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_pinQualifiedName_toElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_pinQualifiedName.apply { (_ observer : EBEvent) in
        managedObject.pinQualifiedName_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_pinQualifiedName_fromElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_pinQualifiedName.apply { (_ observer : EBEvent) in
        managedObject.pinQualifiedName_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'isConnected' transient property
  //····················································································································

  private var mObserversOf_isConnected = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_isConnected (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_isConnected.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.isConnected_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_isConnected (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_isConnected.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.isConnected_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_isConnected_toElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_isConnected.apply { (_ observer : EBEvent) in
        managedObject.isConnected_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_isConnected_fromElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_isConnected.apply { (_ observer : EBEvent) in
        managedObject.isConnected_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································
  //   Observers of 'numberShape' transient property
  //····················································································································

  private var mObserversOf_numberShape = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_numberShape (_ inObserver : EBEvent) {
    self.addEBObserver (inObserver)
    self.mObserversOf_numberShape.insert (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.numberShape_property.addEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func removeEBObserverOf_numberShape (_ inObserver : EBEvent) {
    self.removeEBObserver (inObserver)
    self.mObserversOf_numberShape.remove (inObserver)
    switch prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      for managedObject in v {
        managedObject.numberShape_property.removeEBObserver (inObserver)
      }
    }
  }

  //····················································································································

  final func addEBObserversOf_numberShape_toElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_numberShape.apply { (_ observer : EBEvent) in
        managedObject.numberShape_property.addEBObserver (observer)
      }
    }
  }

  //····················································································································

  final func removeEBObserversOf_numberShape_fromElementsOfSet (_ inSet : Set<SymbolPinInstanceInDevice>) {
    for managedObject in inSet {
      self.mObserversOf_numberShape.apply { (_ observer : EBEvent) in
        managedObject.numberShape_property.removeEBObserver (observer)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    TransientArrayOf SymbolPinInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class TransientArrayOf_SymbolPinInstanceInDevice : ReadOnlyArrayOf_SymbolPinInstanceInDevice {

  //····················································································································
  //   Data provider
  //····················································································································

  private var mDataProvider : ReadOnlyArrayOf_SymbolPinInstanceInDevice? = nil
  private var mTransientKind : PropertyKind = .empty

  //····················································································································

  func setDataProvider (_ inProvider : ReadOnlyArrayOf_SymbolPinInstanceInDevice?) {
    if self.mDataProvider !== inProvider {
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mDataProvider?.attachClient (self)
      if inProvider == nil {
        self.mInternalArrayValue = []
      }
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newArray : [SymbolPinInstanceInDevice] 
    if let dataProvider = self.mDataProvider {
      switch dataProvider.prop {
      case .empty :
        newArray = []
        self.mTransientKind = .empty
      case .single (let v) :
        newArray = v
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

  override var prop : EBSelection < [SymbolPinInstanceInDevice] > {
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

  override var propval : [SymbolPinInstanceInDevice] { return self.mInternalArrayValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    TransientArrayOfSuperOf SymbolPinInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class TransientArrayOfSuperOf_SymbolPinInstanceInDevice <SUPER : EBManagedObject> : ReadOnlyArrayOf_SymbolPinInstanceInDevice {

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
    var newArray = [SymbolPinInstanceInDevice] ()
    for superObject in newModelArray {
      if let object = superObject as? SymbolPinInstanceInDevice {
        newArray.append (object)
      }
    }
    self.mInternalArrayValue = newArray
    super.notifyModelDidChange ()
  }

  //····················································································································

  override var prop : EBSelection < [SymbolPinInstanceInDevice] > {
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

  override var propval : [SymbolPinInstanceInDevice] { return self.mInternalArrayValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    To many relationship read write: SymbolPinInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadWriteArrayOf_SymbolPinInstanceInDevice : ReadOnlyArrayOf_SymbolPinInstanceInDevice {

  //····················································································································
 
  func setProp (_ value :  [SymbolPinInstanceInDevice]) { } // Abstract method
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Proxy: ProxyArrayOf_SymbolPinInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class ProxyArrayOf_SymbolPinInstanceInDevice : ReadWriteArrayOf_SymbolPinInstanceInDevice {

  //····················································································································

  private var mModel : ReadWriteArrayOf_SymbolPinInstanceInDevice? = nil

  //····················································································································

  func setModel (_ inModel : ReadWriteArrayOf_SymbolPinInstanceInDevice?) {
    if self.mModel !== inModel {
      self.mModel?.detachClient (self)
      self.mModel = inModel
      self.mModel?.attachClient (self)
      /* if inModel == nil {
        self.mInternalArrayValue = []
      } */
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newModelArray : [SymbolPinInstanceInDevice]
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

  override func setProp (_ inArrayValue : [SymbolPinInstanceInDevice]) {
    self.mModel?.setProp (inArrayValue)
  }

  //····················································································································

  override var prop : EBSelection < [SymbolPinInstanceInDevice] > {
    if let model = self.mModel {
      return model.prop
    }else{
      return .empty
    }
  }

  //····················································································································

  override var propval : [SymbolPinInstanceInDevice] {
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
//    To many relationship: SymbolPinInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class StoredArrayOf_SymbolPinInstanceInDevice : ReadWriteArrayOf_SymbolPinInstanceInDevice, EBSignatureObserverProtocol {

  //····················································································································
  //   Opposite relationship management
  //····················································································································

  private var mSetOppositeRelationship : Optional < (_ inManagedObject : SymbolPinInstanceInDevice) -> Void > = nil
  private var mResetOppositeRelationship : Optional < (_ inManagedObject : SymbolPinInstanceInDevice) -> Void > = nil

  //····················································································································

  func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : SymbolPinInstanceInDevice) -> Void,
                                         resetter inResetter : @escaping (_ inManagedObject : SymbolPinInstanceInDevice) -> Void) {
    self.mSetOppositeRelationship = inSetter
    self.mResetOppositeRelationship = inResetter
  }
  
  //····················································································································

  private var mPrefKey : String? = nil

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
  //  Init
  //····················································································································

  convenience init (prefKey : String) {
    self.init ()
    self.mPrefKey = prefKey
    if let array = UserDefaults.standard.array (forKey: prefKey) as? [NSDictionary] {
      var objectArray = [SymbolPinInstanceInDevice] ()
      for dictionary in array {
        if let object = newInstanceOfEntityNamed (self.ebUndoManager, "SymbolPinInstanceInDevice") as? SymbolPinInstanceInDevice {
          object.setUpAtomicPropertiesWithDictionary (dictionary)
          objectArray.append (object)
        }
      }
      self.setProp (objectArray)
    }
  }

  //····················································································································
  // Model will change 
  //····················································································································

  override func notifyModelDidChangeFrom (oldValue inOldValue : [SymbolPinInstanceInDevice]) {
  //--- Register old value in undo manager
    self.ebUndoManager?.registerUndo (withTarget: self, selector:#selector(performUndo(_:)), object: inOldValue)
  //---
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  }
 
  //····················································································································

  @objc func performUndo (_ oldValue : [SymbolPinInstanceInDevice]) {
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
  //--- Write in preferences ?
    self.writeInPreferences ()
  //---
    super.notifyModelDidChange ()
  }

  //····················································································································
  // Update observers 
  //····················································································································

  internal override func updateObservers (removedSet inRemovedSet : Set <SymbolPinInstanceInDevice>, addedSet inAddedSet : Set <SymbolPinInstanceInDevice>) {
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

  override var prop : EBSelection < [SymbolPinInstanceInDevice] > { return .single (self.mInternalArrayValue) }

  //····················································································································

  override func setProp (_ inValue : [SymbolPinInstanceInDevice]) { self.mInternalArrayValue = inValue }

  //····················································································································

  override var propval : [SymbolPinInstanceInDevice] { return self.mInternalArrayValue }

  //····················································································································

  private func writeInPreferences () {
    if let prefKey = self.mPrefKey {
      var dictionaryArray = [NSDictionary] ()
      for object in self.mInternalArrayValue {
        let d = NSMutableDictionary ()
        object.saveIntoDictionary (d)
        d [ENTITY_KEY] = nil // Remove entity key, not used in preferences
        dictionaryArray.append (d)
      }
      UserDefaults.standard.set (dictionaryArray, forKey: prefKey)
    }
  }

  //····················································································································

  func remove (_ object : SymbolPinInstanceInDevice) {
    if let idx = self.mInternalArrayValue.firstIndex (of: object) {
      self.mInternalArrayValue.remove (at: idx)
    }
  }
  
  //····················································································································

  func add (_ object : SymbolPinInstanceInDevice) {
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
