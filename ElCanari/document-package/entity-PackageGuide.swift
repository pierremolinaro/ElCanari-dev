//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_y1 : AnyObject {
//   var y1 : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_x2 : AnyObject {
//   var x2 : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_y2 : AnyObject {
//   var y2 : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_x1Unit : AnyObject {
//   var x1Unit : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_y1Unit : AnyObject {
//   var y1Unit : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_x2Unit : AnyObject {
//   var x2Unit : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_y2Unit : AnyObject {
//   var y2Unit : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_x1 : AnyObject {
//   var x1 : Int { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_objectDisplay : AnyObject {
//   var objectDisplay : EBShape? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_selectionDisplay : AnyObject {
//   var selectionDisplay : EBShape? { get }
// }

//--------------------------------------------------------------------------------------------------

// Commented out, not used
// @MainActor protocol PackageGuide_issues : AnyObject {
//   var issues : CanariIssueArray? { get }
// }

//--------------------------------------------------------------------------------------------------
//    Entity: PackageGuide
//--------------------------------------------------------------------------------------------------

final class PackageGuide : PackageObject
    // PackageGuide_y1 // Commented out, not used
    // PackageGuide_x2 // Commented out, not used
    // PackageGuide_y2 // Commented out, not used
    // PackageGuide_x1Unit // Commented out, not used
    // PackageGuide_y1Unit // Commented out, not used
    // PackageGuide_x2Unit // Commented out, not used
    // PackageGuide_y2Unit // Commented out, not used
    // PackageGuide_x1 // Commented out, not used
    // PackageGuide_objectDisplay // Commented out, not used
    // PackageGuide_selectionDisplay // Commented out, not used
    // PackageGuide_issues // Commented out, not used
    {

  //------------------------------------------------------------------------------------------------
  //   Atomic property: y1
  //------------------------------------------------------------------------------------------------

  final let y1_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var y1 : Int {
    get { return self.y1_property.propval }
    set { self.y1_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: x2
  //------------------------------------------------------------------------------------------------

  final let x2_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var x2 : Int {
    get { return self.x2_property.propval }
    set { self.x2_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: y2
  //------------------------------------------------------------------------------------------------

  final let y2_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var y2 : Int {
    get { return self.y2_property.propval }
    set { self.y2_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: x1Unit
  //------------------------------------------------------------------------------------------------

  final let x1Unit_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var x1Unit : Int {
    get { return self.x1Unit_property.propval }
    set { self.x1Unit_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: y1Unit
  //------------------------------------------------------------------------------------------------

  final let y1Unit_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var y1Unit : Int {
    get { return self.y1Unit_property.propval }
    set { self.y1Unit_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: x2Unit
  //------------------------------------------------------------------------------------------------

  final let x2Unit_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var x2Unit : Int {
    get { return self.x2Unit_property.propval }
    set { self.x2Unit_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: y2Unit
  //------------------------------------------------------------------------------------------------

  final let y2Unit_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var y2Unit : Int {
    get { return self.y2Unit_property.propval }
    set { self.y2Unit_property.setProp (newValue) }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: x1
  //------------------------------------------------------------------------------------------------

  final let x1_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------

  final var x1 : Int {
    get { return self.x1_property.propval }
    set { self.x1_property.setProp (newValue) }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (_ inUndoManager : UndoManager?) {
    self.y1_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "y1")
    self.x2_property = EBStoredProperty_Int (defaultValue: 685800, undoManager: inUndoManager, key: "x2")
    self.y2_property = EBStoredProperty_Int (defaultValue: 685800, undoManager: inUndoManager, key: "y2")
    self.x1Unit_property = EBStoredProperty_Int (defaultValue: 2286, undoManager: inUndoManager, key: "x1Unit")
    self.y1Unit_property = EBStoredProperty_Int (defaultValue: 2286, undoManager: inUndoManager, key: "y1Unit")
    self.x2Unit_property = EBStoredProperty_Int (defaultValue: 2286, undoManager: inUndoManager, key: "x2Unit")
    self.y2Unit_property = EBStoredProperty_Int (defaultValue: 2286, undoManager: inUndoManager, key: "y2Unit")
    self.x1_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "x1")
    super.init (inUndoManager)
    self.accumulateProperty (self.y1_property)
    self.accumulateProperty (self.x2_property)
    self.accumulateProperty (self.y2_property)
    self.accumulateProperty (self.x1Unit_property)
    self.accumulateProperty (self.y1Unit_property)
    self.accumulateProperty (self.x2Unit_property)
    self.accumulateProperty (self.y2Unit_property)
    self.accumulateProperty (self.x1_property)
  //--- Atomic property: objectDisplay
    self.objectDisplay_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.x1_property.selection
        let s1 = unwSelf.y1_property.selection
        let s2 = unwSelf.x2_property.selection
        let s3 = unwSelf.y2_property.selection
        switch (s0, s1, s2, s3) {
        case (.single (let v0),
              .single (let v1),
              .single (let v2),
              .single (let v3)) :
          return .single (transient_PackageGuide_objectDisplay (v0, v1, v2, v3))
        case (.multiple,
              .multiple,
              .multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.x1_property.startsBeingObserved (by: self.objectDisplay_property)
    self.y1_property.startsBeingObserved (by: self.objectDisplay_property)
    self.x2_property.startsBeingObserved (by: self.objectDisplay_property)
    self.y2_property.startsBeingObserved (by: self.objectDisplay_property)
  //--- Atomic property: selectionDisplay
    self.selectionDisplay_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = preferences_selectionHiliteColor_property.selection
        let s1 = unwSelf.x1_property.selection
        let s2 = unwSelf.y1_property.selection
        let s3 = unwSelf.x2_property.selection
        let s4 = unwSelf.y2_property.selection
        let s5 = unwSelf.knobSize_property.selection
        switch (s0, s1, s2, s3, s4, s5) {
        case (.single (let v0),
              .single (let v1),
              .single (let v2),
              .single (let v3),
              .single (let v4),
              .single (let v5)) :
          return .single (transient_PackageGuide_selectionDisplay (v0, v1, v2, v3, v4, v5))
        case (.multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    preferences_selectionHiliteColor_property.startsBeingObserved (by: self.selectionDisplay_property)
    self.x1_property.startsBeingObserved (by: self.selectionDisplay_property)
    self.y1_property.startsBeingObserved (by: self.selectionDisplay_property)
    self.x2_property.startsBeingObserved (by: self.selectionDisplay_property)
    self.y2_property.startsBeingObserved (by: self.selectionDisplay_property)
    self.knobSize_property.startsBeingObserved (by: self.selectionDisplay_property)
  //--- Atomic property: issues
    self.issues_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.x1_property.selection
        let s1 = unwSelf.y1_property.selection
        let s2 = unwSelf.x2_property.selection
        let s3 = unwSelf.y2_property.selection
        switch (s0, s1, s2, s3) {
        case (.single (let v0),
              .single (let v1),
              .single (let v2),
              .single (let v3)) :
          return .single (transient_PackageGuide_issues (v0, v1, v2, v3))
        case (.multiple,
              .multiple,
              .multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.x1_property.startsBeingObserved (by: self.issues_property)
    self.y1_property.startsBeingObserved (by: self.issues_property)
    self.x2_property.startsBeingObserved (by: self.issues_property)
    self.y2_property.startsBeingObserved (by: self.issues_property)
  //--- Install undoers and opposite setter for relationships
  //--- Register properties for handling signature
    self.x1_property.setSignatureObserver (observer: self)
    self.x1Unit_property.setSignatureObserver (observer: self)
    self.x2_property.setSignatureObserver (observer: self)
    self.x2Unit_property.setSignatureObserver (observer: self)
    self.y1_property.setSignatureObserver (observer: self)
    self.y1Unit_property.setSignatureObserver (observer: self)
    self.y2_property.setSignatureObserver (observer: self)
    self.y2Unit_property.setSignatureObserver (observer: self)
  //--- Extern delegates
   }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Extern delegates
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   computeSignature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func computeSignature () -> UInt32 {
    var crc = super.computeSignature ()
    crc.accumulate (u32: self.x1_property.signature ())
    crc.accumulate (u32: self.x1Unit_property.signature ())
    crc.accumulate (u32: self.x2_property.signature ())
    crc.accumulate (u32: self.x2Unit_property.signature ())
    crc.accumulate (u32: self.y1_property.signature ())
    crc.accumulate (u32: self.y1Unit_property.signature ())
    crc.accumulate (u32: self.y2_property.signature ())
    crc.accumulate (u32: self.y2Unit_property.signature ())
    return crc
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    return self.cursorForKnob_PackageGuide (knob: inKnobIndex)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func acceptedTranslation (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return self.acceptedTranslation_PackageGuide (xBy: inDx, yBy: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return self.acceptToTranslate_PackageGuide (xBy: inDx, yBy: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func translate (xBy inDx: Int, yBy inDy: Int,
                           userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.translate_PackageGuide (xBy: inDx, yBy: inDy, userSet: &ioSet)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    return self.canMove_PackageGuide (
      knob: inKnobIndex,
      proposedUnalignedAlignedTranslation: inProposedUnalignedTranslation,
      proposedAlignedTranslation: inProposedAlignedTranslation,
      unalignedMouseDraggedLocation: inUnalignedMouseDraggedLocation,
      shift: inShift
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    self.move_PackageGuide (
      knob: inKnobIndex,
      proposedDx: inDx,
      proposedDy: inDy,
      unalignedMouseLocationX: inUnlignedMouseLocationX,
      unalignedMouseLocationY: inUnlignedMouseLocationY,
      alignedMouseLocationX: inAlignedMouseLocationX,
      alignedMouseLocationY: inAlignedMouseLocationY,
      shift: inShift
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Snap to grid
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func snapToGrid (_ inGrid : Int) {
    self.snapToGrid_PackageGuide (inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    return self.canSnapToGrid_PackageGuide (inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func flipHorizontally () {
    self.flipHorizontally_PackageGuide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func canFlipHorizontally () -> Bool {
    return self.canFlipHorizontally_PackageGuide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func flipVertically () {
    self.flipVertically_PackageGuide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func canFlipVertically () -> Bool {
    return self.canFlipVertically_PackageGuide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func canRotate90 (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return self.canRotate90_PackageGuide (accumulatedPoints: &accumulatedPoints)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func rotate90Clockwise (from inRotationCenter : CanariPoint,
                                   userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.rotate90Clockwise_PackageGuide (from: inRotationCenter, userSet: &ioSet)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func rotate90CounterClockwise (from inRotationCenter : CanariPoint,
                                          userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.rotate90CounterClockwise_PackageGuide (from: inRotationCenter, userSet: &ioSet)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func saveIntoAdditionalDictionary (_ ioDictionary : inout [String : Any]) {
    self.saveIntoAdditionalDictionary_PackageGuide (&ioDictionary)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func operationAfterPasting (additionalDictionary inDictionary : [String : Any],
                                       optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                       objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return self.operationAfterPasting_PackageGuide (additionalDictionary: inDictionary,
                                                      optionalDocument: inOptionalDocument,
                                                      objectArray: inObjectArray)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func alignmentPoints () -> Set <CanariPoint> {
    return self.alignmentPoints_PackageGuide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func operationBeforeRemoving () {
    self.operationBeforeRemoving_PackageGuide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  COPY AND PASTE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func canCopyAndPaste () -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

