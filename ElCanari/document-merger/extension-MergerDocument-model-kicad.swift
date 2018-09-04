//
//  ElCanari
//
//  Created by Pierre Molinaro on 21/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let DEBUG = false

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class KicadItem {
  let key : String
  let items : [KicadItem]

  //····················································································································

  init (_ inKey : String, _ inValue : [KicadItem]) { key = inKey ; items = inValue }

  //····················································································································

  func display (_ inIndentationString : String, _ ioString : inout String) {
    if self.items.count == 0 {
      ioString += inIndentationString + "'\(self.key)'\n"
    }else{
      ioString += inIndentationString + "('\(self.key)'\n"
      for item in self.items {
        item.display (inIndentationString + " ", &ioString)
      }
      ioString += inIndentationString + ")\n"
    }
  }

  //····················································································································

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> Double? {
    var result : Double? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if let r = Double (self.items [inIndex].key) {
          result = r
        }else{
          ioErrorArray.append (("Key \(self.items [inIndex].key) is not a float", inLine))
        }
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getFloat ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray, inLine)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append (("Key \(inPath [1]) not found", inLine))
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", inLine))
    }
    return result
  }

  //····················································································································

  func getOptionalFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> Double? {
    var result : Double? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if inIndex < self.items.count {
          if let r = Double (self.items [inIndex].key) {
            result = r
          }else{
            ioErrorArray.append (("Key \(self.items [inIndex].key) is not a float", inLine))
          }
        }
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getOptionalFloat ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray, inLine)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", inLine))
    }
    return result
  }

  //····················································································································

  func getString (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> String? {
    var result : String? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        result = self.items [inIndex].key
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getString ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray, inLine)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append (("Key \(inPath [1]) not found", inLine))
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", inLine))
    }
    return result
  }

  //····················································································································

  func getOptionalString (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> String? {
    var result : String? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        result = self.items [inIndex].key
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getOptionalString ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray, inLine)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", inLine))
    }
    return result
  }

  //····················································································································

  func getInt (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> Int? {
    var result : Int? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if let r = Int (self.items [inIndex].key) {
          result = r
        }else{
          ioErrorArray.append (("Key \(self.items [inIndex].key) is not an int", inLine))
        }
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getInt ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray, inLine)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append (("Key \(inPath [1]) not found", #line))
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", inLine))
    }
    return result
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension KicadItem {

  //····················································································································

  func collectTexts (_ ioFrontLayoutTextEntities : inout [CanariSegment],
                     _ ioBackLayoutTextEntities : inout [CanariSegment],
                     _ inKicadFont : [UInt32 : KicadChar],
                     _ inModelLeftMM  : Double,
                     _ inModelBottomMM : Double,
                     _ ioErrorArray : inout [(String, Int)],
                     _ inMOC : EBManagedObjectContext) {
    if self.key == "gr_text",
            let value = self.getString (["gr_text"], 0, &ioErrorArray, #line),
            let textLayer = self.getString (["gr_text", "layer"], 0, &ioErrorArray, #line),
            let startX = self.getFloat (["gr_text", "at"], 0, &ioErrorArray, #line),
            let startY = self.getFloat (["gr_text", "at"], 1, &ioErrorArray, #line),
            let thickness = self.getOptionalFloat (["gr_text", "effects", "font", "thickness"], 0, &ioErrorArray, #line),
            let fontSize = self.getOptionalFloat (["gr_text", "effects", "font", "size"], 0, &ioErrorArray, #line) {
      let textTransform = NSAffineTransform ()
      textTransform.scaleX (by: 1.0, yBy: -1.0)
      textTransform.translateX (by: CGFloat (startX - inModelLeftMM), yBy: CGFloat (startY - inModelBottomMM))
//      textTransform.rotate (byDegrees: CGFloat (-moduleRotationInDegrees))
    //--- Mirror ?
      let optionalMirror = self.getOptionalString (["gr_text", "effects", "justify"], 0, &ioErrorArray, #line)
      let mirror : Double
      if let mirrorString = optionalMirror, mirrorString == "mirror" {
        mirror = -1.0
      }else{
        mirror = 1.0
      }
    //--- Compute string metrics
      var stringWidth = 0.0
      var descent = 0 // is >= 0
      var ascent = 0  // is < 0
      for unicodeChar in value.unicodeArray {
        if let charDefinition = inKicadFont [unicodeChar.value] {
          stringWidth += Double (charDefinition.advancement) * fontSize / 21.0
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
      var segments = [CanariSegment] ()
      var advancement = -mirror * stringWidth / 2.0
      let textY = Double (descent - ascent) * 0.5 * fontSize / 21.0
      for unicodeChar in value.unicodeArray {
        if let charDefinition = inKicadFont [unicodeChar.value] {
          for charSegment in charDefinition.segments {
            let x1 = advancement + mirror * Double (charSegment.x1) * fontSize / 21.0
            let y1 = textY + Double (charSegment.y1) * fontSize / 21.0
            let x2 = advancement + mirror * Double (charSegment.x2) * fontSize / 21.0
            let y2 = textY + Double (charSegment.y2) * fontSize / 21.0
            let p1 = textTransform.transform (NSPoint (x:x1, y:y1))
            let p2 = textTransform.transform (NSPoint (x:x2, y:y2))
            let segment = CanariSegment (managedObjectContext: inMOC)
            segment.x1 = millimeterToCanariUnit (Double (p1.x))
            segment.y1 = millimeterToCanariUnit (Double (p1.y))
            segment.x2 = millimeterToCanariUnit (Double (p2.x))
            segment.y2 = millimeterToCanariUnit (Double (p2.y))
            segment.width = millimeterToCanariUnit (thickness)
            segments.append (segment)
          }
          advancement += mirror * Double (charDefinition.advancement) * fontSize / 21.0
        }
      }
      if textLayer == "F.Cu" {
        ioFrontLayoutTextEntities += segments
      }else if textLayer == "B.Cu" {
        ioBackLayoutTextEntities += segments
      }
//        if layer == "F.Cu" {
//          ioFrontLayoutTextEntities.append (segment)
//        }else if layer == "B.Cu" {
//          ioBackLayoutTextEntities.append (segment)
//        }else{
//          ioErrorArray.append (("Invalid segment layer \(layer)", #line))
//        }
//      }
    }else{
      for item in self.items {
        item.collectTexts (&ioFrontLayoutTextEntities, &ioBackLayoutTextEntities, inKicadFont, inModelLeftMM, inModelBottomMM, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [(String, Int)],
                      _ inMOC : EBManagedObjectContext) {
    if self.key == "segment" {
      if let startX = self.getFloat (["segment", "start"], 0, &ioErrorArray, #line),
         let startY = self.getFloat (["segment", "start"], 1, &ioErrorArray, #line),
         let endX = self.getFloat (["segment", "end"], 0, &ioErrorArray, #line),
         let endY = self.getFloat (["segment", "end"], 1, &ioErrorArray, #line),
         let width = self.getFloat (["segment", "width"], 0, &ioErrorArray, #line),
         let layer = self.getString (["segment", "layer"], 0, &ioErrorArray, #line) {
        let segment = CanariSegment (managedObjectContext: inMOC)
        segment.x1 = millimeterToCanariUnit (startX - inModelLeftMM)
        segment.y1 = millimeterToCanariUnit (inModelBottomMM - startY)
        segment.x2 = millimeterToCanariUnit (endX - inModelLeftMM)
        segment.y2 = millimeterToCanariUnit (inModelBottomMM - endY)
        segment.width = millimeterToCanariUnit (width)
        if layer == "F.Cu" {
          ioFrontTrackEntities.append (segment)
        }else if layer == "B.Cu" {
          ioBackTrackEntities.append (segment)
        }else{
          ioErrorArray.append (("Invalid segment layer \(layer)", #line))
        }
      }
    }else{
      for item in self.items {
        item.collectTracks (&ioFrontTrackEntities, &ioBackTrackEntities, inModelLeftMM, inModelBottomMM, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································

  func collectBoardLimits (_ ioLeft : inout Int,
                           _ ioRight : inout Int,
                           _ ioTop : inout Int,
                           _ ioBottom : inout Int,
                           _ ioLineWidth : inout Int,
                           _ ioErrorArray : inout [(String, Int)]) {
    if self.key == "gr_line" {
      if let startX = self.getFloat (["gr_line", "start"], 0, &ioErrorArray, #line),
         let startY = self.getFloat (["gr_line", "start"], 1, &ioErrorArray, #line),
         let endX = self.getFloat (["gr_line", "end"], 0, &ioErrorArray, #line),
         let endY = self.getFloat (["gr_line", "end"], 1, &ioErrorArray, #line),
         let width = self.getFloat (["gr_line", "width"], 0, &ioErrorArray, #line),
//         let angle = self.getFloat (["gr_line", "angle"], 0, &ioErrorArray, #line),
         let layer = self.getString (["gr_line", "layer"], 0, &ioErrorArray, #line) {
        if layer == "Edge.Cuts" {
          let x1 = millimeterToCanariUnit (startX)
          let y1 = millimeterToCanariUnit (startY)
          let x2 = millimeterToCanariUnit (endX)
          let y2 = millimeterToCanariUnit (endY)
          let lineWidth = millimeterToCanariUnit (width)
          if ioLeft > x1 {
            ioLeft = x1
          }
          if ioRight < x1 {
            ioRight = x1
          }
          if ioBottom < y1 {
            ioBottom = y1
          }
          if ioTop > y1 {
            ioTop = y1
          }
          if ioLeft > x2 {
            ioLeft = x2
          }
          if ioRight < x2 {
            ioRight = x2
          }
          if ioBottom < y2 {
            ioBottom = y2
          }
          if ioTop > y2 {
            ioTop = y2
          }
          if ioLineWidth < lineWidth {
            ioLineWidth = lineWidth
          }
        }
      }
    }else{
      for item in self.items {
        item.collectBoardLimits (&ioLeft, &ioRight, &ioTop, &ioBottom, &ioLineWidth, &ioErrorArray)
      }
    }
  }

  //····················································································································

  func collectVias (_ ioViaEntities : inout [BoardModelVia],
                    _ ioDrillEntities : inout [CanariSegment],
                    _ inModelLeftMM  : Double,
                    _ inModelBottomMM : Double,
                    _ inNetArray : [KicadNetClass],
                    _ ioErrorArray : inout [(String, Int)],
                    _ inMOC : EBManagedObjectContext) {
    if self.key == "via" {
      if let x = self.getFloat (["via", "at"], 0, &ioErrorArray, #line),
         let y = self.getFloat (["via", "at"], 1, &ioErrorArray, #line),
         let diameter = self.getFloat (["via", "size"], 0, &ioErrorArray, #line),
         let netIndex = self.getInt (["via", "net"], 0, &ioErrorArray, #line) {
        let via = BoardModelVia (managedObjectContext: inMOC)
        via.x = millimeterToCanariUnit (x - inModelLeftMM)
        via.y = millimeterToCanariUnit (inModelBottomMM - y)
        via.padDiameter = millimeterToCanariUnit (diameter)
        let netClass = inNetArray [netIndex]
        ioViaEntities.append (via)
      //--- Add drill
        let segment = CanariSegment (managedObjectContext: inMOC)
        segment.x1 = via.x
        segment.y1 = via.y
        segment.x2 = via.x
        segment.y2 = via.y
        segment.width = netClass.drillDiameter
        ioDrillEntities.append (segment)
      }
    }else{
      for item in self.items {
        item.collectVias (&ioViaEntities, &ioDrillEntities, inModelLeftMM, inModelBottomMM, inNetArray, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································

  func collectNetNameArray (_ ioNetNameArray : inout [String],
                            _ ioNetClassArray : inout [KicadNetClass],
                            _ ioErrorArray : inout [(String, Int)]) {
    var idx = 0
    for item in self.items {
      if item.key == "net" {
        if let index = item.getInt (["net"], 0, &ioErrorArray, #line),
           let name = item.getString (["net"], 1, &ioErrorArray, #line) {
          if index != idx {
            ioErrorArray.append (("Invalid net index: \(index) instead of \(idx)", #line))
          }
          ioNetNameArray.append (name)
          idx += 1
        }
      }else if item.key == "net_class" {
        if let padDiameter = item.getFloat (["net_class", "via_dia"], 0, &ioErrorArray, #line),
           let holeDiameter = item.getFloat (["net_class", "via_drill"], 0, &ioErrorArray, #line),
           let name = item.getString (["net_class"], 0, &ioErrorArray, #line) {
          var netNameArray = [String] ()
          for netClassItem in item.items {
            if netClassItem.key == "add_net", let netName = netClassItem.getString (["add_net"], 0, &ioErrorArray, #line) {
              netNameArray.append (netName)
            }
          }
          let netClass = KicadNetClass (
            name: name,
            padDiameter: millimeterToCanariUnit (padDiameter),
            drillDiameter: millimeterToCanariUnit (holeDiameter),
            netNames: netNameArray
          )
          ioNetClassArray.append (netClass)
        }
      }
    }
  }

  //····················································································································

  func collectComponents (_ ioFrontPackagesEntities : inout [CanariSegment],
                          _ ioBackPackagesEntities : inout [CanariSegment],
                          _ ioDrillEntities : inout [CanariSegment],
                          _ ioFrontPadEntities : inout [BoardModelPad],
                          _ ioBackPadEntities : inout [BoardModelPad],
                          _ ioFrontComponentNamesEntities : inout [CanariSegment],
                          _ ioBackComponentNamesEntities : inout [CanariSegment],
                          _ ioFrontComponentValuesEntities : inout [CanariSegment],
                          _ ioBackComponentValuesEntities : inout [CanariSegment],
                          _ inKicadFont : [UInt32 : KicadChar],
                          _ inModelLeftMM  : Double,
                          _ inModelBottomMM : Double,
                          _ ioErrorArray : inout [(String, Int)],
                          _ inMOC : EBManagedObjectContext) {
    if self.key == "module" {
      if let moduleX = self.getFloat (["module", "at"], 0, &ioErrorArray, #line),
         let moduleY = self.getFloat (["module", "at"], 1, &ioErrorArray, #line),
         let layer = self.getString (["module", "layer"], 0, &ioErrorArray, #line) { // F.Cu, B.Cu
        let moduleRotationInDegrees = self.getOptionalFloat (["module", "at"], 2, &ioErrorArray, #line) ?? 0.0
        let moduleTransform = NSAffineTransform ()
        moduleTransform.scaleX (by: 1.0, yBy: -1.0)
        moduleTransform.translateX (by: CGFloat (moduleX - inModelLeftMM), yBy: CGFloat (moduleY - inModelBottomMM))
        moduleTransform.rotate (byDegrees: CGFloat (-moduleRotationInDegrees))
        for item in self.items {
          if item.key == "fp_text",
                let kind = item.getString (["fp_text"], 0, &ioErrorArray, #line), // reference, value, user
                let value = item.getString (["fp_text"], 1, &ioErrorArray, #line),
                let textLayer = item.getString (["fp_text", "layer"], 0, &ioErrorArray, #line),
                let startX = item.getFloat (["fp_text", "at"], 0, &ioErrorArray, #line),
                let startY = item.getFloat (["fp_text", "at"], 1, &ioErrorArray, #line),
                let thickness = item.getOptionalFloat (["fp_text", "effects", "font", "thickness"], 0, &ioErrorArray, #line),
                let fontSize = item.getOptionalFloat (["fp_text", "effects", "font", "size"], 0, &ioErrorArray, #line) {
          //--- Mirror ?
            let optionalMirror = item.getOptionalString (["fp_text", "effects", "justify"], 0, &ioErrorArray, #line)
            let mirror : Double
            if let mirrorString = optionalMirror, mirrorString == "mirror" {
              mirror = -1.0
            }else{
              mirror = 1.0
            }
          //--- Compute string metrics
            var stringWidth = 0.0
            var descent = 0 // is >= 0
            var ascent = 0  // is < 0
            for unicodeChar in value.unicodeArray {
              if let charDefinition = inKicadFont [unicodeChar.value] {
                stringWidth += Double (charDefinition.advancement) * fontSize / 21.0
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
            var segments = [CanariSegment] ()
            var advancement = startX - mirror * stringWidth / 2.0
            let textY = startY + Double (descent - ascent) * 0.5 * fontSize / 21.0
            for unicodeChar in value.unicodeArray {
              if let charDefinition = inKicadFont [unicodeChar.value] {
                for charSegment in charDefinition.segments {
                  let x1 = advancement + mirror * Double (charSegment.x1) * fontSize / 21.0
                  let y1 = textY + Double (charSegment.y1) * fontSize / 21.0
                  let x2 = advancement + mirror * Double (charSegment.x2) * fontSize / 21.0
                  let y2 = textY + Double (charSegment.y2) * fontSize / 21.0
                  let p1 = moduleTransform.transform (NSPoint (x:x1, y:y1))
                  let p2 = moduleTransform.transform (NSPoint (x:x2, y:y2))
                  let segment = CanariSegment (managedObjectContext: inMOC)
                  segment.x1 = millimeterToCanariUnit (Double (p1.x))
                  segment.y1 = millimeterToCanariUnit (Double (p1.y))
                  segment.x2 = millimeterToCanariUnit (Double (p2.x))
                  segment.y2 = millimeterToCanariUnit (Double (p2.y))
                  segment.width = millimeterToCanariUnit (thickness)
                  segments.append (segment)
                }
                advancement += mirror * Double (charDefinition.advancement) * fontSize / 21.0
              }
            }
            if (kind == "reference") && (textLayer == "F.SilkS") {
              ioFrontComponentNamesEntities += segments
            }else if (kind == "reference") && (textLayer == "B.SilkS") {
              ioBackComponentNamesEntities += segments
            }else if (kind == "value") && (textLayer == "F.Fab") {
              ioFrontComponentValuesEntities += segments
            }else if (kind == "value") && (textLayer == "B.Fab") {
              ioBackComponentValuesEntities += segments
            }
          }else if item.key == "fp_line",
                let startX = item.getFloat (["fp_line", "start"], 0, &ioErrorArray, #line),
                let startY = item.getFloat (["fp_line", "start"], 1, &ioErrorArray, #line),
                let endX = item.getFloat (["fp_line", "end"], 0, &ioErrorArray, #line),
                let endY = item.getFloat (["fp_line", "end"], 1, &ioErrorArray, #line),
                let widthMM = item.getFloat (["fp_line", "width"], 0, &ioErrorArray, #line),
                let lineLayer = item.getString (["fp_line", "layer"], 0, &ioErrorArray, #line) {
            let packageLine = CanariSegment (managedObjectContext: inMOC)
            let start = moduleTransform.transform (NSPoint (x: startX, y: startY))
            packageLine.x1 = millimeterToCanariUnit (Double(start.x))
            packageLine.y1 = millimeterToCanariUnit (Double(start.y))
            let end = moduleTransform.transform (NSPoint (x: endX, y: endY))
            packageLine.x2 = millimeterToCanariUnit (Double(end.x))
            packageLine.y2 = millimeterToCanariUnit (Double(end.y))
            packageLine.width = millimeterToCanariUnit (widthMM)
            if layer == "F.Cu" {
              if lineLayer == "F.SilkS" {
                ioFrontPackagesEntities.append (packageLine)
              }
            }else if layer == "B.Cu" {
              if lineLayer == "B.SilkS" {
                ioBackPackagesEntities.append (packageLine)
              }
            }else{
              ioErrorArray.append (("Invalid module layer: \(layer)", #line))
            }
          }else if item.key == "fp_arc",
                let centerX = item.getFloat (["fp_arc", "start"], 0, &ioErrorArray, #line),
                let centerY = item.getFloat (["fp_arc", "start"], 1, &ioErrorArray, #line),
                let startX = item.getFloat (["fp_arc", "end"], 0, &ioErrorArray, #line),
                let startY = item.getFloat (["fp_arc", "end"], 1, &ioErrorArray, #line),
                let angle = item.getFloat (["fp_arc", "angle"], 0, &ioErrorArray, #line),
                let widthMM = item.getFloat (["fp_arc", "width"], 0, &ioErrorArray, #line),
                let lineLayer = item.getString (["fp_arc", "layer"], 0, &ioErrorArray, #line) {
            let start = moduleTransform.transform (NSPoint (x: startX, y: startY))
            let center = moduleTransform.transform (NSPoint (x: centerX, y: centerY))
            let bp = NSBezierPath ()
            let dx = start.x - center.x
            let dy = start.y - center.y
            let radius = sqrt (dx * dx + dy * dy)
            let startAngle = angleInDegreesBetweenNSPoints (center, start)
            bp.appendArc (
              withCenter: center,
              radius: radius,
              startAngle: startAngle,
              endAngle: startAngle + CGFloat(angle),
              clockwise: angle > 0.0
            )
            bp.lineWidth = CGFloat (widthMM)
            NSBezierPath.setDefaultFlatness (CGFloat (widthMM) / 10.0)
            let flattenedBP = bp.flattened
            var currentPoint = NSPoint ()
            for idx in 0 ..< flattenedBP.elementCount {
              var pointArray = [NSPoint (), NSPoint (), NSPoint ()] // 3-point array
              let element : NSBezierPathElement = flattenedBP.element(at:idx, associatedPoints: &pointArray)
              switch element {
              case .moveToBezierPathElement :
                currentPoint = pointArray [0]
              case .lineToBezierPathElement :
                let packageLine = CanariSegment (managedObjectContext: inMOC)
                packageLine.x1 = millimeterToCanariUnit (Double (currentPoint.x))
                packageLine.y1 = millimeterToCanariUnit (Double (currentPoint.y))
                packageLine.x2 = millimeterToCanariUnit (Double (pointArray [0].x))
                packageLine.y2 = millimeterToCanariUnit (Double (pointArray [0].y))
                currentPoint = pointArray [0]
                packageLine.width = millimeterToCanariUnit (widthMM)
                if layer == "F.Cu" {
                  if lineLayer == "F.SilkS" {
                    ioFrontPackagesEntities.append (packageLine)
                  }
                }else if layer == "B.Cu" {
                  if lineLayer == "B.SilkS" {
                    ioBackPackagesEntities.append (packageLine)
                  }
                }else{
                  ioErrorArray.append (("Invalid module layer: \(layer)", #line))
                }
              case .curveToBezierPathElement :
                ioErrorArray.append (("Invalid curveToBezierPathElement", #line))
              case .closePathBezierPathElement :
                ioErrorArray.append (("Invalid closePathBezierPathElement", #line))
              }
            }
          }else if item.key == "pad",
                let padSideString = item.getString (["pad"], 1, &ioErrorArray, #line), // thru_hole, smd, np_thru_hole
                let padShapeString = item.getString (["pad"], 2, &ioErrorArray, #line), // oval, rect, circle
                let atX = item.getFloat (["pad", "at"], 0, &ioErrorArray, #line),
                let atY = item.getFloat (["pad", "at"], 1, &ioErrorArray, #line),
                let widthMM = item.getFloat (["pad", "size"], 0, &ioErrorArray, #line),
                let heightMM = item.getFloat (["pad", "size"], 1, &ioErrorArray, #line) {
            let pad = BoardModelPad (managedObjectContext: inMOC)
            let padXY = moduleTransform.transform (NSPoint (x: atX, y: atY))
            pad.x = millimeterToCanariUnit (Double (padXY.x))
            pad.y = millimeterToCanariUnit (Double (padXY.y))
            pad.width = millimeterToCanariUnit (widthMM)
            pad.height = millimeterToCanariUnit (heightMM)
            let padRotationInDegrees = item.getOptionalFloat (["pad", "at"], 2, &ioErrorArray, #line) ?? 0.0
            pad.rotation = degreesToCanariRotation (padRotationInDegrees)
            if padShapeString == "rect" {
              pad.shape = .rectangular
            }else if padShapeString == "oval" {
              pad.shape = .round
            }else if padShapeString == "circle" {
              pad.shape = .round
              if widthMM != heightMM {
                ioErrorArray.append (("Invalid circle pad: width \"\(widthMM)\".", #line))
              }
            }else{
              ioErrorArray.append (("Invalid pad shape height \(padShapeString) ≠ height \(heightMM)", #line))
            }
            if (padSideString == "thru_hole") || (padSideString == "np_thru_hole") {
              ioFrontPadEntities.append (pad)
              ioBackPadEntities.append (pad)
              if let holeSpecification = item.getString (["pad", "drill"], 0, &ioErrorArray, #line) {
                if let holeDiameter = Double (holeSpecification) {
                  let drillDiameter = millimeterToCanariUnit (holeDiameter)
                  let x1 = pad.x
                  let y1 = pad.y
                  let drill = CanariSegment (managedObjectContext: inMOC)
                  drill.x1 = x1
                  drill.y1 = y1
                  drill.x2 = x1
                  drill.y2 = y1
                  drill.width = drillDiameter
                  ioDrillEntities.append (drill)
                }else if holeSpecification == "oval" {
                  if let drillDiameterMM = item.getFloat (["pad", "drill"], 1, &ioErrorArray, #line),
                     let ovalMM = item.getFloat (["pad", "drill"], 2, &ioErrorArray, #line) {
                    let drillDiameter = millimeterToCanariUnit (drillDiameterMM)
                    let padTransform = NSAffineTransform ()
                    padTransform.scaleX (by: 1.0, yBy: -1.0)
                    padTransform.rotate (byDegrees: CGFloat (-moduleRotationInDegrees))
                    let p = padTransform.transform (NSPoint (x: (ovalMM - drillDiameterMM) / 2.0, y:0))
                    let dx = millimeterToCanariUnit (Double (p.x))
                    let dy = millimeterToCanariUnit (Double (p.y))
                    let drill = CanariSegment (managedObjectContext: inMOC)
                    drill.x1 = pad.x - dx
                    drill.y1 = pad.y - dy
                    drill.x2 = pad.x + dx
                    drill.y2 = pad.y + dy
                    drill.width = drillDiameter
                    ioDrillEntities.append (drill)
                  }else{
                    ioErrorArray.append (("Invalid pad drill oval width or height", #line))
                  }
                }else{
                  ioErrorArray.append (("Invalid pad drill \"\(holeSpecification)\".", #line))
                }
              }
            }else if padSideString == "smd" {
              if layer == "F.Cu" {
                ioFrontPadEntities.append (pad)
              }else{
                ioBackPadEntities.append (pad)
              }
            }else{
              ioErrorArray.append (("Invalid pad side \"\(padSideString)\".", #line))
            }
          }
        }
      }
    }else{
      for item in self.items {
        item.collectComponents (&ioFrontPackagesEntities, &ioBackPackagesEntities,
                                &ioDrillEntities, &ioFrontPadEntities, &ioBackPadEntities,
                                &ioFrontComponentNamesEntities, &ioBackComponentNamesEntities,
                                &ioFrontComponentValuesEntities, &ioBackComponentValuesEntities,
                                inKicadFont, inModelLeftMM, inModelBottomMM, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class KicadNetClass {
  let name : String
  let padDiameter : Int
  let drillDiameter : Int
  let netNames : [String]

  //····················································································································

  init (name inName : String, padDiameter inPadDiameter : Int, drillDiameter inDrillDiameter : Int, netNames inNetNames : [String]) {
    name = inName
    padDiameter = inPadDiameter
    drillDiameter = inDrillDiameter
    netNames = inNetNames
  }

  //····················································································································

  init () {
    name = "???"
    padDiameter = 0
    drillDiameter = 0
    netNames = []
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func loadBoardModel_kicad (filePath inFilePath : String, windowForSheet inWindow : NSWindow) {
  //--- Load file, as plist
    let optionalFileData : Data? = FileManager ().contents (atPath: inFilePath)
    if let fileData = optionalFileData {
      let s = inFilePath.lastPathComponent.deletingPathExtension
      let possibleBoardModel = self.parseBoardModel_kicad (fromData: fileData, named : s)
      if let boardModel = possibleBoardModel {
        self.rootObject.boardModels_property.add (boardModel)
        self.mBoardModelController.select (object:boardModel)
      }
    }else{ // Cannot read file
      let alert = NSAlert ()
      alert.messageText = "Cannot read file"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = "The file \(inFilePath) cannot be read."
      alert.beginSheetModal (for: inWindow, completionHandler: {(NSModalResponse) in})
    }
  }

  //····················································································································

  func parseBoardModel_kicad (fromData inData : Data, named inName : String) -> BoardModel? {
    var boardModel : BoardModel? = nil
    if let contentString = String (data: inData, encoding: .utf8) {
    //--- Parse
      var index = 0
      let contents = parse (contentString.unicodeArray, &index)
    //--- Display
//      var str = ""
//      contents?.display ("", &str)
//      Swift.print (str)
    //--- Extract board limits
      var errorArray = [(String, Int)] ()
      var left   =  Int.max ; var right  = -Int.max
      var bottom = -Int.max ; var top = Int.max // in Kicad, the Y-axis is pointing down
      var boardModelWidth = -Int.max
      contents?.collectBoardLimits (&left, &right, &top, &bottom, &boardModelWidth, &errorArray)
      if (left >= right) || (top >= bottom) {
        let alert = NSAlert ()
        alert.messageText = "Cannot extract board bounding box"
        alert.addButton (withTitle: "Ok")
        alert.informativeText = ""
        alert.beginSheetModal (for: self.windowForSheet!, completionHandler: {(NSModalResponse) in})
      }else{
        let leftMM = canariUnitToMillimeter (left)
        let rightMM = canariUnitToMillimeter (right)
        let topMM = canariUnitToMillimeter (top)
        let bottomMM = canariUnitToMillimeter (bottom)
        let modelWidthMM = rightMM - leftMM
        let modelHeightMM = bottomMM - topMM // in Kicad, the Y-axis is pointing down
        // Swift.print ("Board size \(modelWidth) mm • \(modelHeight) mm")
      //--- Collect tracks
        var frontTrackEntities = [CanariSegment] ()
        var backTrackEntities = [CanariSegment] ()
        contents?.collectTracks (&frontTrackEntities, &backTrackEntities, leftMM, bottomMM, &errorArray, self.managedObjectContext ())
      //--- Collect net name array, net class array
        var netNameArray = [String] ()
        var netClassArray = [KicadNetClass] ()
        contents?.collectNetNameArray (&netNameArray, &netClassArray, &errorArray)
      //--- Build dictionary of net class, key by net name
        var netDictionary = [String : KicadNetClass] ()
        for netClass in netClassArray {
          for netName in netClass.netNames {
            netDictionary [netName] = netClass
          }
        }
      //--- Build array of net class, index by net index
      //    Note that net #0 has an empty name and is never used
        var netArray = [KicadNetClass] ()
        netArray.append (KicadNetClass ()) // Pseudo net #0
        for netName in netNameArray.dropFirst () {
          if let netClass = netDictionary [netName] {
            netArray.append (netClass)
          }else{
            errorArray.append (("no net named \(netName)", #line))
          }
        }
      //--- Collect vias
        var drillEntities = [CanariSegment] ()
        var viaEntities = [BoardModelVia] ()
        contents?.collectVias (&viaEntities, &drillEntities, leftMM, bottomMM, netArray, &errorArray, self.managedObjectContext ())
      //---- Collect components
        let font : [UInt32 : KicadChar] = kicadFont ()
        var frontPadEntities = [BoardModelPad] ()
        var backPadEntities = [BoardModelPad] ()
        var frontPackagesEntities = [CanariSegment] ()
        var backPackagesEntities = [CanariSegment] ()
        var backComponentNamesEntities = [CanariSegment] ()
        var frontComponentNamesEntities = [CanariSegment] ()
        var frontComponentValuesEntities = [CanariSegment] ()
        var backComponentValuesEntities = [CanariSegment] ()
        contents?.collectComponents (&frontPackagesEntities, &backPackagesEntities,
                                     &drillEntities, &frontPadEntities, &backPadEntities,
                                     &frontComponentNamesEntities, &backComponentNamesEntities,
                                     &frontComponentValuesEntities, &backComponentValuesEntities,
                                     font, leftMM, bottomMM, &errorArray, self.managedObjectContext ())
      //---- Collect texts and lines (gr_text)
        var frontLayoutTextEntities = [CanariSegment] ()
        var backLayoutTextEntities = [CanariSegment] ()
        contents?.collectTexts (&frontLayoutTextEntities, &backLayoutTextEntities,
                                font, leftMM, bottomMM, &errorArray, self.managedObjectContext ())




    //  //--- Back Legend texts
    //    var backLegendLinesEntities = [CanariSegment] ()
    //    let backLegendLines = stringArray (fromDict: boardArchiveDict, key: "LINES-BACK", &errorArray)
    //    for str in backLegendLines {
    //      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
    //      let ints = array5int (fromString: str, &errorArray)
    //      segment.x1 = ints [0]
    //      segment.y1 = ints [1]
    //      segment.x2 = ints [2]
    //      segment.y2 = ints [3]
    //      segment.width = ints [4]
    //      backLegendLinesEntities.append (segment)
    //    }
    //    boardModel.backLegendLines_property.setProp (backLegendLinesEntities)
    //  //--- Front Legend texts
    //    var frontLegendLinesEntities = [CanariSegment] ()
    //    let frontLegendLines = stringArray (fromDict: boardArchiveDict, key: "LINES-FRONT", &errorArray)
    //    for str in frontLegendLines {
    //      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
    //      let ints = array5int (fromString: str, &errorArray)
    //      segment.x1 = ints [0]
    //      segment.y1 = ints [1]
    //      segment.x2 = ints [2]
    //      segment.y2 = ints [3]
    //      segment.width = ints [4]
    //      frontLegendLinesEntities.append (segment)
    //    }
    //    boardModel.frontLegendLines_property.setProp (frontLegendLinesEntities)
    //  //--- Back Legend texts
    //    var backLegendTextEntities = [CanariSegment] ()
    //    let backLegendTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LEGEND-BACK", &errorArray)
    //    for str in backLegendTexts {
    //      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
    //      let ints = array5int (fromString: str, &errorArray)
    //      segment.x1 = ints [0]
    //      segment.y1 = ints [1]
    //      segment.x2 = ints [2]
    //      segment.y2 = ints [3]
    //      segment.width = ints [4]
    //      backLegendTextEntities.append (segment)
    //    }
    //    boardModel.backLegendTexts_property.setProp (backLegendTextEntities)
    //  //--- Front Legend texts
    //    var frontLegendTextEntities = [CanariSegment] ()
    //    let frontTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LEGEND-FRONT", &errorArray)
    //    for str in frontTexts {
    //      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
    //      let ints = array5int (fromString: str, &errorArray)
    //      segment.x1 = ints [0]
    //      segment.y1 = ints [1]
    //      segment.x2 = ints [2]
    //      segment.y2 = ints [3]
    //      segment.width = ints [4]
    //      frontLegendTextEntities.append (segment)
    //    }
    //    boardModel.frontLegendTexts_property.setProp (frontLegendTextEntities)
      //--- Dictionary import ok ?
        if errorArray.count == 0 {
          boardModel = BoardModel (managedObjectContext: self.managedObjectContext ())
          boardModel?.name = inName
          boardModel?.modelWidth  = millimeterToCanariUnit (modelWidthMM)
          boardModel?.modelWidthUnit = ONE_MILLIMETER_IN_CANARI_UNIT
          boardModel?.modelHeight = millimeterToCanariUnit (modelHeightMM)
          boardModel?.modelHeightUnit = ONE_MILLIMETER_IN_CANARI_UNIT
          boardModel?.modelLimitWidth = boardModelWidth
          boardModel?.modelLimitWidthUnit = ONE_MILLIMETER_IN_CANARI_UNIT
          boardModel?.backTracks_property.setProp (backTrackEntities)
          boardModel?.frontTracks_property.setProp (frontTrackEntities)
          boardModel?.vias_property.setProp (viaEntities)
          boardModel?.frontPackages_property.setProp (frontPackagesEntities)
          boardModel?.backPackages_property.setProp (backPackagesEntities)
          boardModel?.frontPads_property.setProp (frontPadEntities)
          boardModel?.backPads_property.setProp (backPadEntities)
          boardModel?.backComponentNames_property.setProp (backComponentNamesEntities)
          boardModel?.frontComponentNames_property.setProp (frontComponentNamesEntities)
          boardModel?.frontComponentValues_property.setProp (frontComponentValuesEntities)
          boardModel?.backComponentValues_property.setProp (backComponentValuesEntities)
          boardModel?.drills_property.setProp (drillEntities)
          boardModel?.frontLayoutTexts_property.setProp (frontLayoutTextEntities)
          boardModel?.backLayoutTexts_property.setProp (backLayoutTextEntities)
        }else{ // Error
          var s = ""
          for anError in errorArray {
            if s != "" {
              s += "\n"
            }
            s += anError.0 + " (line \(anError.1))"
          }
          let alert = NSAlert ()
          alert.messageText = "Cannot Analyse file contents"
          alert.addButton (withTitle: "Ok")
          alert.informativeText = s
          alert.beginSheetModal (for: self.windowForSheet!, completionHandler: {(NSModalResponse) in})
        }
      }
    }
  //--- Return
    return boardModel
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func parse (_ inContentString : [UnicodeScalar], _ ioIndex : inout Int) -> KicadItem? {
  passSeparators (inContentString, &ioIndex)
  var result : KicadItem? = nil
  if !atEnd (inContentString, ioIndex) {
    if inContentString [ioIndex] == "(" {
      if DEBUG { print ("FIND (") }
      ioIndex += 1
    //--- Parse key
      passSeparators (inContentString, &ioIndex)
      var key = ""
      var c = inContentString [ioIndex]
      while (c > " ") && (c != ")") && (c != "(") {
        key += String (c)
        ioIndex += 1
        c = inContentString [ioIndex]
      }
      if DEBUG { print ("KEY '\(key)'") }
      var items = [KicadItem] ()
      var parseItems = true
      while parseItems {
        passSeparators (inContentString, &ioIndex)
        if atEnd (inContentString, ioIndex) {
          parseItems = false
        }else if inContentString [ioIndex] == ")" {
          if DEBUG { print ("FIND )") }
          parseItems = false
          ioIndex += 1
        }else if let item = parse (inContentString, &ioIndex) {
          items.append (item)
        }else{
          Swift.print ("Error at index \(ioIndex)")
          parseItems = false
        }
      }
      result = KicadItem (key, items)
    }else if inContentString [ioIndex] == "\"" { // String
      ioIndex += 1
      var str = ""
      var c = inContentString [ioIndex]
      ioIndex += 1
      while c != "\"" {
        str += String (c)
        c = inContentString [ioIndex]
        ioIndex += 1
      }
      if DEBUG { print ("STRING '\(str)'") }
      result = KicadItem (str, [])
    }else if (inContentString [ioIndex] > " ") && (inContentString [ioIndex] != ")") && (inContentString [ioIndex] != "(") {
      var str = String (inContentString [ioIndex])
      ioIndex += 1
      var c = inContentString [ioIndex]
      while (c > " ") && (c < "~") && (c != ")") && (c != "(") {
        str += String (c)
        ioIndex += 1
        c = inContentString [ioIndex]
      }
      result = KicadItem (str, [])
    }
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func passSeparators (_ inContentString : [UnicodeScalar], _ ioIndex : inout Int) {
  var loop = true
  while loop && !atEnd (inContentString, ioIndex) {
    let c = inContentString [ioIndex]
    if (c == " ") || (c == "\n") || (c == "\r") {
      ioIndex += 1
    }else{
      loop = false
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func atEnd (_ inContentString : [UnicodeScalar], _ inIndex : Int) -> Bool {
  return inIndex == inContentString.count
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension String {

  var unicodeArray : [UnicodeScalar] {
    var array = [UnicodeScalar] ()
    for scalar in self.unicodeScalars {
      array.append (scalar)
    }
    return array
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
