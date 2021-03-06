//
//  extension-ComponentInProject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let COMPONENT_PACKAGE_CENTER_KNOB  = 0
let COMPONENT_PACKAGE_ROTATION_KNOB  = 1
let COMPONENT_PACKAGE_NAME_KNOB  = 2
let COMPONENT_PACKAGE_VALUE_KNOB = 3

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let COMPONENT_PACKAGE_ROTATION_KNOB_DISTANCE : CGFloat = 10.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION ComponentInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ComponentInProject {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
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

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx : Int, yBy inDy : Int, userSet ioSet : ObjcObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint,
                         shift inShift : Bool) -> ObjcCanariPoint {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == COMPONENT_PACKAGE_VALUE_KNOB {
      return inProposedAlignedTranslation
    }else{
      return ObjcCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      self.mX += inDx
      self.mY += inDy
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      let absoluteCenter = CanariPoint (x: self.mX, y: self.mY).cocoaPoint
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).cocoaPoint
      let newAngleInDegrees = angleInDegreesBetweenNSPoints (absoluteCenter, newRotationKnobLocation)
      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      self.mXName += inDx
      self.mYName += inDy
    }else if inKnobIndex == COMPONENT_PACKAGE_VALUE_KNOB {
      self.mXValue += inDx
      self.mYValue += inDy
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var isAligned = self.mX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.mX.align (onGrid: inGrid)
    self.mY.align (onGrid: inGrid)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    if let padRect = self.selectedPackagePadsRect () {
      accumulatedPoints.insert (padRect.center.canariPoint)
      return true
    }else{
      return false
    }
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    self.mRotation = (self.mRotation + 270_000) % 360_000
    ioSet.insert (self)
  }

  //····················································································································

  override func rotate90CounterClockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    self.mRotation = (self.mRotation + 90_000) % 360_000
    ioSet.insert (self)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func operationBeforeRemoving () {
    for connector in self.mConnectors {
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
  }

  //····················································································································

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
  
  //····················································································································

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

  //····················································································································

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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
