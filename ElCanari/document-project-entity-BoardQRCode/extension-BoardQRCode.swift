//
//  extension-BoardQRCode.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/04/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let BOARD_QRCODE_ORIGIN_KNOB  = 0
let BOARD_QRCODE_ROTATION_KNOB  = 1

fileprivate let BOARD_QRCODE_ROTATION_KNOB_DISTANCE = CanariLength.pt (30.0)

//--------------------------------------------------------------------------------------------------
//   EXTENSION BoardQRCode
//--------------------------------------------------------------------------------------------------

extension BoardQRCode {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_BoardQRCode (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_BoardQRCode (xBy inDx : CanariLength, yBy inDy : CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BoardQRCode (xBy inDx : CanariLength, yBy inDy : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BoardQRCode (xBy inDx : CanariLength,
                              yBy inDy : CanariLength,
                              userSet ioUserSet : inout EBReferenceSet <EBManagedObject>) {
    self.mCenterX += inDx
    self.mCenterY += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_BoardQRCode (additionalDictionary _ : [String : Any],
                                          optionalDocument _ : EBAutoLayoutManagedDocument?,
                                          objectArray _ : [EBGraphicManagedObject]) -> String {
    return "" // Ok, no error
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_BoardQRCode (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_BoardQRCode (knob inKnobIndex : Int,
                            proposedUnalignedAlignedTranslation _ : CanariPoint,
                            proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                            unalignedMouseDraggedLocation _ : CanariPoint,
                            shift _ : Bool) -> CanariPoint {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else{
      return .zero
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_BoardQRCode (knob inKnobIndex : Int,
                         proposedDx inDx : CanariLength,
                         proposedDy inDy : CanariLength,
                         unalignedMouseLocationX _ : CanariLength,
                         unalignedMouseLocationY _ : CanariLength,
                         alignedMouseLocationX inAlignedMouseLocationX : CanariLength,
                         alignedMouseLocationY inAlignedMouseLocationY : CanariLength,
                         shift _ : Bool) {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      self.mCenterX += inDx
      self.mCenterY += inDy
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      let origin = NSPoint (x: self.mCenterX, y: self.mCenterY)
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).ptValue
//      let newAngleInDegrees = NSPoint.angleInDegrees (origin, newRotationKnobLocation)
      self.mRotation = origin.angle (to: newRotationKnobLocation)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BoardQRCode (_ inGrid : CanariLength) -> Bool {
    var isAligned = self.mCenterX.isAligned (on: inGrid)
    if isAligned {
      isAligned = self.mCenterY.isAligned (on: inGrid)
    }
    return !isAligned
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardQRCode (_ inGrid : CanariLength) {
    self.mCenterX.align (on: inGrid)
    self.mCenterY.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BoardQRCode (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.mCenterX, y: self.mCenterY)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BoardQRCode (from inRotationCenter : CanariPoint,
                                      userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
//    self.mRotation = (self.mRotation + degreesToCanariRotation (270.0)) % degreesToCanariRotation (360.0)
    self.mRotation += .degrees270
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardQRCode (from inRotationCenter : CanariPoint,
                                             userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
//    self.mRotation = (self.mRotation + degreesToCanariRotation (90.0)) % degreesToCanariRotation (360.0)
    self.mRotation += .degrees90
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_BoardQRCode () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  REMOVING
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_BoardQRCode () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_BoardQRCode () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_BoardQRCode () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_BoardQRCode () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_BoardQRCode () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

struct QRCodeDisplayInfos {
  let rotationKnobLocation : CanariPoint
  let backgroundBP : BezierPath
  let qrCodeBP : BezierPath
  let productRectangles : [ProductRectangle]
  let transformedRectangles : [CanariAffinity]
}

//--------------------------------------------------------------------------------------------------

@MainActor func boardQRCode_displayInfos (centerX inCenterX : CanariLength,
                                          centerY inCenterY : CanariLength,
                                          _ inQRCodeDescriptor : QRCodeDescriptor,
                                          frontSide inFrontSide : Bool,
                                          moduleSizeInCanariUnit inModuleSize : CanariLength,
                                          rotation inRotation : CanariAngle) -> QRCodeDisplayInfos {
  let moduleSize = inModuleSize
  let width = inQRCodeDescriptor.imageWidth * moduleSize
  let height = inQRCodeDescriptor.imageHeight * moduleSize
  let qrRect = CanariRect (center: .zero, size: CanariSize (width: width, height: height))
//--- Affine transform
  var af = CanariAffinity
    .translating (x: inCenterX, y: inCenterY)
    .rotating (by: inRotation)
  if !inFrontSide {
    af.scale (x: -1.0, y: 1.0)
  }
//--- Background
  let backgroundBP = BezierPath (rect: qrRect).transformed (by: af)
//--- QR code
  var filledBP = BezierPath ()
  var productRectangles = [ProductRectangle] ()
  var transformedRectangles = [CanariAffinity] ()
  for rect in inQRCodeDescriptor.blackRectangles {
    let x = CGFloat (rect.x) * moduleSize - width / 2.0
    let y = CGFloat (rect.y) * moduleSize - height / 2.0
    let w = CGFloat (rect.width) * moduleSize
    let h = CGFloat (rect.height) * moduleSize
    let r = CanariRect (left: x, bottom: y, width: w, height: h)
    filledBP.appendRect (r)
    let p0 = af.transforming (x: x,     y: y)
    let p1 = af.transforming (x: x + w, y: y)
    let p2 = af.transforming (x: x + w, y: y + h)
    let p3 = af.transforming (x: x,     y: y + h)
    productRectangles.append (ProductRectangle (p0: p0, p1: p1, p2: p2, p3: p3))
//    let size = NSSize (width: w, height: h)
  //---
    var rectAF = af
    rectAF.translate (x: x + w / 2.0, y: y + h / 2.0)
    rectAF.scale (x: w.ptValue, y: h.ptValue)
    transformedRectangles.append (rectAF)
  }
  let qrCodeBP = filledBP.transformed (by: af)
//--- Rotation knob
  let rotationKnobTransform = CanariAffinity
    .translating (x: inCenterX, y: inCenterY)
    .rotating (by: inRotation)
  let rotationKnobLocation = rotationKnobTransform.transforming (x: BOARD_QRCODE_ROTATION_KNOB_DISTANCE)
//---
  return QRCodeDisplayInfos (
    rotationKnobLocation: rotationKnobLocation,
    backgroundBP: backgroundBP,
    qrCodeBP: qrCodeBP,
    productRectangles: productRectangles,
    transformedRectangles: transformedRectangles
  )
}

//--------------------------------------------------------------------------------------------------
