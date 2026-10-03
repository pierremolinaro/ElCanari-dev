//
//  extension-BoardImage.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let BOARD_IMAGE_CENTER  = 0
let BOARD_IMAGE_ROTATION_KNOB = 1

fileprivate let BOARD_IMAGE_ROTATION_KNOB_DISTANCE = CanariLength.pt (30.0)

let DEFAULT_BOARD_IMAGE = "board-image-default"

//--------------------------------------------------------------------------------------------------
//   EXTENSION BoardImage
//--------------------------------------------------------------------------------------------------

extension BoardImage {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_BoardImage (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == BOARD_IMAGE_CENTER {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == BOARD_IMAGE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_BoardImage (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_BoardImage (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_BoardImage (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BoardImage (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BoardImage (xBy inDx : CanariLength, yBy inDy : CanariLength,
                             userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mCenterX += inDx
    self.mCenterY += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_BoardImage () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_BoardImage (knob inKnobIndex : Int,
                           proposedUnalignedAlignedTranslation _ : CanariPoint,
                           proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                           unalignedMouseDraggedLocation _ : CanariPoint,
                           shift _ : Bool) -> CanariPoint {
    if inKnobIndex == BOARD_IMAGE_CENTER {
      return inProposedAlignedTranslation
    }else if inKnobIndex == BOARD_IMAGE_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else{
      return .zero
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_BoardImage (knob inKnobIndex : Int,
                        proposedDx inDx : CanariLength,
                        proposedDy inDy : CanariLength,
                        unalignedMouseLocationX _ : CanariLength,
                        unalignedMouseLocationY _ : CanariLength,
                        alignedMouseLocationX inAlignedMouseLocationX : CanariLength,
                        alignedMouseLocationY inAlignedMouseLocationY : CanariLength,
                        shift _ : Bool) {
    if inKnobIndex == BOARD_IMAGE_CENTER {
      self.mCenterX += inDx
      self.mCenterY += inDy
    }else if inKnobIndex == BOARD_IMAGE_ROTATION_KNOB {
      let origin = NSPoint (x: self.mCenterX, y: self.mCenterY)
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).ptValue
//      let newAngleInDegrees = NSPoint.angleInDegrees (origin, newRotationKnobLocation)
//      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
      self.mRotation = origin.angle (to: newRotationKnobLocation)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BoardImage (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.mCenterX, y: self.mCenterY)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BoardImage (from inRotationCenter : CanariPoint,
                                     userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p1.x
    self.mCenterY = p1.y
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardImage (from inRotationCenter : CanariPoint,
                                            userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p1.x
    self.mCenterY = p1.y
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BoardImage (_ inGrid : CanariLength) -> Bool {
    var isAligned = self.mCenterX.isAligned (on: inGrid)
    if isAligned {
      isAligned = self.mCenterY.isAligned (on: inGrid)
    }
    return !isAligned
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardImage (_ inGrid : CanariLength) {
    self.mCenterX.align (on: inGrid)
    self.mCenterY.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_BoardImage () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_BoardImage () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_BoardImage () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_BoardImage () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_BoardImage () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

struct BoardImageDisplayInfos {
  let rotationKnobLocation : CanariPoint
  let backgroundBP : BezierPath
  let imageBP : BezierPath
  let productRectangles : [ProductRectangle]
  let transformedRectangles : [CanariAffinity]
}

//--------------------------------------------------------------------------------------------------

@MainActor func boardImage_displayInfos (centerX inCenterX : CanariLength,
                                         centerY inCenterY : CanariLength,
                                         _ inBoardImageDescriptor : BoardImageDescriptor,
                                         frontSide inFrontSide : Bool,
                                         pixelSizeInCanariUnit inPixelSize : CanariLength,
                                         rotation inRotation : CanariAngle) -> BoardImageDisplayInfos {
  let pixelSize = inPixelSize
  let width = CGFloat (inBoardImageDescriptor.scaledImageWidth) * pixelSize
  let height = CGFloat (inBoardImageDescriptor.scaledImageHeight) * pixelSize
  let qrRect = NSRect (center: .zero, size: NSSize (width: width, height: height))
//--- Affine transform
  var af = CanariAffinity
    .translating (x: inCenterX, y: inCenterY)
    .rotating (by: inRotation)
  if !inFrontSide {
    af.scale (x: -1.0, y: 1.0)
  }
//--- Background
  let backgroundBP = BezierPath (rect: qrRect).transformed (by: af)
//--- Board image
  var filledBP = BezierPath ()
  var productRectangles = [ProductRectangle] ()
  var transformedRectangles = [CanariAffinity] ()
  for rect in inBoardImageDescriptor.blackRectangles {
    let x = CGFloat (rect.x) * pixelSize - width / 2.0
    let y = CGFloat (rect.y) * pixelSize - height / 2.0
    let w = CGFloat (rect.width) * pixelSize
    let h = CGFloat (rect.height) * pixelSize
    let r = NSRect (x: x, y: y, width: w, height: h)
    filledBP.appendRect (r)
    let p0 = af.transforming (CanariPoint (x: x,     y: y))
    let p1 = af.transforming (CanariPoint (x: x + w, y: y))
    let p2 = af.transforming (CanariPoint (x: x + w, y: y + h))
    let p3 = af.transforming (CanariPoint (x: x,     y: y + h))
    productRectangles.append (ProductRectangle (p0: p0, p1: p1, p2: p2, p3: p3))
  //---
    var rectAF = af
    rectAF.translate (x: x + w / 2.0, y: y + h / 2.0)
    rectAF.scale (x: w.ptValue, y: h.ptValue)
    transformedRectangles.append (rectAF)
  }
  let imageBP = filledBP.transformed (by: af)
//--- Rotation knob
  let rotationKnobTransform = CanariAffinity
    .translating (x: inCenterX, y: inCenterY)
    .rotating (by: inRotation)
  let rotationKnobLocation = rotationKnobTransform.transforming (CanariPoint (x: BOARD_IMAGE_ROTATION_KNOB_DISTANCE))
//---
  return BoardImageDisplayInfos (
    rotationKnobLocation: rotationKnobLocation,
    backgroundBP: backgroundBP,
    imageBP: imageBP,
    productRectangles: productRectangles,
    transformedRectangles: transformedRectangles
  )
}

//--------------------------------------------------------------------------------------------------
