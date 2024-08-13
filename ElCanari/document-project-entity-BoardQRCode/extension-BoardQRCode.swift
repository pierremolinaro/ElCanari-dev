//
//  extension-BoardQRCode.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/04/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_QRCODE_ORIGIN_KNOB  = 0
let BOARD_QRCODE_ROTATION_KNOB  = 1

fileprivate let BOARD_QRCODE_ROTATION_KNOB_DISTANCE : CGFloat = 30.0

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardQRCode
//——————————————————————————————————————————————————————————————————————————————————————————————————

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

  func acceptedTranslation_BoardQRCode (xBy inDx : Int, yBy inDy : Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BoardQRCode (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BoardQRCode (xBy inDx : Int,
                              yBy inDy : Int,
                              userSet _ : inout EBReferenceSet <EBManagedObject>) {
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
//    ioDictionary [FONT_NAME_IN_DICTIONARY] = self.fontName
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
                         proposedDx inDx : Int,
                         proposedDy inDy : Int,
                         unalignedMouseLocationX _ : Int,
                         unalignedMouseLocationY _ : Int,
                         alignedMouseLocationX inAlignedMouseLocationX : Int,
                         alignedMouseLocationY inAlignedMouseLocationY : Int,
                         shift _ : Bool) {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      self.mCenterX += inDx
      self.mCenterY += inDy
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      let origin = CanariPoint (x: self.mCenterX, y: self.mCenterY).cocoaPoint
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).cocoaPoint
      let newAngleInDegrees = NSPoint.angleInDegrees (origin, newRotationKnobLocation)
      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BoardQRCode (_ inGrid : Int) -> Bool {
    var isAligned = self.mCenterX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mCenterY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardQRCode (_ inGrid : Int) {
    self.mCenterX.align (onGrid: inGrid)
    self.mCenterY.align (onGrid: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BoardQRCode (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.mCenterX, y: self.mCenterY)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BoardQRCode (from inRotationCenter : CanariPoint,
                                      userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
    self.mRotation = (self.mRotation + degreesToCanariRotation (270.0)) % degreesToCanariRotation (360.0)
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardQRCode (from inRotationCenter : CanariPoint,
                                             userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
    self.mRotation = (self.mRotation + degreesToCanariRotation (90.0)) % degreesToCanariRotation (360.0)
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

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct QRCodeDisplayInfos {
  let rotationKnobLocation : NSPoint
  let backgroundBP : EBBezierPath
  let qrCodeBP : EBBezierPath
  let productRectangles : [ProductRectangle]
  let transformedRectangles : [AffineTransform]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func boardQRCode_displayInfos (centerX inCenterX : Int,
                                          centerY inCenterY : Int,
                                          _ inQRCodeDescriptor : QRCodeDescriptor,
                                          frontSide inFrontSide : Bool,
                                          moduleSizeInCanariUnit inModuleSize : Int,
                                          rotation inRotation : Int) -> QRCodeDisplayInfos {
  let moduleSize = canariUnitToCocoa (inModuleSize)
  let width = CGFloat (inQRCodeDescriptor.imageWidth) * moduleSize
  let height = CGFloat (inQRCodeDescriptor.imageHeight) * moduleSize
  let qrRect = NSRect (center: .zero, size: NSSize (width: width, height: height))
//--- Affine transform
  var af = AffineTransform ()
  let centerX = canariUnitToCocoa (inCenterX)
  let centerY = canariUnitToCocoa (inCenterY)
  af.translate (x: centerX, y: centerY)
  let rotationInDegrees = CGFloat (inRotation) / 1000.0
  af.rotate (byDegrees: rotationInDegrees)
  if !inFrontSide {
    af.scale (x: -1.0, y: 1.0)
  }
//--- Background
  let backgroundBP = EBBezierPath (rect: qrRect).transformed (by: af)
//--- QR code
  var filledBP = EBBezierPath ()
  var productRectangles = [ProductRectangle] ()
  var transformedRectangles = [AffineTransform] ()
  for rect in inQRCodeDescriptor.blackRectangles {
    let x = CGFloat (rect.x) * moduleSize - width / 2.0
    let y = CGFloat (rect.y) * moduleSize - height / 2.0
    let w = CGFloat (rect.width) * moduleSize
    let h = CGFloat (rect.height) * moduleSize
    let r = NSRect (x: x, y: y, width: w, height: h)
    filledBP.appendRect (r)
    let p0 = af.transform (NSPoint (x: x,     y: y))
    let p1 = af.transform (NSPoint (x: x + w, y: y))
    let p2 = af.transform (NSPoint (x: x + w, y: y + h))
    let p3 = af.transform (NSPoint (x: x,     y: y + h))
    productRectangles.append (ProductRectangle (p0: p0, p1: p1, p2: p2, p3: p3))
//    let size = NSSize (width: w, height: h)
  //---
    var rectAF = af
    rectAF.translate (x: x + w / 2.0, y: y + h / 2.0)
    rectAF.scale (x: w, y: h)
    transformedRectangles.append (rectAF)
  }
  let qrCodeBP = filledBP.transformed (by: af)
//--- Rotation knob
  var rotationKnobTransform = AffineTransform ()
  rotationKnobTransform.translate (x: centerX, y: centerY)
  rotationKnobTransform.rotate (byDegrees: rotationInDegrees)
  let rotationKnobLocation = rotationKnobTransform.transform (NSPoint (x: BOARD_QRCODE_ROTATION_KNOB_DISTANCE, y: 0.0))
//---
  return QRCodeDisplayInfos (
    rotationKnobLocation: rotationKnobLocation,
    backgroundBP: backgroundBP,
    qrCodeBP: qrCodeBP,
    productRectangles: productRectangles,
    transformedRectangles: transformedRectangles
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
