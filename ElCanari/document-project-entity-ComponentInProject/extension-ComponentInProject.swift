//
//  extension-ComponentInProject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let COMPONENT_PACKAGE_CENTER_KNOB  = 0
let COMPONENT_PACKAGE_ROTATION_KNOB  = 1
let COMPONENT_PACKAGE_NAME_KNOB  = 2
let COMPONENT_PACKAGE_VALUE_KNOB = 3

//——————————————————————————————————————————————————————————————————————————————————————————————————

let COMPONENT_PACKAGE_ROTATION_KNOB_DISTANCE : CGFloat = 10.0

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION ComponentInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension ComponentInProject {

  //································································································

  func cursorForKnob_ComponentInProject (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == COMPONENT_PACKAGE_VALUE_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else{
      return nil
    }
  }

  //································································································
  //  Translation
  //································································································

  func acceptedTranslation_ComponentInProject (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //································································································

  func acceptToTranslate_ComponentInProject (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //································································································

  func translate_ComponentInProject (xBy inDx : Int, yBy inDy : Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  //································································································
  //  operationAfterPasting
  //································································································

  func operationAfterPasting_ComponentInProject (additionalDictionary _ : [String : Any],
                                                 optionalDocument _ : EBAutoLayoutManagedDocument?,
                                                 objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //································································································
  //  HORIZONTAL FLIP
  //································································································

  func flipHorizontally_ComponentInProject () {
  }

  //································································································

  func canFlipHorizontally_ComponentInProject () -> Bool {
    return false
  }

  //································································································
  //  VERTICAL FLIP
  //································································································

  func flipVertically_ComponentInProject () {
  }

  //································································································

  func canFlipVertically_ComponentInProject () -> Bool {
    return false
  }

  //································································································
  //  Save into additional dictionary
  //································································································

  func saveIntoAdditionalDictionary_ComponentInProject (_ _ : inout [String : Any]) {
  }

  //································································································
  //  Knob
  //································································································

  func canMove_ComponentInProject (knob inKnobIndex : Int,
                                   proposedUnalignedAlignedTranslation _ : CanariPoint,
                                   proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                   unalignedMouseDraggedLocation _ : CanariPoint,
                                   shift _ : Bool) -> CanariPoint {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == COMPONENT_PACKAGE_VALUE_KNOB {
      return inProposedAlignedTranslation
    }else{
      return CanariPoint (x: 0, y: 0)
    }
  }

  //································································································

  func move_ComponentInProject (knob inKnobIndex: Int,
                                proposedDx inDx: Int,
                                proposedDy inDy: Int,
                                unalignedMouseLocationX _ : Int,
                                unalignedMouseLocationY _ : Int,
                                alignedMouseLocationX inAlignedMouseLocationX : Int,
                                alignedMouseLocationY inAlignedMouseLocationY : Int,
                                shift _ : Bool) {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      self.mX += inDx
      self.mY += inDy
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      let absoluteCenter = CanariPoint (x: self.mX, y: self.mY).cocoaPoint
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).cocoaPoint
      let newAngleInDegrees = NSPoint.angleInDegrees (absoluteCenter, newRotationKnobLocation)
      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      self.mXName += inDx
      self.mYName += inDy
    }else if inKnobIndex == COMPONENT_PACKAGE_VALUE_KNOB {
      self.mXValue += inDx
      self.mYValue += inDy
    }
  }

  //································································································
  //   SNAP TO GRID
  //································································································

  func canSnapToGrid_ComponentInProject (_ inGrid : Int) -> Bool {
    var isAligned = self.mX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mXName.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mYName.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mXValue.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mYValue.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //································································································

  func snapToGrid_ComponentInProject (_ inGrid : Int) {
    self.mX.align (onGrid: inGrid)
    self.mY.align (onGrid: inGrid)
    self.mXName.align (onGrid: inGrid)
    self.mYName.align (onGrid: inGrid)
    self.mXValue.align (onGrid: inGrid)
    self.mYValue.align (onGrid: inGrid)
  }

  //································································································
  //  Rotate 90°
  //································································································

  func canRotate90_ComponentInProject (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    if let padRect = self.selectedPackagePadsRect () {
      accumulatedPoints.insert (padRect.center.canariPoint)
      return true
    }else{
      return false
    }
  }

  //································································································

  func rotate90Clockwise_ComponentInProject (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    self.mRotation = (self.mRotation + 270_000) % 360_000
    ioSet.insert (self)
  }

  //································································································

  func rotate90CounterClockwise_ComponentInProject (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    self.mRotation = (self.mRotation + 90_000) % 360_000
    ioSet.insert (self)
  }

  //································································································
  //  REMOVING
  //································································································

  func operationBeforeRemoving_ComponentInProject () {
    for connector in self.mConnectors.values {
    //--- Assign pad location to connector
      let descriptor : ComponentPadDescriptor = self.componentPadDictionary! [connector.mComponentPadName]!
      let pad = descriptor.pads [connector.mPadIndex]
      connector.mX = cocoaToCanariUnit (pad.location.x)
      connector.mY = cocoaToCanariUnit (pad.location.y)
    //--- Detach from component
      connector.mComponent = nil
      connector.mComponentPadName = ""
    //--- Delete connector ?
      if (connector.mComponent == nil) && (connector.mTracksP1.count == 0) && (connector.mTracksP2.count == 0) {
        connector.mRoot = nil // Remove from board objects
      }
    }
  //--- Remove unused devices
    if let rootObject = self.mRoot {
      DispatchQueue.main.async { rootObject.removeUnusedDevices () }
    }
  }

  //································································································
  //  Alignment Points
  //································································································

  func alignmentPoints_ComponentInProject () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //································································································

  func affineTransformFromPackage () -> AffineTransform {
    let packagePadDictionary : PackageMasterPadDictionary = self.packagePadDictionary!
    let padRect = packagePadDictionary.padsRect
    let center = padRect.center.cocoaPoint
    var af = AffineTransform ()
    af.translate (x: canariUnitToCocoa (self.mX), y: canariUnitToCocoa (self.mY))
    af.rotate (byDegrees: CGFloat (self.mRotation) / 1000.0)
    if self.mSide == .back {
      af.scale (x: -1.0, y: 1.0)
    }
    af.translate (x: -center.x, y: -center.y)
    return af
  }
  
  //································································································

  func packageToComponentAffineTransform () -> AffineTransform {
    let packagePadDictionary : PackageMasterPadDictionary = self.packagePadDictionary!
    let center = packagePadDictionary.padsRect.center.cocoaPoint
    var af = AffineTransform ()
    af.translate (x: canariUnitToCocoa (self.mX), y: canariUnitToCocoa (self.mY))
    af.rotate (byDegrees: CGFloat (self.mRotation) / 1000.0)
    if self.mSide == .back {
      af.scale (x: -1.0, y: 1.0)
    }
    af.translate (x: -center.x, y: -center.y)
    return af
  }

  //································································································

  func selectedPackagePadsRect () -> NSRect? {
    if let inBoard = self.isPlacedInBoard, inBoard, let padDictionary = self.packagePadDictionary {
      let af = self.packageToComponentAffineTransform ()
      var padCenters = [NSPoint] ()
      for (_, masterPad) in padDictionary {
        padCenters.append (af.transform (masterPad.center.cocoaPoint))
        for slavePad in masterPad.slavePads {
          padCenters.append (af.transform (slavePad.center.cocoaPoint))
        }
      }
      return NSRect (points: padCenters)
    }else{
      return nil
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
