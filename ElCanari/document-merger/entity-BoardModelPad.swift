//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol BoardModelPad_y : AnyObject {
  var y : Int { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol BoardModelPad_width : AnyObject {
  var width : Int { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol BoardModelPad_height : AnyObject {
  var height : Int { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol BoardModelPad_shape : AnyObject {
  var shape : PadShape { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol BoardModelPad_rotation : AnyObject {
  var rotation : Int { get }
}

//--------------------------------------------------------------------------------------------------

@MainActor protocol BoardModelPad_x : AnyObject {
  var x : Int { get }
}

//--------------------------------------------------------------------------------------------------
//    Entity: BoardModelPad
//--------------------------------------------------------------------------------------------------

final class BoardModelPad : EBManagedObject
    , BoardModelPad_y
    , BoardModelPad_width
    , BoardModelPad_height
    , BoardModelPad_shape
    , BoardModelPad_rotation
    , BoardModelPad_x
    {

  //------------------------------------------------------------------------------------------------
  //   Atomic property: y
  //------------------------------------------------------------------------------------------------

  final let y_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var y : Int {
    get { return self.y_property.propval }
    set { self.y_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: width
  //------------------------------------------------------------------------------------------------

  final let width_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var width : Int {
    get { return self.width_property.propval }
    set { self.width_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: height
  //------------------------------------------------------------------------------------------------

  final let height_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var height : Int {
    get { return self.height_property.propval }
    set { self.height_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: shape
  //------------------------------------------------------------------------------------------------

  final let shape_property : EBStoredProperty_PadShape

  //------------------------------------------------------------------------------------------------

  final var shape : PadShape {
    get { return self.shape_property.propval }
    set { self.shape_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: rotation
  //------------------------------------------------------------------------------------------------

  final let rotation_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var rotation : Int {
    get { return self.rotation_property.propval }
    set { self.rotation_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: x
  //------------------------------------------------------------------------------------------------

  final let x_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var x : Int {
    get { return self.x_property.propval }
    set { self.x_property.setProp (newValue) }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (_ inUndoManager : UndoManager?) {
    self.y_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "y")
    self.width_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "width")
    self.height_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "height")
    self.shape_property = EBStoredProperty_PadShape (defaultValue: PadShape.rect, undoManager: inUndoManager, key: "shape")
    self.rotation_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "rotation")
    self.x_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "x")
    super.init (inUndoManager)
    self.accumulateProperty (self.y_property)
    self.accumulateProperty (self.width_property)
    self.accumulateProperty (self.height_property)
    self.accumulateProperty (self.shape_property)
    self.accumulateProperty (self.rotation_property)
    self.accumulateProperty (self.x_property)
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

