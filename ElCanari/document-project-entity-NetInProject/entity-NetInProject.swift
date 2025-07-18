//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol NetInProject_mNetName : AnyObject {
  var mNetName : String { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol NetInProject_mWarnsExactlyOneLabel : AnyObject {
  var mWarnsExactlyOneLabel : Bool { get }
}

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol NetInProject_netClassName : AnyObject {
//   var netClassName : String? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol NetInProject_netClassTrackWidth : AnyObject {
//   var netClassTrackWidth : Int? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol NetInProject_netClassViaHoleDiameter : AnyObject {
//   var netClassViaHoleDiameter : Int? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol NetInProject_netClassViaPadDiameter : AnyObject {
//   var netClassViaPadDiameter : Int? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol NetInProject_wireColor : AnyObject {
//   var wireColor : NSColor? { get }
// }

//--------------------------------------------------------------------------------------------------

@MainActor protocol NetInProject_netSchematicPointsInfo : AnyObject {
  var netSchematicPointsInfo : NetInfoPointArray? { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol NetInProject_trackCount : AnyObject {
  var trackCount : Int? { get }
}

//--------------------------------------------------------------------------------------------------
//    Entity: NetInProject
//--------------------------------------------------------------------------------------------------

final class NetInProject : EBManagedObject
    , NetInProject_mNetName
    , NetInProject_mWarnsExactlyOneLabel
    // NetInProject_netClassName // Commented out, not used
    // NetInProject_netClassTrackWidth // Commented out, not used
    // NetInProject_netClassViaHoleDiameter // Commented out, not used
    // NetInProject_netClassViaPadDiameter // Commented out, not used
    // NetInProject_wireColor // Commented out, not used
    , NetInProject_netSchematicPointsInfo
    , NetInProject_trackCount
    {

  //------------------------------------------------------------------------------------------------
  //   To many property: mPoints
  //------------------------------------------------------------------------------------------------

  final let mPoints_property = StoredArrayOf_PointInSchematic (usedForSignature: false, key: "mPoints")

  //------------------------------------------------------------------------------------------------

  final var mPoints : EBReferenceArray <PointInSchematic> {
    get { return self.mPoints_property.propval }
    set { self.mPoints_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mNetName
  //------------------------------------------------------------------------------------------------

  final let mNetName_property : EBStoredProperty_String

  //------------------------------------------------------------------------------------------------

  final var mNetName : String {
    get { return self.mNetName_property.propval }
    set { self.mNetName_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mWarnsExactlyOneLabel
  //------------------------------------------------------------------------------------------------

  final let mWarnsExactlyOneLabel_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------

  final var mWarnsExactlyOneLabel : Bool {
    get { return self.mWarnsExactlyOneLabel_property.propval }
    set { self.mWarnsExactlyOneLabel_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   To many property: mTracks
  //------------------------------------------------------------------------------------------------

  final let mTracks_property = StoredArrayOf_BoardTrack (usedForSignature: false, key: "mTracks")

  //------------------------------------------------------------------------------------------------

  final var mTracks : EBReferenceArray <BoardTrack> {
    get { return self.mTracks_property.propval }
    set { self.mTracks_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   To one property: mNetClass
  //------------------------------------------------------------------------------------------------

  final let mNetClass_property = StoredObject_NetClassInProject (usedForSignature: false, strongRef: false, key: "mNetClass")

  //------------------------------------------------------------------------------------------------

  final var mNetClass : NetClassInProject? {
    get {
      return self.mNetClass_property.propval
    }
    set {
      // self.mNetClass_property.setProp (newValue)
      if self.mNetClass_property.propval !== newValue {
        if self.mNetClass_property.propval != nil {
          self.mNetClass_property.setProp (nil)
        }
        if newValue != nil {
          self.mNetClass_property.setProp (newValue)
        }
      }
    }
  }

  //------------------------------------------------------------------------------------------------

  final let mNetClass_none = EBTransientProperty <Bool> ()

  //------------------------------------------------------------------------------------------------
  //   Transient property: netClassName
  //------------------------------------------------------------------------------------------------

  final let netClassName_property = EBTransientProperty <String> ()

  //------------------------------------------------------------------------------------------------

  final var netClassName : String? {
    return self.netClassName_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: netClassTrackWidth
  //------------------------------------------------------------------------------------------------

  final let netClassTrackWidth_property = EBTransientProperty <Int> ()

  //------------------------------------------------------------------------------------------------

  final var netClassTrackWidth : Int? {
    return self.netClassTrackWidth_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: netClassViaHoleDiameter
  //------------------------------------------------------------------------------------------------

  final let netClassViaHoleDiameter_property = EBTransientProperty <Int> ()

  //------------------------------------------------------------------------------------------------

  final var netClassViaHoleDiameter : Int? {
    return self.netClassViaHoleDiameter_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: netClassViaPadDiameter
  //------------------------------------------------------------------------------------------------

  final let netClassViaPadDiameter_property = EBTransientProperty <Int> ()

  //------------------------------------------------------------------------------------------------

  final var netClassViaPadDiameter : Int? {
    return self.netClassViaPadDiameter_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: wireColor
  //------------------------------------------------------------------------------------------------

  final let wireColor_property = EBTransientProperty <NSColor> ()

  //------------------------------------------------------------------------------------------------

  final var wireColor : NSColor? {
    return self.wireColor_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: netSchematicPointsInfo
  //------------------------------------------------------------------------------------------------

  final let netSchematicPointsInfo_property = EBTransientProperty <NetInfoPointArray> ()

  //------------------------------------------------------------------------------------------------

  final var netSchematicPointsInfo : NetInfoPointArray? {
    return self.netSchematicPointsInfo_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: trackCount
  //------------------------------------------------------------------------------------------------

  final let trackCount_property = EBTransientProperty <Int> ()

  //------------------------------------------------------------------------------------------------

  final var trackCount : Int? {
    return self.trackCount_property.optionalValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (_ inUndoManager : UndoManager?) {
    self.mNetName_property = EBStoredProperty_String (defaultValue: "", undoManager: inUndoManager, key: "mNetName")
    self.mWarnsExactlyOneLabel_property = EBStoredProperty_Bool (defaultValue: true, undoManager: inUndoManager, key: "mWarnsExactlyOneLabel")
    super.init (inUndoManager)
    self.mNetClass_none.mReadModelFunction = { [weak self] in
      if let uwSelf = self {
        return .single (uwSelf.mNetClass_property.propval == nil)
      }else{
        return .empty
      }
    }
    self.mNetClass_property.startsBeingObserved (by: self.mNetClass_none)
  //--- To many property: mPoints (has opposite relationship)
    self.mPoints_property.undoManager = inUndoManager
    self.mPoints_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mNet_property.setProp (me) } },
      resetter: { inObject in inObject.mNet_property.setProp (nil) }
    )
    self.accumulateProperty (self.mPoints_property)
    self.accumulateProperty (self.mNetName_property)
    self.accumulateProperty (self.mWarnsExactlyOneLabel_property)
  //--- To many property: mTracks (has opposite relationship)
    self.mTracks_property.undoManager = inUndoManager
    self.mTracks_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mNet_property.setProp (me) } },
      resetter: { inObject in inObject.mNet_property.setProp (nil) }
    )
    self.accumulateProperty (self.mTracks_property)
  //--- To one property: mNetClass (has opposite to many relationship: mNets)
    self.mNetClass_property.undoManager = inUndoManager
    self.mNetClass_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mNets_property.add (me) } },
      resetter: { [weak self] inObject in if let me = self { inObject.mNets_property.remove (me) } }
    )
    self.accumulateProperty (self.mNetClass_property)
  //--- Atomic property: netClassName
    self.netClassName_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mNetClass_property.mNetClassName_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_netClassName (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mNetClass_property.mNetClassName_property.startsBeingObserved (by: self.netClassName_property)
  //--- Atomic property: netClassTrackWidth
    self.netClassTrackWidth_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mNetClass_property.mTrackWidth_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_netClassTrackWidth (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mNetClass_property.mTrackWidth_property.startsBeingObserved (by: self.netClassTrackWidth_property)
  //--- Atomic property: netClassViaHoleDiameter
    self.netClassViaHoleDiameter_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mNetClass_property.mViaHoleDiameter_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_netClassViaHoleDiameter (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mNetClass_property.mViaHoleDiameter_property.startsBeingObserved (by: self.netClassViaHoleDiameter_property)
  //--- Atomic property: netClassViaPadDiameter
    self.netClassViaPadDiameter_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mNetClass_property.mViaPadDiameter_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_netClassViaPadDiameter (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mNetClass_property.mViaPadDiameter_property.startsBeingObserved (by: self.netClassViaPadDiameter_property)
  //--- Atomic property: wireColor
    self.wireColor_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mNetClass_property.mNetClassColor_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_wireColor (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mNetClass_property.mNetClassColor_property.startsBeingObserved (by: self.wireColor_property)
  //--- Atomic property: netSchematicPointsInfo
    self.netSchematicPointsInfo_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mPoints_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_netSchematicPointsInfo (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mPoints_property.toMany_netInfoForPoint_StartsBeingObserved (by: self.netSchematicPointsInfo_property)
  //--- Atomic property: trackCount
    self.trackCount_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mTracks_property.count_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_NetInProject_trackCount (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mTracks_property.startsBeingObserved (by: self.trackCount_property)
  //--- Install undoers and opposite setter for relationships
    self.mPoints_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mNet_property.setProp (me) } },
      resetter: { inObject in inObject.mNet_property.setProp (nil) }
    )
    self.mTracks_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mNet_property.setProp (me) } },
      resetter: { inObject in inObject.mNet_property.setProp (nil) }
    )
  //--- Register properties for handling signature
  //--- Extern delegates
   }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Extern delegates
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

