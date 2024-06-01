//
//  extension-BoardImage.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_IMAGE_CENTER  = 0
let BOARD_IMAGE_ROTATION_KNOB = 1

fileprivate let BOARD_IMAGE_ROTATION_KNOB_DISTANCE : CGFloat = 30.0

let DEFAULT_BOARD_IMAGE = "board-image-default"

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardImage
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardImage {

  //································································································

  func cursorForKnob_BoardImage (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == BOARD_IMAGE_CENTER {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == BOARD_IMAGE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  //································································································
  //  operationAfterPasting
  //································································································

  func operationAfterPasting_BoardImage (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //································································································
  //  Save into additional dictionary
  //································································································

  func saveIntoAdditionalDictionary_BoardImage (_ _ : inout [String : Any]) {
  }

  //································································································
  //  Translation
  //································································································

  func acceptedTranslation_BoardImage (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //································································································

  func acceptToTranslate_BoardImage (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //································································································

  func translate_BoardImage (xBy inDx : Int, yBy inDy : Int,
                             userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mCenterX += inDx
    self.mCenterY += inDy
  }

  //································································································
  //  Alignment Points
  //································································································

  func alignmentPoints_BoardImage () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //································································································
  //  Knob
  //································································································

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

  //································································································

  func move_BoardImage (knob inKnobIndex : Int,
                        proposedDx inDx : Int,
                        proposedDy inDy : Int,
                        unalignedMouseLocationX _ : Int,
                        unalignedMouseLocationY _ : Int,
                        alignedMouseLocationX inAlignedMouseLocationX : Int,
                        alignedMouseLocationY inAlignedMouseLocationY : Int,
                        shift _ : Bool) {
    if inKnobIndex == BOARD_IMAGE_CENTER {
      self.mCenterX += inDx
      self.mCenterY += inDy
    }else if inKnobIndex == BOARD_IMAGE_ROTATION_KNOB {
      let origin = CanariPoint (x: self.mCenterX, y: self.mCenterY).cocoaPoint
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).cocoaPoint
      let newAngleInDegrees = NSPoint.angleInDegrees (origin, newRotationKnobLocation)
      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
    }
  }

  //································································································
  //  Rotate 90°
  //································································································

  func canRotate90_BoardImage (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.mCenterX, y: self.mCenterY)
    return true
  }

  //································································································

  func rotate90Clockwise_BoardImage (from inRotationCenter : CanariPoint,
                                     userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p1.x
    self.mCenterY = p1.y
    ioSet.insert (self)
  }

  //································································································

  func rotate90CounterClockwise_BoardImage (from inRotationCenter : CanariPoint,
                                            userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p1.x
    self.mCenterY = p1.y
    ioSet.insert (self)
  }

  //································································································
  //   SNAP TO GRID
  //································································································

  func canSnapToGrid_BoardImage (_ inGrid : Int) -> Bool {
    var isAligned = self.mCenterX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mCenterY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //································································································

  func snapToGrid_BoardImage (_ inGrid : Int) {
    self.mCenterX.align (onGrid: inGrid)
    self.mCenterY.align (onGrid: inGrid)
  }

  //································································································
  //  operationBeforeRemoving
  //································································································

  func operationBeforeRemoving_BoardImage () {
  }

  //································································································
  //  HORIZONTAL FLIP
  //································································································

  func flipHorizontally_BoardImage () {
  }

  //································································································

  func canFlipHorizontally_BoardImage () -> Bool {
    return false
  }

  //································································································
  //  VERTICAL FLIP
  //································································································

  func flipVertically_BoardImage () {
  }

  //································································································

  func canFlipVertically_BoardImage () -> Bool {
    return false
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct BoardImageDisplayInfos {
  let rotationKnobLocation : NSPoint
  let backgroundBP : EBBezierPath
  let imageBP : EBBezierPath
  let productRectangles : [ProductRectangle]
  let nonRotatedRectangles : [NSRect]
  let affineTransform : AffineTransform
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func boardImage_displayInfos (centerX inCenterX : Int,
                                         centerY inCenterY : Int,
                                         _ inBoardImageDescriptor : BoardImageDescriptor,
                                         frontSide inFrontSide : Bool,
                                         pixelSizeInCanariUnit inPixelSize : Int,
                                         rotation inRotation : Int) -> BoardImageDisplayInfos {
  let pixelSize = canariUnitToCocoa (inPixelSize)
  let width = CGFloat (inBoardImageDescriptor.scaledImageWidth) * pixelSize
  let height = CGFloat (inBoardImageDescriptor.scaledImageHeight) * pixelSize
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
//--- Board image
  var filledBP = EBBezierPath ()
  var productRectangles = [ProductRectangle] ()
  var nonRotatedRectangles = [NSRect] ()
  for rect in inBoardImageDescriptor.blackRectangles {
    let x = CGFloat (rect.x) * pixelSize - width / 2.0
    let y = CGFloat (rect.y) * pixelSize - height / 2.0
    let w = CGFloat (rect.width) * pixelSize
    let h = CGFloat (rect.height) * pixelSize
    let r = NSRect (x: x, y: y, width: w, height: h)
    filledBP.appendRect (r)
    let center = af.transform (NSPoint (x: x + w / 2.0, y: y + h / 2.0))
    let size = NSSize (width: w, height: h)
    nonRotatedRectangles.append (NSRect (center: center, size: size))
    let p0 = af.transform (NSPoint (x: x,     y: y))
    let p1 = af.transform (NSPoint (x: x + w, y: y))
    let p2 = af.transform (NSPoint (x: x + w, y: y + h))
    let p3 = af.transform (NSPoint (x: x,     y: y + h))
    productRectangles.append (ProductRectangle (p0: p0, p1: p1, p2: p2, p3: p3))
  }
  let imageBP = filledBP.transformed (by: af)
//--- Rotation knob
  var rotationKnobTransform = AffineTransform ()
  rotationKnobTransform.translate (x: centerX, y: centerY)
  rotationKnobTransform.rotate (byDegrees: rotationInDegrees)
  let rotationKnobLocation = rotationKnobTransform.transform (NSPoint (x: BOARD_IMAGE_ROTATION_KNOB_DISTANCE, y: 0.0))
//---
  return BoardImageDisplayInfos (
    rotationKnobLocation: rotationKnobLocation,
    backgroundBP: backgroundBP,
    imageBP: imageBP,
    productRectangles: productRectangles,
    nonRotatedRectangles: nonRotatedRectangles,
    affineTransform: af
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
