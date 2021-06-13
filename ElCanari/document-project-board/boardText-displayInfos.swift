//
//  boardText_displayInfos
//  ElCanari
//
//  Created by Pierre Molinaro on 16/06/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

func boardText_displayInfos (
       x self_mX : Int,
       y self_mY : Int,
       string self_mText : String,
       fontSize self_mFontSize : Double,
       _ self_mFont_descriptor : BoardFontDescriptor,
       horizontalAlignment self_mHorizontalAlignment : HorizontalAlignment,
       verticalAlignment self_mVerticalAlignment : BoardTextVerticalAlignment,
       frontSide inFrontSide : Bool,
       rotation self_mRotation : Int,
       weight self_mWeight : Double,
       oblique self_mOblique : Bool,
       extraWidth inExtraWidth : CGFloat // Used for ERC checking
) -> (EBBezierPath, EBBezierPath, NSPoint, NSPoint, [GeometricOblong]) { // (textDisplay, frame, origin, rotation knob)
  let s = (self_mText == "") ? "Empty" : self_mText
  var stringWidth : CGFloat = 0.0
  let oblique = self_mOblique ? CGFloat (0.25) : CGFloat (0.0)
  let fontFactor = CGFloat (self_mFontSize) / CGFloat (self_mFont_descriptor.nominalSize)
  let lineThickness = fontFactor * 2.0 * CGFloat (self_mWeight) + inExtraWidth
  var bp = EBBezierPath ()
  bp.lineWidth = lineThickness
  bp.lineCapStyle = .round
  bp.lineJoinStyle = .round
  var oblongs = [GeometricOblong] ()
  for character in s.unicodeScalars {
    if let characterDescriptor = self_mFont_descriptor.dictionary [character.value] {
      for segment in characterDescriptor.segments {
        let x1 = fontFactor * (CGFloat (segment.x1) + oblique * CGFloat (segment.y1))
        let y1 = fontFactor * CGFloat (segment.y1)
        let x2 = fontFactor * (CGFloat (segment.x2) + oblique * CGFloat (segment.y2))
        let y2 = fontFactor * CGFloat (segment.y2)
        let p1 = NSPoint (x: stringWidth + x1, y: y1)
        let p2 = NSPoint (x: stringWidth + x2, y: y2)
        bp.move (to: p1)
        bp.line (to: p2)
        oblongs.append (GeometricOblong (from: p1, to: p2, width: lineThickness))
      }
      stringWidth += CGFloat (characterDescriptor.advancement) * fontFactor
    }
  }
  var frameBP = EBBezierPath ()
  if !bp.isEmpty {
    frameBP.appendRect (bp.bounds.insetBy (dx: -1.0, dy: -1.0))
  }
  var tr = AffineTransform ()
  let startX = canariUnitToCocoa (self_mX)
  let startY = canariUnitToCocoa (self_mY)
  tr.translate (x: startX, y: startY)
  let rotationInDegrees = CGFloat (self_mRotation) / 1000.0
  tr.rotate (byDegrees: rotationInDegrees)
  if !inFrontSide {
    tr.scale (x: -1.0, y: 1.0)
  }

  switch self_mHorizontalAlignment {
  case .onTheLeft :
    tr.translate (x: -stringWidth, y: 0.0)
  case .center :
    tr.translate (x: -stringWidth / 2.0, y: 0.0)
  case .onTheRight :
    ()
  }

  switch self_mVerticalAlignment {
  case .above :
    tr.translate (x: 0.0, y: -bp.bounds.minY)
  case .base :
    ()
  case .center :
    tr.translate (x: 0.0, y: -(bp.bounds.maxY + bp.bounds.minY) / 2.0)
  case .below :
    tr.translate (x: 0.0, y: -bp.bounds.maxY)
  }
  bp.transform (using: tr)

  var transformedOblongs = [GeometricOblong] ()
  for ob in oblongs {
    transformedOblongs.append (ob.transformed (by: tr))
  }
  frameBP.transform (using: tr)
  frameBP.lineWidth = 0.5
  frameBP.lineCapStyle = .round
  frameBP.lineJoinStyle = .round
//--- Rotation knob
  var rotationKnobTransform = AffineTransform ()
  rotationKnobTransform.translate (x: startX, y: startY)
  rotationKnobTransform.rotate (byDegrees: rotationInDegrees)
  let rotationKnobLocation = rotationKnobTransform.transform (NSPoint (x: BOARD_TEXT_ROTATION_KNOB_DISTANCE, y: 0.0))
//---
  return (bp, frameBP, NSPoint (x: startX, y: startY), rotationKnobLocation, transformedOblongs)
}

//----------------------------------------------------------------------------------------------------------------------
