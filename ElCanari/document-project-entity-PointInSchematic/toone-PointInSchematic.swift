//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadOnlyObject_PointInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadOnlyObject_PointInSchematic : ReadOnlyAbstractObjectProperty <PointInSchematic> {

  //····················································································································

  internal override func notifyModelDidChangeFrom (oldValue inOldValue : PointInSchematic?) {
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  //--- Remove observers from removed objects
    if let oldValue = inOldValue {
      oldValue.mSymbolPinName_property.removeEBObserver (self.mSymbolPinName_property) // Stored property
      oldValue.mX_property.removeEBObserver (self.mX_property) // Stored property
      oldValue.mY_property.removeEBObserver (self.mY_property) // Stored property
      oldValue.location_property.removeEBObserver (self.location_property) // Transient property
      oldValue.netName_property.removeEBObserver (self.netName_property) // Transient property
      oldValue.netClassName_property.removeEBObserver (self.netClassName_property) // Transient property
      oldValue.hasNet_property.removeEBObserver (self.hasNet_property) // Transient property
      oldValue.canMove_property.removeEBObserver (self.canMove_property) // Transient property
      oldValue.wireColor_property.removeEBObserver (self.wireColor_property) // Transient property
      oldValue.symbolRotation_property.removeEBObserver (self.symbolRotation_property) // Transient property
      oldValue.symbolNameNetName_property.removeEBObserver (self.symbolNameNetName_property) // Transient property
      oldValue.isConnected_property.removeEBObserver (self.isConnected_property) // Transient property
      oldValue.status_property.removeEBObserver (self.status_property) // Transient property
      oldValue.connectedPoints_property.removeEBObserver (self.connectedPoints_property) // Transient property
      oldValue.netInfoForPoint_property.removeEBObserver (self.netInfoForPoint_property) // Transient property
    }
  //--- Add observers to added objects
    if let newValue = self.mInternalValue {
      newValue.mSymbolPinName_property.addEBObserver (self.mSymbolPinName_property) // Stored property
      newValue.mX_property.addEBObserver (self.mX_property) // Stored property
      newValue.mY_property.addEBObserver (self.mY_property) // Stored property
      newValue.location_property.addEBObserver (self.location_property) // Transient property
      newValue.netName_property.addEBObserver (self.netName_property) // Transient property
      newValue.netClassName_property.addEBObserver (self.netClassName_property) // Transient property
      newValue.hasNet_property.addEBObserver (self.hasNet_property) // Transient property
      newValue.canMove_property.addEBObserver (self.canMove_property) // Transient property
      newValue.wireColor_property.addEBObserver (self.wireColor_property) // Transient property
      newValue.symbolRotation_property.addEBObserver (self.symbolRotation_property) // Transient property
      newValue.symbolNameNetName_property.addEBObserver (self.symbolNameNetName_property) // Transient property
      newValue.isConnected_property.addEBObserver (self.isConnected_property) // Transient property
      newValue.status_property.addEBObserver (self.status_property) // Transient property
      newValue.connectedPoints_property.addEBObserver (self.connectedPoints_property) // Transient property
      newValue.netInfoForPoint_property.addEBObserver (self.netInfoForPoint_property) // Transient property
    }
  }

  //····················································································································
  //   Observers of 'mSymbolPinName' stored property
  //····················································································································

  final let mSymbolPinName_property = EBGenericTransientProperty <String?> ()

  //····················································································································
  //   Observers of 'mX' stored property
  //····················································································································

  final let mX_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mY' stored property
  //····················································································································

  final let mY_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'location' transient property
  //····················································································································

  final let location_property = EBGenericTransientProperty <CanariPoint?> ()

  //····················································································································
  //   Observers of 'netName' transient property
  //····················································································································

  final let netName_property = EBGenericTransientProperty <String?> ()

  //····················································································································
  //   Observers of 'netClassName' transient property
  //····················································································································

  final let netClassName_property = EBGenericTransientProperty <String?> ()

  //····················································································································
  //   Observers of 'hasNet' transient property
  //····················································································································

  final let hasNet_property = EBGenericTransientProperty <Bool?> ()

  //····················································································································
  //   Observers of 'canMove' transient property
  //····················································································································

  final let canMove_property = EBGenericTransientProperty <Bool?> ()

  //····················································································································
  //   Observers of 'wireColor' transient property
  //····················································································································

  final let wireColor_property = EBGenericTransientProperty <NSColor?> ()

  //····················································································································
  //   Observers of 'symbolRotation' transient property
  //····················································································································

  final let symbolRotation_property = EBGenericTransientProperty <QuadrantRotation?> ()

  //····················································································································
  //   Observers of 'symbolNameNetName' transient property
  //····················································································································

  final let symbolNameNetName_property = EBGenericTransientProperty <TwoStrings?> ()

  //····················································································································
  //   Observers of 'isConnected' transient property
  //····················································································································

  final let isConnected_property = EBGenericTransientProperty <Bool?> ()

  //····················································································································
  //   Observers of 'status' transient property
  //····················································································································

  final let status_property = EBGenericTransientProperty <SchematicPointStatus?> ()

  //····················································································································
  //   Observers of 'connectedPoints' transient property
  //····················································································································

  final let connectedPoints_property = EBGenericTransientProperty <CanariPointArray?> ()

  //····················································································································
  //   Observers of 'netInfoForPoint' transient property
  //····················································································································

  final let netInfoForPoint_property = EBGenericTransientProperty <NetInfoPoint?> ()

  //····················································································································
  //   Observable toMany property: mLabels
  //····················································································································

  private final var mObserversOf_mLabels = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_mLabels (_ inObserver : EBEvent) {
    self.mObserversOf_mLabels.insert (inObserver)
    if let object = self.propval {
      object.mLabels_property.addEBObserver (inObserver)
    }
  }

  //····················································································································

  final func removeEBObserverOf_mLabels (_ inObserver : EBEvent) {
    self.mObserversOf_mLabels.remove (inObserver)
    if let object = self.propval {
      object.mLabels_property.removeEBObserver (inObserver)
    }
  }

  //····················································································································
  //   Observable toMany property: mWiresP2s
  //····················································································································

  private final var mObserversOf_mWiresP2s = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_mWiresP2s (_ inObserver : EBEvent) {
    self.mObserversOf_mWiresP2s.insert (inObserver)
    if let object = self.propval {
      object.mWiresP2s_property.addEBObserver (inObserver)
    }
  }

  //····················································································································

  final func removeEBObserverOf_mWiresP2s (_ inObserver : EBEvent) {
    self.mObserversOf_mWiresP2s.remove (inObserver)
    if let object = self.propval {
      object.mWiresP2s_property.removeEBObserver (inObserver)
    }
  }

  //····················································································································
  //   Observable toMany property: mWiresP1s
  //····················································································································

  private final var mObserversOf_mWiresP1s = EBWeakEventSet ()

  //····················································································································

  final func addEBObserverOf_mWiresP1s (_ inObserver : EBEvent) {
    self.mObserversOf_mWiresP1s.insert (inObserver)
    if let object = self.propval {
      object.mWiresP1s_property.addEBObserver (inObserver)
    }
  }

  //····················································································································

  final func removeEBObserverOf_mWiresP1s (_ inObserver : EBEvent) {
    self.mObserversOf_mWiresP1s.remove (inObserver)
    if let object = self.propval {
      object.mWiresP1s_property.removeEBObserver (inObserver)
    }
  }

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
  //--- Configure mSymbolPinName simple stored property
    self.mSymbolPinName_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mSymbolPinName_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure mX simple stored property
    self.mX_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mX_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure mY simple stored property
    self.mY_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mY_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure location transient property
    self.location_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.location_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure netName transient property
    self.netName_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.netName_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure netClassName transient property
    self.netClassName_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.netClassName_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure hasNet transient property
    self.hasNet_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.hasNet_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure canMove transient property
    self.canMove_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.canMove_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure wireColor transient property
    self.wireColor_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.wireColor_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure symbolRotation transient property
    self.symbolRotation_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.symbolRotation_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure symbolNameNetName transient property
    self.symbolNameNetName_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.symbolNameNetName_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure isConnected transient property
    self.isConnected_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.isConnected_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure status transient property
    self.status_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.status_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure connectedPoints transient property
    self.connectedPoints_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.connectedPoints_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  //--- Configure netInfoForPoint transient property
    self.netInfoForPoint_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.netInfoForPoint_property.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          return .single (v)
        }
      }else{
        return .single (nil)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   TransientObject PointInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class TransientObject_PointInSchematic : ReadOnlyObject_PointInSchematic {

  //····················································································································
  //   Data provider
  //····················································································································

  private var mDataProvider : ReadOnlyObject_PointInSchematic? = nil
  private var mTransientKind : PropertyKind = .empty

  //····················································································································

  func setDataProvider (_ inProvider : ReadOnlyObject_PointInSchematic?) {
    if self.mDataProvider !== inProvider {
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mDataProvider?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newObject : PointInSchematic?
    if let dataProvider = self.mDataProvider {
      switch dataProvider.selection {
      case .empty :
        newObject = nil
        self.mTransientKind = .empty
      case .single (let v) :
        newObject = v
        self.mTransientKind = .single
       case .multiple :
        newObject = nil
        self.mTransientKind = .empty
      }
    }else{
      newObject = nil
      self.mTransientKind = .empty
    }
    self.mInternalValue = newObject
    super.notifyModelDidChange ()
  }

  //····················································································································

  override var selection : EBSelection < PointInSchematic? > {
    switch self.mTransientKind {
    case .empty :
      return .empty
    case .single :
      if let internalValue = self.mInternalValue {
        return .single (internalValue)
      }else{
        return .empty
      }
    case .multiple :
      return .multiple
    }
  }

  //····················································································································

  override var propval : PointInSchematic? { return self.mInternalValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadWriteObject_PointInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadWriteObject_PointInSchematic : ReadOnlyObject_PointInSchematic {

  //····················································································································

  func setProp (_ inValue : PointInSchematic?) { } // Abstract method

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Proxy: ProxyObject_PointInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class ProxyObject_PointInSchematic : ReadWriteObject_PointInSchematic {

  //····················································································································

  private var mModel : ReadWriteObject_PointInSchematic? = nil

  //····················································································································

  func setModel (_ inModel : ReadWriteObject_PointInSchematic?) {
    if self.mModel !== inModel {
      self.mModel?.detachClient (self)
      self.mModel = inModel
      self.mModel?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newModel : PointInSchematic?
    if let model = self.mModel {
      switch model.selection {
      case .empty :
        newModel = nil
      case .single (let v) :
        newModel = v
       case .multiple :
        newModel = nil
      }
    }else{
      newModel = nil
    }
    self.mInternalValue = newModel
    super.notifyModelDidChange ()
  }

  //····················································································································

  override func setProp (_ inValue : PointInSchematic?) {
    self.mModel?.setProp (inValue)
  }

  //····················································································································

  override var selection : EBSelection < PointInSchematic? > {
    if let model = self.mModel {
      return model.selection
    }else{
      return .empty
    }
  }

  //····················································································································

  override var propval : PointInSchematic? {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        return nil
      case .single (let v) :
        return v
      }
    }else{
      return nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    StoredObject_PointInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class StoredObject_PointInSchematic : ReadWriteObject_PointInSchematic, EBSignatureObserverProtocol, EBObservableObjectProtocol {

 //····················································································································

  init (usedForSignature inUsedForSignature : Bool) {
    mUsedForSignature = inUsedForSignature
    super.init ()
  }

  //····················································································································
  //   Signature ?
  //····················································································································

  private let mUsedForSignature : Bool

  //····················································································································
  //   Undo manager
  //····················································································································

  weak final var ebUndoManager : EBUndoManager? = nil // SOULD BE WEAK

 //····················································································································
  //   Opposite relationship management
  //····················································································································

  private var mSetOppositeRelationship : Optional < (_ inManagedObject : PointInSchematic) -> Void > = nil
  private var mResetOppositeRelationship : Optional < (_ inManagedObject : PointInSchematic) -> Void > = nil

  //····················································································································

  func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : PointInSchematic) -> Void,
                                         resetter inResetter : @escaping (_ inManagedObject : PointInSchematic) -> Void) {
    self.mSetOppositeRelationship = inSetter
    self.mResetOppositeRelationship = inResetter
  }

  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    var mValueExplorer : NSButton? {
      didSet {
        if let unwrappedExplorer = self.mValueExplorer {
          switch self.selection {
          case .empty, .multiple :
            break ;
          case .single (let v) :
            updateManagedObjectToOneRelationshipDisplay (object: v, button: unwrappedExplorer)
          }
        }
      }
    }
  #endif
  
  //····················································································································
  // Model will change
  //····················································································································

  override func notifyModelDidChangeFrom (oldValue inOldValue : PointInSchematic?) {
  //--- Register old value in undo manager
    self.ebUndoManager?.registerUndo (withTarget: self) { $0.mInternalValue = inOldValue }
  //---
    if let object = inOldValue {
      if self.mUsedForSignature {
        object.setSignatureObserver (observer: nil)
      }
      self.mResetOppositeRelationship? (object)
    }
  //---
    if let object = self.mInternalValue {
      if self.mUsedForSignature {
        object.setSignatureObserver (observer: self)
      }
      self.mSetOppositeRelationship? (object)
    }
  //---
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  }

  //····················································································································
  // Model did change
  //····················································································································

  override func notifyModelDidChange () {
  //--- Update explorer
    #if BUILD_OBJECT_EXPLORER
      if let valueExplorer = self.mValueExplorer {
        updateManagedObjectToOneRelationshipDisplay (object: self.mInternalValue, button: valueExplorer)
      }
    #endif
  //--- Notify observers
    self.postEvent ()
    self.clearSignatureCache ()
  //---
    super.notifyModelDidChange ()
  }

  //····················································································································

  override var selection : EBSelection < PointInSchematic? > {
    if let object = self.mInternalValue {
      return .single (object)
    }else{
      return .empty
    }
  }

  //····················································································································

  override func setProp (_ inValue : PointInSchematic?) { self.mInternalValue = inValue }

  //····················································································································

  override var propval : PointInSchematic? { return self.mInternalValue }

  //····················································································································
  //   signature
  //····················································································································

  private weak var mSignatureObserver : EBSignatureObserverProtocol? = nil // SOULD BE WEAK

  //····················································································································

  private var mSignatureCache : UInt32? = nil

  //····················································································································

  final func setSignatureObserver (observer inObserver : EBSignatureObserverProtocol?) {
    self.mSignatureObserver?.clearSignatureCache ()
    self.mSignatureObserver = inObserver
    inObserver?.clearSignatureCache ()
    self.clearSignatureCache ()
  }

  //····················································································································

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

  //····················································································································

  final private func computeSignature () -> UInt32 {
    var crc : UInt32 = 0
    if let object = self.mInternalValue {
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
