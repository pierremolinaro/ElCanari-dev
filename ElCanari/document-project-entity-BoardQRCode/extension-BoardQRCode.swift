//
//  extension-BoardQRCode.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/04/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_QRCODE_ORIGIN_KNOB  = 0
let BOARD_QRCODE_ROTATION_KNOB  = 1

fileprivate let BOARD_QRCODE_ROTATION_KNOB_DISTANCE : CGFloat = 30.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardQRCode
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardQRCode {

  //····················································································································

  func cursorForKnob_BoardQRCode (knob inKnobIndex: Int) -> NSCursor? {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_BoardQRCode (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_BoardQRCode (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_BoardQRCode (xBy inDx : Int, yBy inDy : Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.mCenterX += inDx
    self.mCenterY += inDy
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_BoardQRCode (additionalDictionary inDictionary : [String : Any],
                                        optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                        objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return "" // Ok, no error
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_BoardQRCode (_ ioDictionary : inout [String : Any]) {
//    ioDictionary [FONT_NAME_IN_DICTIONARY] = self.fontName
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_BoardQRCode (knob inKnobIndex : Int,
                            proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                            proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                            unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                            shift inShift : Bool) -> CanariPoint {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else{
      return CanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  func move_BoardQRCode (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == BOARD_QRCODE_ORIGIN_KNOB {
      self.mCenterX += inDx
      self.mCenterY += inDy
    }else if inKnobIndex == BOARD_QRCODE_ROTATION_KNOB {
      let origin = CanariPoint (x: self.mCenterX, y: self.mCenterY).cocoaPoint
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).cocoaPoint
      let newAngleInDegrees = angleInDegreesBetweenNSPoints (origin, newRotationKnobLocation)
      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  func canSnapToGrid_BoardQRCode (_ inGrid : Int) -> Bool {
    var isAligned = self.mCenterX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mCenterY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  func snapToGrid_BoardQRCode (_ inGrid : Int) {
    self.mCenterX.align (onGrid: inGrid)
    self.mCenterY.align (onGrid: inGrid)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_BoardQRCode (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.mCenterX, y: self.mCenterY)
    return true
  }

  //····················································································································

  func rotate90Clockwise_BoardQRCode (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
    self.mRotation = (self.mRotation + degreesToCanariRotation (270.0)) % degreesToCanariRotation (360.0)
    ioSet.insert (self)
  }

  //····················································································································

  func rotate90CounterClockwise_BoardQRCode (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
    self.mRotation = (self.mRotation + degreesToCanariRotation (90.0)) % degreesToCanariRotation (360.0)
    ioSet.insert (self)
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_BoardQRCode () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  func operationBeforeRemoving_BoardQRCode () {
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_BoardQRCode () {
  }

  //····················································································································

  func canFlipHorizontally_BoardQRCode () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_BoardQRCode () {
  }

  //····················································································································

  func canFlipVertically_BoardQRCode () -> Bool {
    return false
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct QRCodeDisplayInfos {
  let rotationKnobLocation : NSPoint
  let backgroundBP : EBBezierPath
  let qrCodeBP : EBBezierPath
  let productRectangles : [ProductRectangle]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
  var tr = AffineTransform ()
  let centerX = canariUnitToCocoa (inCenterX)
  let centerY = canariUnitToCocoa (inCenterY)
  tr.translate (x: centerX, y: centerY)
  let rotationInDegrees = CGFloat (inRotation) / 1000.0
  tr.rotate (byDegrees: rotationInDegrees)
  if !inFrontSide {
    tr.scale (x: -1.0, y: 1.0)
  }
//--- Background
  let backgroundBP = EBBezierPath (rect: qrRect).transformed (by: tr)
//--- QR code
  var filledBP = EBBezierPath ()
  var productRectangles = [ProductRectangle] ()
  for rect in inQRCodeDescriptor.blackRectangles {
    let x = CGFloat (rect.x) * moduleSize - width / 2.0
    let y = CGFloat (rect.y) * moduleSize - height / 2.0
    let w = CGFloat (rect.width) * moduleSize
    let h = CGFloat (rect.height) * moduleSize
    let r = NSRect (x: x, y: y, width: w, height: h)
    filledBP.appendRect (r)
    let p0 = tr.transform (NSPoint (x: x,     y: y))
    let p1 = tr.transform (NSPoint (x: x + w, y: y))
    let p2 = tr.transform (NSPoint (x: x + w, y: y + h))
    let p3 = tr.transform (NSPoint (x: x,     y: y + h))
    productRectangles.append (ProductRectangle (p0: p0, p1: p1, p2: p2, p3: p3))
  }
  let qrCodeBP = filledBP.transformed (by: tr)
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
    productRectangles: productRectangles
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————