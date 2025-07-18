//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol SchematicObject_issues : AnyObject {
//   var issues : CanariIssueArray? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol SchematicObject_connectedPoints : AnyObject {
//   var connectedPoints : CanariPointArray? { get }
// }

//--------------------------------------------------------------------------------------------------

@MainActor protocol SchematicObject_wires : AnyObject {
  var wires : CanariWireArray? { get }
}

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol SchematicObject_sheetDescriptor : AnyObject {
//   var sheetDescriptor : SchematicSheetDescriptor? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol SchematicObject_selectionDisplay : AnyObject {
//   var selectionDisplay : EBShape? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol SchematicObject_objectDisplay : AnyObject {
//   var objectDisplay : EBShape? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol SchematicObject_isPlacedInSchematic : AnyObject {
//   var isPlacedInSchematic : Bool? { get }
// }

//--------------------------------------------------------------------------------------------------
//    Entity: SchematicObject
//--------------------------------------------------------------------------------------------------

class SchematicObject : EBGraphicManagedObject
    // SchematicObject_issues // Commented out, not used
    // SchematicObject_connectedPoints // Commented out, not used
    , SchematicObject_wires
    // SchematicObject_sheetDescriptor // Commented out, not used
    // SchematicObject_selectionDisplay // Commented out, not used
    // SchematicObject_objectDisplay // Commented out, not used
    // SchematicObject_isPlacedInSchematic // Commented out, not used
    {

  //------------------------------------------------------------------------------------------------
  //   To one property: mSheet
  //------------------------------------------------------------------------------------------------

  final let mSheet_property = StoredObject_SheetInProject (usedForSignature: false, strongRef: false, key: "mSheet")

  //------------------------------------------------------------------------------------------------

  final var mSheet : SheetInProject? {
    get {
      return self.mSheet_property.propval
    }
    set {
      // self.mSheet_property.setProp (newValue)
      if self.mSheet_property.propval !== newValue {
        if self.mSheet_property.propval != nil {
          self.mSheet_property.setProp (nil)
        }
        if newValue != nil {
          self.mSheet_property.setProp (newValue)
        }
      }
    }
  }

  //------------------------------------------------------------------------------------------------

  final let mSheet_none = EBTransientProperty <Bool> ()

  //------------------------------------------------------------------------------------------------
  //   Transient property: issues
  //------------------------------------------------------------------------------------------------

  final let issues_property = EBTransientProperty <CanariIssueArray> ()

  //------------------------------------------------------------------------------------------------

  final var issues : CanariIssueArray? {
    return self.issues_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: connectedPoints
  //------------------------------------------------------------------------------------------------

  final let connectedPoints_property = EBTransientProperty <CanariPointArray> ()

  //------------------------------------------------------------------------------------------------

  final var connectedPoints : CanariPointArray? {
    return self.connectedPoints_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: wires
  //------------------------------------------------------------------------------------------------

  final let wires_property = EBTransientProperty <CanariWireArray> ()

  //------------------------------------------------------------------------------------------------

  final var wires : CanariWireArray? {
    return self.wires_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: sheetDescriptor
  //------------------------------------------------------------------------------------------------

  final let sheetDescriptor_property = EBTransientProperty <SchematicSheetDescriptor> ()

  //------------------------------------------------------------------------------------------------

  final var sheetDescriptor : SchematicSheetDescriptor? {
    return self.sheetDescriptor_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: isPlacedInSchematic
  //------------------------------------------------------------------------------------------------

  final let isPlacedInSchematic_property = EBTransientProperty <Bool> ()

  //------------------------------------------------------------------------------------------------

  final var isPlacedInSchematic : Bool? {
    return self.isPlacedInSchematic_property.optionalValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (_ inUndoManager : UndoManager?) {
    super.init (inUndoManager)
    self.mSheet_none.mReadModelFunction = { [weak self] in
      if let uwSelf = self {
        return .single (uwSelf.mSheet_property.propval == nil)
      }else{
        return .empty
      }
    }
    self.mSheet_property.startsBeingObserved (by: self.mSheet_none)
  //--- To one property: mSheet (has opposite to many relationship: mObjects)
    self.mSheet_property.undoManager = inUndoManager
    self.mSheet_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mObjects_property.add (me) } },
      resetter: { [weak self] inObject in if let me = self { inObject.mObjects_property.remove (me) } }
    )
    self.accumulateProperty (self.mSheet_property)
  //--- Atomic property: sheetDescriptor
    self.sheetDescriptor_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mSheet_property.sheetDescriptor_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_SchematicObject_sheetDescriptor (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mSheet_property.sheetDescriptor_property.startsBeingObserved (by: self.sheetDescriptor_property)
  //--- Atomic property: isPlacedInSchematic
    self.isPlacedInSchematic_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mSheet_none.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_SchematicObject_isPlacedInSchematic (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mSheet_property.startsBeingObserved (by: self.isPlacedInSchematic_property)
  //--- Install undoers and opposite setter for relationships
  //--- Register properties for handling signature
  //--- Extern delegates
   }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Extern delegates
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

