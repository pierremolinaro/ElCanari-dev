//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadOnlyObject_DeviceSlavePadInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadOnlyObject_DeviceSlavePadInProject : ReadOnlyAbstractObjectProperty <DeviceSlavePadInProject> {

  //····················································································································

  internal override func notifyModelDidChangeFrom (oldValue inOldValue : DeviceSlavePadInProject?) {
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  //--- Remove observers from removed objects
    if let oldValue = inOldValue {
      oldValue.mCenterX_property.removeEBObserver (self.mCenterX_property) // Stored property
      oldValue.mCenterY_property.removeEBObserver (self.mCenterY_property) // Stored property
      oldValue.mWidth_property.removeEBObserver (self.mWidth_property) // Stored property
      oldValue.mHeight_property.removeEBObserver (self.mHeight_property) // Stored property
      oldValue.mHoleWidth_property.removeEBObserver (self.mHoleWidth_property) // Stored property
      oldValue.mHoleHeight_property.removeEBObserver (self.mHoleHeight_property) // Stored property
      oldValue.mShape_property.removeEBObserver (self.mShape_property) // Stored property
      oldValue.mStyle_property.removeEBObserver (self.mStyle_property) // Stored property
      oldValue.descriptor_property.removeEBObserver (self.descriptor_property) // Transient property
    }
  //--- Add observers to added objects
    if let newValue = self.mInternalValue {
      newValue.mCenterX_property.addEBObserver (self.mCenterX_property) // Stored property
      newValue.mCenterY_property.addEBObserver (self.mCenterY_property) // Stored property
      newValue.mWidth_property.addEBObserver (self.mWidth_property) // Stored property
      newValue.mHeight_property.addEBObserver (self.mHeight_property) // Stored property
      newValue.mHoleWidth_property.addEBObserver (self.mHoleWidth_property) // Stored property
      newValue.mHoleHeight_property.addEBObserver (self.mHoleHeight_property) // Stored property
      newValue.mShape_property.addEBObserver (self.mShape_property) // Stored property
      newValue.mStyle_property.addEBObserver (self.mStyle_property) // Stored property
      newValue.descriptor_property.addEBObserver (self.descriptor_property) // Transient property
    }
  }

  //····················································································································
  //   Observers of 'mCenterX' stored property
  //····················································································································

  final let mCenterX_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mCenterY' stored property
  //····················································································································

  final let mCenterY_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mWidth' stored property
  //····················································································································

  final let mWidth_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mHeight' stored property
  //····················································································································

  final let mHeight_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mHoleWidth' stored property
  //····················································································································

  final let mHoleWidth_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mHoleHeight' stored property
  //····················································································································

  final let mHoleHeight_property = EBGenericTransientProperty <Int?> ()

  //····················································································································
  //   Observers of 'mShape' stored property
  //····················································································································

  final let mShape_property = EBGenericTransientProperty <PadShape?> ()

  //····················································································································
  //   Observers of 'mStyle' stored property
  //····················································································································

  final let mStyle_property = EBGenericTransientProperty <SlavePadStyle?> ()

  //····················································································································
  //   Observers of 'descriptor' transient property
  //····················································································································

  final let descriptor_property = EBGenericTransientProperty <SlavePadDescriptor?> ()

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
  //--- Configure mCenterX simple stored property
    self.mCenterX_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mCenterX_property.selection {
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
  //--- Configure mCenterY simple stored property
    self.mCenterY_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mCenterY_property.selection {
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
  //--- Configure mWidth simple stored property
    self.mWidth_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mWidth_property.selection {
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
  //--- Configure mHeight simple stored property
    self.mHeight_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mHeight_property.selection {
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
  //--- Configure mHoleWidth simple stored property
    self.mHoleWidth_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mHoleWidth_property.selection {
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
  //--- Configure mHoleHeight simple stored property
    self.mHoleHeight_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mHoleHeight_property.selection {
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
  //--- Configure mShape simple stored property
    self.mShape_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mShape_property.selection {
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
  //--- Configure mStyle simple stored property
    self.mStyle_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.mStyle_property.selection {
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
  //--- Configure descriptor transient property
    self.descriptor_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.descriptor_property.selection {
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
//   TransientObject DeviceSlavePadInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class TransientObject_DeviceSlavePadInProject : ReadOnlyObject_DeviceSlavePadInProject {

  //····················································································································
  //   Data provider
  //····················································································································

  private var mDataProvider : ReadOnlyObject_DeviceSlavePadInProject? = nil
  private var mTransientKind : PropertyKind = .empty

  //····················································································································

  func setDataProvider (_ inProvider : ReadOnlyObject_DeviceSlavePadInProject?) {
    if self.mDataProvider !== inProvider {
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mDataProvider?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newObject : DeviceSlavePadInProject?
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

  override var selection : EBSelection < DeviceSlavePadInProject? > {
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

  override var propval : DeviceSlavePadInProject? { return self.mInternalValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadWriteObject_DeviceSlavePadInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadWriteObject_DeviceSlavePadInProject : ReadOnlyObject_DeviceSlavePadInProject {

  //····················································································································

  func setProp (_ inValue : DeviceSlavePadInProject?) { } // Abstract method

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Proxy: ProxyObject_DeviceSlavePadInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class ProxyObject_DeviceSlavePadInProject : ReadWriteObject_DeviceSlavePadInProject {

  //····················································································································

  private var mModel : ReadWriteObject_DeviceSlavePadInProject? = nil

  //····················································································································

  func setModel (_ inModel : ReadWriteObject_DeviceSlavePadInProject?) {
    if self.mModel !== inModel {
      self.mModel?.detachClient (self)
      self.mModel = inModel
      self.mModel?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newModel : DeviceSlavePadInProject?
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

  override func setProp (_ inValue : DeviceSlavePadInProject?) {
    self.mModel?.setProp (inValue)
  }

  //····················································································································

  override var selection : EBSelection < DeviceSlavePadInProject? > {
    if let model = self.mModel {
      return model.selection
    }else{
      return .empty
    }
  }

  //····················································································································

  override var propval : DeviceSlavePadInProject? {
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
//    StoredObject_DeviceSlavePadInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class StoredObject_DeviceSlavePadInProject : ReadWriteObject_DeviceSlavePadInProject, EBSignatureObserverProtocol, EBObservableObjectProtocol {

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

  private var mSetOppositeRelationship : Optional < (_ inManagedObject : DeviceSlavePadInProject) -> Void > = nil
  private var mResetOppositeRelationship : Optional < (_ inManagedObject : DeviceSlavePadInProject) -> Void > = nil

  //····················································································································

  func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : DeviceSlavePadInProject) -> Void,
                                         resetter inResetter : @escaping (_ inManagedObject : DeviceSlavePadInProject) -> Void) {
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

  override func notifyModelDidChangeFrom (oldValue inOldValue : DeviceSlavePadInProject?) {
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

  override var selection : EBSelection < DeviceSlavePadInProject? > {
    if let object = self.mInternalValue {
      return .single (object)
    }else{
      return .empty
    }
  }

  //····················································································································

  override func setProp (_ inValue : DeviceSlavePadInProject?) { self.mInternalValue = inValue }

  //····················································································································

  override var propval : DeviceSlavePadInProject? { return self.mInternalValue }

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
