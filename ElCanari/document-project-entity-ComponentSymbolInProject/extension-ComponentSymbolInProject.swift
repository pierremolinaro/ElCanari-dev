//
//  extension-ComponentSymbolInProject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_IN_SCHEMATICS_CENTER_KNOB = 0
let SYMBOL_IN_SCHEMATICS_COMPONENT_NAME_KNOB = 1
let SYMBOL_IN_SCHEMATICS_COMPONENT_VALUE_KNOB = 2
let SYMBOL_IN_SCHEMATICS_ROTATION_KNOB = 3

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ComponentSymbolInProject {

  //····················································································································

  func cursorForKnob_ComponentSymbolInProject (knob inKnobIndex: Int) -> NSCursor? {
    if inKnobIndex == SYMBOL_IN_SCHEMATICS_CENTER_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == SYMBOL_IN_SCHEMATICS_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else if inKnobIndex == SYMBOL_IN_SCHEMATICS_COMPONENT_NAME_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == SYMBOL_IN_SCHEMATICS_COMPONENT_VALUE_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else{
      return nil
    }
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_ComponentSymbolInProject (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_ComponentSymbolInProject (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_ComponentSymbolInProject (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.mCenterX += inDx
    self.mCenterY += inDy
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_ComponentSymbolInProject (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_ComponentSymbolInProject (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_ComponentSymbolInProject (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_ComponentSymbolInProject (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == SYMBOL_IN_SCHEMATICS_CENTER_KNOB {
      self.mCenterX += inDx
      self.mCenterY += inDy
    }else if inKnobIndex == SYMBOL_IN_SCHEMATICS_COMPONENT_NAME_KNOB {
      self.mDisplayComponentNameOffsetX += inDx
      self.mDisplayComponentNameOffsetY += inDy
    }else if inKnobIndex == SYMBOL_IN_SCHEMATICS_COMPONENT_VALUE_KNOB {
      self.mDisplayComponentValueOffsetX += inDx
      self.mDisplayComponentValueOffsetY += inDy
    }else if inKnobIndex == SYMBOL_IN_SCHEMATICS_ROTATION_KNOB {
      let newKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY)
      let p = CanariPoint (x: self.mCenterX, y: self.mCenterY)
      let angleInDegrees = CanariPoint.angleInRadian (p, newKnobLocation) * 180.0 / .pi
      if angleInDegrees <= 45.0 {
        self.mRotation = .rotation0
      }else if angleInDegrees <= 135.0 {
        self.mRotation = .rotation90
      }else if angleInDegrees <= 225.0 {
        self.mRotation = .rotation180
      }else if angleInDegrees <= 315.0 {
        self.mRotation = .rotation270
      }else{
        self.mRotation = .rotation0
      }
    }
  }

  //····················································································································
  //  Flip horizontally
  //····················································································································

  func canFlipHorizontally_ComponentSymbolInProject () -> Bool {
    return true
  }

  //····················································································································

  func flipHorizontally_ComponentSymbolInProject () {
    self.mMirror = !self.mMirror
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  func canFlipVertically_ComponentSymbolInProject () -> Bool {
    return true
  }

  //····················································································································

  func flipVertically_ComponentSymbolInProject () {
    self.mMirror = !self.mMirror
    switch self.mRotation {
    case .rotation0 :
      self.mRotation = .rotation180
    case .rotation90 :
      self.mRotation = .rotation270
    case .rotation180 :
      self.mRotation = .rotation0
    case .rotation270 :
      self.mRotation = .rotation90
    }
  }

  //····················································································································
  //  ROTATE 90 CLOCKWISE
  //····················································································································

  func canRotate90_ComponentSymbolInProject (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.mCenterX, y: self.mCenterY)
    return true
  }

  //····················································································································

  func rotate90Clockwise_ComponentSymbolInProject (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
    if self.mMirror {
      self.mRotation.rotateCounterClockwise ()
    }else{
      self.mRotation.rotateClockwise ()
    }
  }

  //····················································································································

  func rotate90CounterClockwise_ComponentSymbolInProject (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mCenterX, y: self.mCenterY)
    self.mCenterX = p.x
    self.mCenterY = p.y
    if self.mMirror {
      self.mRotation.rotateClockwise ()
    }else{
      self.mRotation.rotateCounterClockwise ()
    }
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_ComponentSymbolInProject (_ inGrid : Int) -> Bool {
    var result = (self.mCenterX % inGrid) != 0
    if !result {
      result = (self.mCenterY % inGrid) != 0
    }
    if !result {
      result = (self.mDisplayComponentNameOffsetX % inGrid) != 0
    }
    if !result {
      result = (self.mDisplayComponentNameOffsetY % inGrid) != 0
    }
    if !result {
      result = (self.mDisplayComponentValueOffsetX % inGrid) != 0
    }
    if !result {
      result = (self.mDisplayComponentValueOffsetY % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_ComponentSymbolInProject (_ inGrid : Int) {
    self.mCenterX = ((self.mCenterX + inGrid / 2) / inGrid) * inGrid
    self.mCenterY = ((self.mCenterY + inGrid / 2) / inGrid) * inGrid
    self.mDisplayComponentNameOffsetX = ((self.mDisplayComponentNameOffsetX + inGrid / 2) / inGrid) * inGrid
    self.mDisplayComponentNameOffsetY = ((self.mDisplayComponentNameOffsetY + inGrid / 2) / inGrid) * inGrid
    self.mDisplayComponentValueOffsetX = ((self.mDisplayComponentValueOffsetX + inGrid / 2) / inGrid) * inGrid
    self.mDisplayComponentValueOffsetY = ((self.mDisplayComponentValueOffsetY + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_ComponentSymbolInProject () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    if let symbolInfo = self.symbolInfo {
      for pin in symbolInfo.pins {
        result.insert (pin.pinLocation)
      }
    }
    if self.mDisplayComponentValue {
      let p = CanariPoint (x: self.mCenterX + self.mDisplayComponentValueOffsetX, y: self.mCenterY + self.mDisplayComponentValueOffsetY)
      result.insert (p)
    }
    let p = CanariPoint (x: self.mCenterX + self.mDisplayComponentNameOffsetX, y: self.mCenterY + self.mDisplayComponentNameOffsetY)
    result.insert (p)
    return result
  }

  //····················································································································

  func operationBeforeRemoving_ComponentSymbolInProject () {
  //--- Remove nc, and attached points in project if they are not connected to any wire
    for point in self.mPoints.values {
    //--- Remove NC
      point.mNC?.mSheet = nil // Remove NC from sheet
      point.mNC = nil // Detach from pin
    //---
      let pinLocation = point.location!
      point.mX = pinLocation.x
      point.mY = pinLocation.y
    //---
      point.mSymbolPinName = ""
      point.mSymbol = nil
    //---
      if (point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) == 0 {
        point.mSheet = nil // Remove from sheet
        point.mNet = nil // Remove from net
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
