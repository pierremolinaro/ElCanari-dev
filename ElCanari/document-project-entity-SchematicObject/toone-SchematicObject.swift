//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadOnlyObject_SchematicObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadOnlyObject_SchematicObject : ReadOnlyAbstractObjectProperty <SchematicObject> {

  //····················································································································

  internal override func notifyModelDidChangeFrom (oldValue inOldValue : SchematicObject?) {
    super.notifyModelDidChangeFrom (oldValue: inOldValue)
  //--- Remove observers from removed objects
    if let oldValue = inOldValue {
      oldValue.issues_property.removeEBObserver (self.issues_property) // Transient property
      oldValue.connectedPoints_property.removeEBObserver (self.connectedPoints_property) // Transient property
      oldValue.sheetDescriptor_property.removeEBObserver (self.sheetDescriptor_property) // Transient property
      oldValue.selectionDisplay_property.removeEBObserver (self.selectionDisplay_property) // Transient property
      oldValue.objectDisplay_property.removeEBObserver (self.objectDisplay_property) // Transient property
      oldValue.isPlacedInSchematic_property.removeEBObserver (self.isPlacedInSchematic_property) // Transient property
    }
  //--- Add observers to added objects
    if let newValue = self.mInternalValue {
      newValue.issues_property.addEBObserver (self.issues_property) // Transient property
      newValue.connectedPoints_property.addEBObserver (self.connectedPoints_property) // Transient property
      newValue.sheetDescriptor_property.addEBObserver (self.sheetDescriptor_property) // Transient property
      newValue.selectionDisplay_property.addEBObserver (self.selectionDisplay_property) // Transient property
      newValue.objectDisplay_property.addEBObserver (self.objectDisplay_property) // Transient property
      newValue.isPlacedInSchematic_property.addEBObserver (self.isPlacedInSchematic_property) // Transient property
    }
  }

  //····················································································································
  //   Observers of 'issues' transient property
  //····················································································································

  final let issues_property = EBGenericTransientProperty <CanariIssueArray?> ()

  //····················································································································
  //   Observers of 'connectedPoints' transient property
  //····················································································································

  final let connectedPoints_property = EBGenericTransientProperty <CanariPointArray?> ()

  //····················································································································
  //   Observers of 'sheetDescriptor' transient property
  //····················································································································

  final let sheetDescriptor_property = EBGenericTransientProperty <SchematicSheetDescriptor?> ()

  //····················································································································
  //   Observers of 'selectionDisplay' transient property
  //····················································································································

  final let selectionDisplay_property = EBGenericTransientProperty <EBShape?> ()

  //····················································································································
  //   Observers of 'objectDisplay' transient property
  //····················································································································

  final let objectDisplay_property = EBGenericTransientProperty <EBShape?> ()

  //····················································································································
  //   Observers of 'isPlacedInSchematic' transient property
  //····················································································································

  final let isPlacedInSchematic_property = EBGenericTransientProperty <Bool?> ()

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
  //--- Configure issues transient property
    self.issues_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.issues_property.selection {
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
  //--- Configure sheetDescriptor transient property
    self.sheetDescriptor_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.sheetDescriptor_property.selection {
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
  //--- Configure selectionDisplay transient property
    self.selectionDisplay_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.selectionDisplay_property.selection {
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
  //--- Configure objectDisplay transient property
    self.objectDisplay_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.objectDisplay_property.selection {
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
  //--- Configure isPlacedInSchematic transient property
    self.isPlacedInSchematic_property.mReadModelFunction = { [weak self] in
      if let model = self?.mInternalValue {
        switch model.isPlacedInSchematic_property.selection {
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
//   TransientObject SchematicObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class TransientObject_SchematicObject : ReadOnlyObject_SchematicObject {

  //····················································································································
  //   Data provider
  //····················································································································

  private var mDataProvider : ReadOnlyObject_SchematicObject? = nil
  private var mTransientKind : PropertyKind = .empty

  //····················································································································

  func setDataProvider (_ inProvider : ReadOnlyObject_SchematicObject?) {
    if self.mDataProvider !== inProvider {
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mDataProvider?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newObject : SchematicObject?
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

  override var selection : EBSelection < SchematicObject? > {
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

  override var propval : SchematicObject? { return self.mInternalValue }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ReadWriteObject_SchematicObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ReadWriteObject_SchematicObject : ReadOnlyObject_SchematicObject {

  //····················································································································

  func setProp (_ inValue : SchematicObject?) { } // Abstract method

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Proxy: ProxyObject_SchematicObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class ProxyObject_SchematicObject : ReadWriteObject_SchematicObject {

  //····················································································································

  private var mModel : ReadWriteObject_SchematicObject? = nil

  //····················································································································

  func setModel (_ inModel : ReadWriteObject_SchematicObject?) {
    if self.mModel !== inModel {
      self.mModel?.detachClient (self)
      self.mModel = inModel
      self.mModel?.attachClient (self)
    }
  }

  //····················································································································

  override func notifyModelDidChange () {
    let newModel : SchematicObject?
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

  override func setProp (_ inValue : SchematicObject?) {
    self.mModel?.setProp (inValue)
  }

  //····················································································································

  override var selection : EBSelection < SchematicObject? > {
    if let model = self.mModel {
      return model.selection
    }else{
      return .empty
    }
  }

  //····················································································································

  override var propval : SchematicObject? {
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
//    StoredObject_SchematicObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class StoredObject_SchematicObject : ReadWriteObject_SchematicObject, EBSignatureObserverProtocol, EBObservableObjectProtocol {

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

  private var mSetOppositeRelationship : Optional < (_ inManagedObject : SchematicObject) -> Void > = nil
  private var mResetOppositeRelationship : Optional < (_ inManagedObject : SchematicObject) -> Void > = nil

  //····················································································································

  func setOppositeRelationShipFunctions (setter inSetter : @escaping (_ inManagedObject : SchematicObject) -> Void,
                                         resetter inResetter : @escaping (_ inManagedObject : SchematicObject) -> Void) {
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

  override func notifyModelDidChangeFrom (oldValue inOldValue : SchematicObject?) {
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

  override var selection : EBSelection < SchematicObject? > {
    if let object = self.mInternalValue {
      return .single (object)
    }else{
      return .empty
    }
  }

  //····················································································································

  override func setProp (_ inValue : SchematicObject?) { self.mInternalValue = inValue }

  //····················································································································

  override var propval : SchematicObject? { return self.mInternalValue }

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
