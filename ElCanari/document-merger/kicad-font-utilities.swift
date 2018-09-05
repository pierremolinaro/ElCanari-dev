//
//  kicad-font-utilities.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/09/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let KICAD_INTERLINE_PITCH_RATIO : CGFloat = 1.5
//let KICAD_OVERBAR_POSITION_FACTOR : CGFloat = 1.22
//let KICAD_BOLD_FACTOR : CGFloat = 1.3
fileprivate let KICAD_STROKE_FONT_SCALE : CGFloat = 1.0 / 21.0
//let KICAD_ITALIC_TILT : CGFloat = 1.0 / 8

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func stringMetrics (str inString : String,
                    fontSize inFontSize : CGFloat,
                    font inKicadFont : [UInt32 : KicadChar]) -> (CGFloat, CGFloat) {
  var stringWidth = 0
  var descent = 0 // is >= 0
  var ascent = 0  // is < 0
  for unicodeChar in inString.unicodeArray {
    if let charDefinition = inKicadFont [unicodeChar.value] {
      stringWidth += charDefinition.advancement
      for charSegment in charDefinition.segments {
        let y1 = charSegment.y1
        if y1 > descent {
          descent = y1
        }
        if y1 < ascent {
          ascent = y1
        }
        let y2 = charSegment.y2
        if y2 > descent {
          descent = y2
        }
        if y2 < ascent {
          ascent = y2
        }
      }
    }
  }
  // Swift.print ("descent \(descent), ascent \(ascent)")
  let fontFactor = inFontSize * KICAD_STROKE_FONT_SCALE
  return (CGFloat (stringWidth) * fontFactor, CGFloat (descent - ascent) * fontFactor)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum KicadStringJustification {
  case left
  case center
  case right
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func drawKicadString (str inString : String,
                      transform inAffineTransform: NSAffineTransform,
                      mirror inMirror : Bool,
                      justification inJustification : KicadStringJustification,
                      fontSize inFontSize : CGFloat,
                      thickness inThickness : CGFloat,
                      font inKicadFont : [UInt32 : KicadChar],
                      leftMM inModelLeftMM  : CGFloat,
                      bottomMM inModelBottomMM : CGFloat,
                      boardRect inBoardRect : CanariHorizontalRect,
                      moc inMOC : EBManagedObjectContext) -> [SegmentEntity] {
  let mirror : CGFloat = inMirror ? -1.0 : 1.0
  let fontFactor = inFontSize * KICAD_STROKE_FONT_SCALE
//--- Compute string metrics
  var totalHeight : CGFloat = 0.0
  var widthArray = [CGFloat] ()
  var heightArray = [CGFloat] ()
  let components = inString.components (separatedBy: "\\n")
  for str in components {
    let (stringWidth, stringHeight) = stringMetrics (str: str, fontSize: inFontSize, font: inKicadFont)
    totalHeight += stringHeight
    totalHeight += fontFactor * KICAD_INTERLINE_PITCH_RATIO + inThickness
    heightArray.append (stringHeight)
    widthArray.append (stringWidth)
  }
//--- Add interlines
//  totalHeight += CGFloat (components.count - 1) * (fontFactor * KICAD_INTERLINE_PITCH_RATIO + inThickness)
//  if components.count > 1 {
//    Swift.print ("heightArray \(heightArray)")
//    Swift.print ("pitch \(fontFactor * KICAD_INTERLINE_PITCH_RATIO), inThickness \(inThickness)")
//  }
//--- Display string
  var textY : CGFloat = (components.count > 1) ? 0.0 : (totalHeight * 0.5)
  var segments = [SegmentEntity] ()
  for idx in 0 ..< components.count {
    var advancement : CGFloat
    switch inJustification {
    case .left :
      advancement = 0
    case .center :
      advancement = -mirror * widthArray [idx] / 2.0
    case .right :
      advancement = -mirror * widthArray [idx]
    }
    for unicodeChar in components [idx].unicodeArray {
      if let charDefinition = inKicadFont [unicodeChar.value] {
        for charSegment in charDefinition.segments {
          let x1 = advancement + mirror * CGFloat (charSegment.x1) * fontFactor
          let y1 = textY + CGFloat (charSegment.y1) * fontFactor
          let x2 = advancement + mirror * CGFloat (charSegment.x2) * fontFactor
          let y2 = textY + CGFloat (charSegment.y2) * fontFactor
          let p1 = inAffineTransform.transform (NSPoint (x:x1, y:y1))
          let p2 = inAffineTransform.transform (NSPoint (x:x2, y:y2))
          if let segment = clippedSegment (
            p1: p1,
            p2: p2,
            width: millimeterToCanariUnit (inThickness),
            clipRect: inBoardRect,
            moc: inMOC
          ) {
            segments.append (segment)
          }
        }
        advancement += mirror * CGFloat (charDefinition.advancement) * fontFactor
      }
    }
    textY += heightArray [idx] + (fontFactor * KICAD_INTERLINE_PITCH_RATIO + inThickness)
  }
  return segments
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
