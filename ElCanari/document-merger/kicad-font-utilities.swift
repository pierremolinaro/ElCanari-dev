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
  return (CGFloat (stringWidth) * inFontSize / 21.0, CGFloat (descent - ascent) * inFontSize / 21.0)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func drawKicadString (str inString : String,
                      transform inAffineTransform: NSAffineTransform,
                      x inStartX : CGFloat,
                      y inStartY : CGFloat,
                      optionalMirror inOptionalMirror : String?,
                      optionalJustify inOptionalJustify : String?,
                      fontSize inFontSize : CGFloat,
                      thickness inThickness : CGFloat,
                      font inKicadFont : [UInt32 : KicadChar],
                      leftMM inModelLeftMM  : CGFloat,
                      bottomMM inModelBottomMM : CGFloat,
                      boardRect inBoardRect : CanariHorizontalRect,
                      moc inMOC : EBManagedObjectContext) -> [SegmentEntity] {
  let mirror : CGFloat
  if let mirrorString = inOptionalMirror, mirrorString == "mirror" {
    mirror = -1.0
  }else{
    mirror = 1.0
  }
//--- Compute string metrics
  var maxStringWidth : CGFloat = 0.0
  var totalHeight : CGFloat = 0.0
  var heightArray = [CGFloat] ()
  let components = inString.components (separatedBy: "\\n")
  for str in components {
    let (stringWidth, stringHeight) = stringMetrics (str: str, fontSize: inFontSize, font: inKicadFont)
    if maxStringWidth < stringWidth {
      maxStringWidth = stringWidth
    }
    totalHeight += stringHeight
    heightArray.append (stringHeight)
  }
//---
  var segments = [SegmentEntity] ()
  var textY = inStartY + heightArray.last! * 0.5 // totalHeight * 0.5
  for idx in 0 ..< components.count {
    let str = components [idx]
    var advancement = inStartX - mirror * maxStringWidth / 2.0
    for unicodeChar in str.unicodeArray {
      if let charDefinition = inKicadFont [unicodeChar.value] {
        for charSegment in charDefinition.segments {
          let x1 = advancement + mirror * CGFloat (charSegment.x1) * inFontSize / 21.0
          let y1 = textY + CGFloat (charSegment.y1) * inFontSize / 21.0
          let x2 = advancement + mirror * CGFloat (charSegment.x2) * inFontSize / 21.0
          let y2 = textY + CGFloat (charSegment.y2) * inFontSize / 21.0
          let p1 = inAffineTransform.transform (NSPoint (x:x1, y:y1))
          let p2 = inAffineTransform.transform (NSPoint (x:x2, y:y2))
          if let segment = clippedSegment (
            x1: p1.x,
            y1: p1.y,
            x2: p2.x,
            y2: p2.y,
            width: millimeterToCanariUnit (inThickness),
            clipRect: inBoardRect,
            moc: inMOC
          ) {
            segments.append (segment)
          }
        }
        advancement += mirror * CGFloat (charDefinition.advancement) * inFontSize / 21.0
      }
    }
    textY += heightArray [idx]
  }
  return segments
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
