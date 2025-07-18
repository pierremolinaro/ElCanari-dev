//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    ReadOnlyArrayOf_NCInSchematic
//--------------------------------------------------------------------------------------------------

class ReadOnlyArrayOf_NCInSchematic : EBReadOnlyAbstractArrayProperty <NCInSchematic> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateObservers (removedSet inRemovedSet : EBReferenceSet <NCInSchematic>,                            
                                 addedSet inAddedSet : EBReferenceSet <NCInSchematic>) {
    super.updateObservers (removedSet: inRemovedSet, addedSet: inAddedSet)
  //--- Remove observers from removed objects
    for managedObject in inRemovedSet.values {
      if let relay = self.mObserversOf_mOrientation { // Stored property
        managedObject.mOrientation_property.stopsBeingObserved (by: relay)
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
      if let relay = self.mObserversOf_mOrientation { // Stored property
        managedObject.mOrientation_property.startsBeingObserved (by: relay)
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
  //   Observers of 'mOrientation' stored property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mObserversOf_mOrientation : EBObservedObserver? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mOrientation_StartsBeingObserved (by inObserver : any EBObserverProtocol) {
    let relay : EBObservedObserver
    if let r = self.mObserversOf_mOrientation {
      relay = r
    }else{
      relay = EBObservedObserver ()
      self.startsBeingObserved (by: relay)
      for managedObject in self.propval.values {
        managedObject.mOrientation_property.startsBeingObserved (by: relay)
      }
      self.mObserversOf_mOrientation = relay
    }
    relay.startsBeingObserved (by: inObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func toMany_mOrientation_StopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mObserversOf_mOrientation?.stopsBeingObserved (by: inObserver)
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
//    TransientArrayOf NCInSchematic
//--------------------------------------------------------------------------------------------------

// TransientArrayOf_NCInSchematic is useless.

//--------------------------------------------------------------------------------------------------
//    TransientArrayOfSuperOf NCInSchematic
//--------------------------------------------------------------------------------------------------

final class TransientArrayOfSuperOf_NCInSchematic <SUPER : EBManagedObject> : ReadOnlyArrayOf_NCInSchematic {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Data provider
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mDataProvider : EBReadOnlyAbstractArrayProperty <SUPER>? = nil // SHOULD BE WEAK
  private var mTransientKind : PropertyKind = .empty
  private var mModelArrayShouldBeComputed = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setDataProvider (_ inProvider : EBReadOnlyAbstractArrayProperty <SUPER>?) {
    if self.mDataProvider !== inProvider {
      self.mDataProvider?.detachClient (self)
      self.mDataProvider = inProvider
      self.mDataProvider?.attachClient (self)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func notifyModelDidChange () {
    if !self.mModelArrayShouldBeComputed {
      self.mModelArrayShouldBeComputed = true
      DispatchQueue.main.async {
        self.computeModelArray ()
      }
    }
    super.notifyModelDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final func computeModelArray () {
    if self.mModelArrayShouldBeComputed {
      self.mModelArrayShouldBeComputed = false
      var newModelArray : EBReferenceArray <SUPER>
      if let dataProvider = self.mDataProvider {
        switch dataProvider.selection {
        case .empty :
          newModelArray = EBReferenceArray ()
          self.mTransientKind = .empty
        case .single (let v) :
          newModelArray = EBReferenceArray (v)
          self.mTransientKind = .single
         case .multiple :
          newModelArray = EBReferenceArray ()
          self.mTransientKind = .multiple
        }
      }else{
        newModelArray = EBReferenceArray ()
        self.mTransientKind = .empty
      }
      var newArray = EBReferenceArray <NCInSchematic> ()
      for superObject in newModelArray.values {
        if let object = superObject as? NCInSchematic {
          newArray.append (object)
        }
      }
      self.mInternalArrayValue = newArray
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var selection : EBSelection < [NCInSchematic] > {
    self.computeModelArray ()
    switch self.mTransientKind {
    case .empty :
      return .empty
    case .single :
      return .single (self.mInternalArrayValue.values)
    case .multiple :
      return .multiple
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var propval : EBReferenceArray <NCInSchematic> {
    self.computeModelArray ()
    return self.mInternalArrayValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//    To many relationship read write: NCInSchematic
//--------------------------------------------------------------------------------------------------

// ReadWriteArrayOf_NCInSchematic is useless.

//--------------------------------------------------------------------------------------------------
//    Proxy: ProxyArrayOf_NCInSchematic
//--------------------------------------------------------------------------------------------------

// ProxyArrayOf_NCInSchematic is useless.

//--------------------------------------------------------------------------------------------------
//    StandAlone Array: NCInSchematic
//--------------------------------------------------------------------------------------------------

// StandAloneArrayOf_NCInSchematic is useless.

//--------------------------------------------------------------------------------------------------
//    Stored Array: NCInSchematic
//--------------------------------------------------------------------------------------------------

// StoredArrayOf_NCInSchematic is useless.

//--------------------------------------------------------------------------------------------------
//    Preferences array: NCInSchematic
//--------------------------------------------------------------------------------------------------

// PreferencesArrayOf_NCInSchematic is useless.

//--------------------------------------------------------------------------------------------------

