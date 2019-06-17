//
//  extension-BoardText.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_TEXT_ORIGIN_KNOB  = 0
let BOARD_TEXT_ROTATION_KNOB  = 1

let ROTATION_KNOB_DISTANCE : CGFloat = 30.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardText
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardText {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx : Int, yBy inDy : Int, userSet ioSet : OCObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    if inKnobIndex == BOARD_TEXT_ORIGIN_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else if inKnobIndex == BOARD_TEXT_ROTATION_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else{
      return OCCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == BOARD_TEXT_ORIGIN_KNOB {
      self.mX += inDx
      self.mY += inDy
    }else if inKnobIndex == BOARD_TEXT_ROTATION_KNOB {
      self.mX += inDx
      self.mY += inDy
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
  //  REMOVING
  //····················································································································

  override func operationBeforeRemoving () {
    self.mFont = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func boardText_displayInfos (
       _ self_mX : Int,
       _ self_mY : Int,
       _ self_mText : String,
       _ self_mFontSize : Double,
       _ self_mFont_descriptor : BoardFontDescriptor,
       _ self_mHorizontalAlignment : HorizontalAlignment,
       _ self_mVerticalAlignment : BoardTextVerticalAlignment,
       _ self_mLayer : BoardTextLayer,
       _ self_mRotation : Int
) -> (NSBezierPath, NSPoint, NSPoint) { // (display, origin, rotation knob)
//--- START OF USER ZONE 2
        let s = (self_mText == "") ? "Empty" : self_mText
        let bp = NSBezierPath ()
        var width : CGFloat = 0.0
        let fontFactor = CGFloat (self_mFontSize) / CGFloat (self_mFont_descriptor.nominalSize)
        for character in s.unicodeScalars {
          if let characterDescriptor = self_mFont_descriptor.dictionary [character.value] {
            for segment in characterDescriptor.segments {
              let x1 = CGFloat (segment.x1) * fontFactor
              let y1 = CGFloat (segment.y1) * fontFactor
              let x2 = CGFloat (segment.x2) * fontFactor
              let y2 = CGFloat (segment.y2) * fontFactor
              bp.move (to: NSPoint (x: width + x1, y: y1))
              bp.line (to: NSPoint (x: width + x2, y: y2))
            }
            width += CGFloat (characterDescriptor.advancement) * fontFactor
          }
        }
        bp.lineWidth = fontFactor * 2.0
        bp.lineCapStyle = .round
        bp.lineJoinStyle = .round
        let startX = canariUnitToCocoa (self_mX)
        let startY = canariUnitToCocoa (self_mY)
        var tr = AffineTransform ()
        switch self_mHorizontalAlignment {
        case .onTheLeft :
          tr.translate (x: startX  - width / 2.0, y: 0.0)
        case .center :
          tr.translate (x: startX, y: 0.0)
        case .onTheRight :
          tr.translate (x: startX + width / 2.0, y: 0.0)
        }
        switch self_mVerticalAlignment {
        case .above :
          tr.translate (x: 0.0, y: startY - bp.bounds.minY)
        case .base :
          tr.translate (x: 0.0, y: startY)
        case .center :
          tr.translate (x: 0.0, y: startY - (bp.bounds.maxY + bp.bounds.minY) / 2.0)
        case .below :
          tr.translate (x: 0.0, y: startY - bp.bounds.maxY)
        }
        switch self_mLayer {
        case .legendFront, .layoutFront :
          ()
        case .layoutBack, .legendBack :
          tr.scale (x: -1.0, y: 1.0)
        }
        let rotationInDegrees = CGFloat (self_mRotation) / 1000.0
        tr.rotate (byDegrees: rotationInDegrees)
        tr.translate (x: -width / 2.0, y: 0.0) // Center horizontally
        bp.transform (using: tr)
      //--- Rotation knob
        var rotationKnobTransform = AffineTransform ()
        rotationKnobTransform.translate (x: startX, y: startY)
        rotationKnobTransform.rotate (byDegrees: rotationInDegrees)
        let rotationKnobLocation = rotationKnobTransform.transform (NSPoint (x: ROTATION_KNOB_DISTANCE, y: 0.0))
      //---
        return (bp, NSPoint (x: startX, y: startY), rotationKnobLocation)
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
