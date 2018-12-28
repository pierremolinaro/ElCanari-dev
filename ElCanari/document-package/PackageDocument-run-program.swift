//
//  PackageDocument-parse-program.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageDocument {

  //····················································································································

  private func passSpaces (_ inString : [UnicodeScalar],
                           _ ioIndex : inout Int,
                           _ ioOk : inout Bool) {
    while ioOk && (inString [ioIndex] == " ") {
      ioIndex += 1
      if ioIndex == inString.count {
        self.raiseError (ioIndex, "End of text reached")
        ioOk = false
      }
    }
  }

  //····················································································································

    private func test (_ inValue : String,
                       _ inString : [UnicodeScalar],
                       _ ioIndex : inout Int,
                       _ ioOk : inout Bool) -> Bool {
    self.passSpaces (inString, &ioIndex, &ioOk)
    if ioOk {
      var idx = ioIndex
      let identifier = inValue.unicodeArray
      for c in identifier {
        if idx >= inString.count {
          return false
        }else if c != inString [idx] {
          return false
        }
        idx += 1
      }
      ioIndex = idx
    }
    return true
  }

  //····················································································································

  private func check (_ inValue : String,
                      _ inString : [UnicodeScalar],
                      _ ioIndex : inout Int,
                      _ ioOk : inout Bool) {
    self.passSpaces (inString, &ioIndex, &ioOk)
    if ioOk {
      var idx = ioIndex
      let identifier = inValue.unicodeArray
      for c in identifier {
        if idx >= inString.count {
          self.raiseError (ioIndex, "End of text reached")
          ioOk = false
          break
        }else if c != inString [idx] {
          self.raiseError (ioIndex, "\"\(inValue)\" expected")
          ioOk = false
          break
        }
        idx += 1
      }
      ioIndex = idx
    }
  }

  //····················································································································

  private func isLetter (_ inCharacter : UnicodeScalar) -> Bool {
    return ((inCharacter >= "A") && (inCharacter <= "Z")) || ((inCharacter >= "a") && (inCharacter <= "z"))
  }

  //····················································································································

  private func scanName (_ inString : [UnicodeScalar],
                           _ ioIndex : inout Int,
                           _ ioOk : inout Bool) -> String {
    self.passSpaces (inString, &ioIndex, &ioOk)
    var value = ""
    if ioOk {
      if ioIndex >= inString.count {
        self.raiseError (ioIndex, "End of text reached")
        ioOk = false
      }else if self.isLetter (inString [ioIndex]) {
        value += "\(inString [ioIndex])"
        ioIndex += 1
      }else{
        self.raiseError (ioIndex, "Invalid start of name, a lower case letter expected")
        ioOk = false
      }
    }
    var loop = true
    while ioOk && loop {
      if ioIndex >= inString.count {
        self.raiseError (ioIndex, "End of text reached")
        ioOk = false
      }else if self.isLetter (inString [ioIndex]) {
        value += "\(inString [ioIndex])"
        ioIndex += 1
      }else{
        loop = false
      }
    }
    return value
  }

  //····················································································································

  private func scanString (_ inString : [UnicodeScalar],
                           _ ioIndex : inout Int,
                           _ ioOk : inout Bool) -> String {
    self.passSpaces (inString, &ioIndex, &ioOk)
    var value = ""
    if ioOk {
      if ioIndex >= inString.count {
        self.raiseError (ioIndex, "End of text reached")
        ioOk = false
      }else if inString [ioIndex] == "\"" {
        ioIndex += 1
      }else{
        self.raiseError (ioIndex, "Invalid start of string, \" expected")
        ioOk = false
      }
    }
    var loop = true
    while ioOk && loop {
      if ioIndex >= inString.count {
        self.raiseError (ioIndex, "End of text reached")
        ioOk = false
      }else if inString [ioIndex] == "\n" {
        self.raiseError (ioIndex, "End of line reached within a character string")
        ioOk = false
      }else if inString [ioIndex] != "\"" {
        value += "\(inString [ioIndex])"
        ioIndex += 1
      }else{
        loop = false
        ioIndex += 1 // Pass terminating "
      }
    }
    return value
  }

  //····················································································································

  private func scanNumber (_ inString : [UnicodeScalar],
                           _ ioIndex : inout Int,
                           _ ioOk : inout Bool) -> Int {
    self.passSpaces (inString, &ioIndex, &ioOk)
    var emptyNumber = true
    var value = 0
    var loop = true
    while ioOk && loop {
      if ioIndex >= inString.count {
        self.raiseError (ioIndex, "End of text reached")
        ioOk = false
      }else if (inString [ioIndex] >= "0") && (inString [ioIndex] <= "9") {
        emptyNumber = false
        value *= 10
        value += Int (inString [ioIndex].value - 48) // 48 : ASCCI code of "0"
        ioIndex += 1
      }else{
        loop = false
      }
    }
    if ioOk && emptyNumber {
      self.raiseError (ioIndex, "An integer value is expected here")
      ioOk = false
    }
    return value
  }

  //····················································································································

  private func scanUnit (_ inString : [UnicodeScalar],
                         _ ioIndex : inout Int,
                         _ ioOk : inout Bool) -> Int {
    self.passSpaces (inString, &ioIndex, &ioOk)
    if self.test ("µm", inString, &ioIndex, &ioOk) {
      return 90
    }else if self.test ("mm", inString, &ioIndex, &ioOk) {
      return 90_000
    }else if self.test ("cm", inString, &ioIndex, &ioOk) {
      return 900_000
    }else if self.test ("in", inString, &ioIndex, &ioOk) {
      return 2_286_000
    }else if self.test ("mil", inString, &ioIndex, &ioOk) {
      return 2_286
    }else if self.test ("pt", inString, &ioIndex, &ioOk) {
      return 31_750
    }else if self.test ("pc", inString, &ioIndex, &ioOk) {
      return 381_000
    }else{
      self.raiseError (ioIndex, "Expected dimension unit: µm, mm, cm, mil, in, pt or pc")
      ioOk = false
      return 1
    }
  }

  //····················································································································

  private func scanNumberWithUnit (_ inString : [UnicodeScalar],
                                   _ ioIndex : inout Int,
                                   _ ioOk : inout Bool) -> (Int, Int) {
    let x = self.scanNumber (inString, &ioIndex, &ioOk)
    let xUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    return (x * xUnit, xUnit)
  }

  //····················································································································

  private func scanPoint (_ inString : [UnicodeScalar],
                          _ ioIndex : inout Int,
                          _ ioOk : inout Bool) -> ((Int, Int), (Int, Int)) {
    let x = self.scanNumber (inString, &ioIndex, &ioOk)
    let xUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    self.check (":", inString, &ioIndex, &ioOk)
    let y = self.scanNumber (inString, &ioIndex, &ioOk)
    let yUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    return ((x * xUnit, xUnit), (y * yUnit, yUnit))
  }

  //····················································································································

  private func scanDimension (_ inString : [UnicodeScalar],
                              _ ioIndex : inout Int,
                              _ ioOk : inout Bool,
                              _ ioObjects : inout [PackageObject]) {
    let ((x1, x1Unit), (y1, y1Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("to", inString, &ioIndex, &ioOk)
    let ((x2, x2Unit), (y2, y2Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("label", inString, &ioIndex, &ioOk)
    let ((xDimension, xDimensionUnit), (yDimension, yDimensionUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("unit", inString, &ioIndex, &ioOk)
    let distanceUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageDimension (self.ebUndoManager, file: #file, #line)
    object.x1 = x1
    object.x1Unit = x1Unit
    object.y1 = y1
    object.y1Unit = y1Unit
    object.x2 = x2
    object.x2Unit = x2Unit
    object.y2 = y2
    object.y2Unit = y2Unit
    object.xDimension = xDimension
    object.xDimensionUnit = xDimensionUnit
    object.yDimension = yDimension
    object.yDimensionUnit = yDimensionUnit
    object.distanceUnit = distanceUnit
    ioObjects.append (object)
 }

  //····················································································································

  private func scanZone (_ inString : [UnicodeScalar],
                         _ ioIndex : inout Int,
                         _ ioOk : inout Bool,
                         _ ioObjects : inout [PackageObject]) {
    let ((x, xUnit), (y, yUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("size", inString, &ioIndex, &ioOk)
    let ((width, widthUnit), (height, heightUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("label", inString, &ioIndex, &ioOk)
    let ((xName, xNameUnit), (yName, yNameUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("name", inString, &ioIndex, &ioOk)
    let zoneName = self.scanString (inString, &ioIndex, &ioOk)
    self.check ("numbering", inString, &ioIndex, &ioOk)
    let numberingIndex = ioIndex
    let numberingName = self.scanName (inString, &ioIndex, &ioOk)
    let possibleZoneNumbering = PadNumbering (string: numberingName)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageZone (self.ebUndoManager, file: #file, #line)
    object.x = x
    object.xUnit = xUnit
    object.y = y
    object.yUnit = yUnit
    object.width = width
    object.widthUnit = widthUnit
    object.height = height
    object.heightUnit = heightUnit
    object.xName = xName
    object.xNameUnit = xNameUnit
    object.yName = yName
    object.yNameUnit = yNameUnit
    object.zoneName = zoneName
    if ioOk, let zoneNumbering = possibleZoneNumbering {
      object.zoneNumbering = zoneNumbering
    }else if ioOk {
      self.raiseError (numberingIndex, "Invalid numbering name")
      ioOk = false
    }
    ioObjects.append (object)
 }

  //····················································································································

  private func scanSlavePad (_ inString : [UnicodeScalar],
                             _ ioIndex : inout Int,
                             _ ioOk : inout Bool,
                             _ ioObjects : inout [PackageObject],
                             _ ioSlavePadArray : inout [(PackageSlavePad, Int, Int)]) {
    let ((xCenter, xCenterUnit), (yCenter, yCenterUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("size", inString, &ioIndex, &ioOk)
    let ((width, widthUnit), (height, heightUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("shape", inString, &ioIndex, &ioOk)
    let padShape : PadShape
    if self.test ("rectangular", inString, &ioIndex, &ioOk) {
      padShape = .rectangular
    }else if self.test ("round", inString, &ioIndex, &ioOk) {
      padShape = .round
    }else{
      self.check ("octo", inString, &ioIndex, &ioOk)
      padShape = .octo
    }
    self.check ("style", inString, &ioIndex, &ioOk)
    let padStyle : PadStyle
    if self.test ("traversing", inString, &ioIndex, &ioOk) {
      padStyle = .traversing
    }else{
      self.check ("surface", inString, &ioIndex, &ioOk)
      padStyle = .surface
    }
    self.check ("hole", inString, &ioIndex, &ioOk)
    let holeDiameter = self.scanNumber (inString, &ioIndex, &ioOk)
    let holeDiameterUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    self.check ("id", inString, &ioIndex, &ioOk)
    let slavePadErrorLocation = ioIndex
    let masterPadID = self.scanNumber (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageSlavePad (self.ebUndoManager, file: #file, #line)
    object.xCenter = xCenter
    object.xCenterUnit = xCenterUnit
    object.yCenter = yCenter
    object.yCenterUnit = yCenterUnit
    object.width = width
    object.widthUnit = widthUnit
    object.height = height
    object.heightUnit = heightUnit
    object.padShape = padShape
    object.padStyle = padStyle
    object.holeDiameter = holeDiameter
    object.holeDiameterUnit = holeDiameterUnit
    ioObjects.append (object)
    ioSlavePadArray.append ((object, masterPadID, slavePadErrorLocation))
 }

  //····················································································································

  private func scanPad (_ inString : [UnicodeScalar],
                        _ ioIndex : inout Int,
                        _ ioOk : inout Bool,
                        _ ioObjects : inout [PackageObject],
                        _ ioMasterPadDictionary : inout [Int : PackagePad]) {
    let ((xCenter, xCenterUnit), (yCenter, yCenterUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("size", inString, &ioIndex, &ioOk)
    let ((width, widthUnit), (height, heightUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("shape", inString, &ioIndex, &ioOk)
    let padShape : PadShape
    if self.test ("rectangular", inString, &ioIndex, &ioOk) {
      padShape = .rectangular
    }else if self.test ("round", inString, &ioIndex, &ioOk) {
      padShape = .round
    }else{
      self.check ("octo", inString, &ioIndex, &ioOk)
      padShape = .octo
    }
    self.check ("style", inString, &ioIndex, &ioOk)
    let padStyle : PadStyle
    if self.test ("traversing", inString, &ioIndex, &ioOk) {
      padStyle = .traversing
    }else{
      self.check ("surface", inString, &ioIndex, &ioOk)
      padStyle = .surface
    }
    self.check ("hole", inString, &ioIndex, &ioOk)
    let (holeDiameter, holeDiameterUnit) = self.scanNumberWithUnit (inString, &ioIndex, &ioOk)
    let object = PackagePad (self.ebUndoManager, file: #file, #line)
    if self.test ("id", inString, &ioIndex, &ioOk) {
      let padID = self.scanNumber (inString, &ioIndex, &ioOk)
      ioMasterPadDictionary [padID] = object
    }
    self.check ("\n", inString, &ioIndex, &ioOk)
    object.xCenter = xCenter
    object.xCenterUnit = xCenterUnit
    object.yCenter = yCenter
    object.yCenterUnit = yCenterUnit
    object.width = width
    object.widthUnit = widthUnit
    object.height = height
    object.heightUnit = heightUnit
    object.padShape = padShape
    object.padStyle = padStyle
    object.holeDiameter = holeDiameter
    object.holeDiameterUnit = holeDiameterUnit
    ioObjects.append (object)
 }

  //····················································································································

  private func scanGuide (_ inString : [UnicodeScalar],
                          _ ioIndex : inout Int,
                          _ ioOk : inout Bool,
                          _ ioObjects : inout [PackageObject]) {
    let ((x1, x1Unit), (y1, y1Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("to", inString, &ioIndex, &ioOk)
    let ((x2, x2Unit), (y2, y2Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageGuide (self.ebUndoManager, file: #file, #line)
    object.x1 = x1
    object.x1Unit = x1Unit
    object.y1 = y1
    object.y1Unit = y1Unit
    object.x2 = x2
    object.x2Unit = x2Unit
    object.y2 = y2
    object.y2Unit = y2Unit
    ioObjects.append (object)
}

  //····················································································································

  private func scanBezier (_ inString : [UnicodeScalar],
                           _ ioIndex : inout Int,
                           _ ioOk : inout Bool,
                           _ ioObjects : inout [PackageObject]) {
    let ((x1, x1Unit), (y1, y1Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("to", inString, &ioIndex, &ioOk)
    let ((x2, x2Unit), (y2, y2Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("cp1", inString, &ioIndex, &ioOk)
    let ((cpx1, cpx1Unit), (cpy1, cpy1Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("cp2", inString, &ioIndex, &ioOk)
    let ((cpx2, cpx2Unit), (cpy2, cpy2Unit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageBezierCurve (self.ebUndoManager, file: #file, #line)
    object.x1 = x1
    object.x1Unit = x1Unit
    object.y1 = y1
    object.y1Unit = y1Unit
    object.x2 = x2
    object.x2Unit = x2Unit
    object.y2 = y2
    object.y2Unit = y2Unit
    object.cpx1 = cpx1
    object.cpx1Unit = cpx1Unit
    object.cpy1 = cpy1
    object.cpy1Unit = cpy1Unit
    object.cpx2 = cpx2
    object.cpx2Unit = cpx2Unit
    object.cpy2 = cpy2
    object.cpy2Unit = cpy2Unit
    ioObjects.append (object)
}

  //····················································································································

  private func scanArc (_ inString : [UnicodeScalar],
                           _ ioIndex : inout Int,
                           _ ioOk : inout Bool,
                           _ ioObjects : inout [PackageObject]) {
    let ((xCenter, xCenterUnit), (yCenter, yCenterUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("radius", inString, &ioIndex, &ioOk)
    let (radius, radiusUnit) = self.scanNumberWithUnit (inString, &ioIndex, &ioOk)
    self.check ("start", inString, &ioIndex, &ioOk)
    let startAngle = self.scanNumber(inString, &ioIndex, &ioOk)
    self.check ("angle", inString, &ioIndex, &ioOk)
    let arcAngle = self.scanNumber(inString, &ioIndex, &ioOk)
    self.check ("leading", inString, &ioIndex, &ioOk)
    let (startTangentLength, startTangentLengthUnit) = self.scanNumberWithUnit (inString, &ioIndex, &ioOk)
    self.check ("training", inString, &ioIndex, &ioOk)
    let (endTangentLength, endTangentLengthUnit) = self.scanNumberWithUnit (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageArc (self.ebUndoManager, file: #file, #line)
    object.xCenter = xCenter
    object.xCenterUnit = xCenterUnit
    object.yCenter = yCenter
    object.yCenterUnit = yCenterUnit
    object.radius = radius
    object.radiusUnit = radiusUnit
    object.startAngle = startAngle
    object.arcAngle = arcAngle
    object.startTangentLength = startTangentLength
    object.startTangentLengthUnit = startTangentLengthUnit
    object.endTangentLength = endTangentLength
    object.endTangentLengthUnit = endTangentLengthUnit
    ioObjects.append (object)
 }

  //····················································································································

  private func scanOval (_ inString : [UnicodeScalar],
                         _ ioIndex : inout Int,
                         _ ioOk : inout Bool,
                         _ ioObjects : inout [PackageObject]) {
    let ((originX, originXUnit), (originY, originYUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("size", inString, &ioIndex, &ioOk)
    let ((width, widthUnit), (height, heightUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageOval (self.ebUndoManager, file: #file, #line)
    object.x = originX
    object.xUnit = originXUnit
    object.y = originY
    object.yUnit = originYUnit
    object.width = width
    object.widthUnit = widthUnit
    object.height = height
    object.heightUnit = heightUnit
    ioObjects.append (object)
}

  //····················································································································

  private func scanSegment (_ inString : [UnicodeScalar],
                            _ ioIndex : inout Int,
                            _ ioOk : inout Bool,
                            _ ioObjects : inout [PackageObject]) {
    let ((p1X, p1XUnit), (p1Y, p1YUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("to", inString, &ioIndex, &ioOk)
    let ((p2X, p2XUnit), (p2Y, p2YUnit)) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
    let object = PackageSegment (self.ebUndoManager, file: #file, #line)
    object.x1 = p1X
    object.x1Unit = p1XUnit
    object.y1 = p1Y
    object.y1Unit = p1YUnit
    object.x2 = p2X
    object.x2Unit = p2XUnit
    object.y2 = p2Y
    object.y2Unit = p2YUnit
    ioObjects.append (object)
 }

  //····················································································································

  internal func clearError () {
    self.mProgramErrorTextField?.stringValue = ""
    if let programTextView = self.mProgramTextView, let textStorage = programTextView.textStorage {
      let r = NSRange (location: 0, length: textStorage.length)
      textStorage.removeAttribute (NSAttributedString.Key.foregroundColor, range: r)
    }
  }

  //····················································································································

  private func raiseError (_ inErrorLocation : Int, _ inMessage : String) {
    self.mProgramErrorTextField?.stringValue = inMessage
    if let programTextView = self.mProgramTextView, let textStorage = programTextView.textStorage {
      let r = NSRange (location: 0, length: textStorage.length)
      textStorage.removeAttribute (NSAttributedString.Key.foregroundColor, range: r)
      if inErrorLocation < textStorage.length {
        let errorRange = NSRange (location: inErrorLocation, length: textStorage.length - inErrorLocation)
        let attributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.foregroundColor : NSColor.red
        ]
        textStorage.addAttributes (attributes, range: errorRange)
      }
    }
  }

  //····················································································································

  internal func runProgram () {
    let text = self.mProgramTextView?.string ?? ""
    if text == "" {
      self.raiseError (0, "Empty Program")
    }else{
      let ua = text.unicodeArray
      var idx = 0
      var ok = true
      var loop = true
      var objects = [PackageObject] ()
      var masterPadDictionary = [Int : PackagePad] ()
      var slavePadArray = [(PackageSlavePad, Int, Int)] () // Slavre Pad, id, errorLocation
      while loop && ok {
        if self.test ("pad", ua, &idx, &ok) {
          self.scanPad (ua, &idx, &ok, &objects, &masterPadDictionary)
        }else if self.test ("dimension", ua, &idx, &ok) {
          self.scanDimension (ua, &idx, &ok, &objects)
        }else if self.test ("zone", ua, &idx, &ok) {
          self.scanZone (ua, &idx, &ok, &objects)
        }else if self.test ("slave", ua, &idx, &ok) {
          self.scanSlavePad (ua, &idx, &ok, &objects, &slavePadArray)
        }else if self.test ("guide", ua, &idx, &ok) {
          self.scanGuide (ua, &idx, &ok, &objects)
        }else if self.test ("bezier", ua, &idx, &ok) {
          self.scanBezier (ua, &idx, &ok, &objects)
        }else if self.test ("arc", ua, &idx, &ok) {
          self.scanArc (ua, &idx, &ok, &objects)
        }else if self.test ("oval", ua, &idx, &ok) {
          self.scanOval (ua, &idx, &ok, &objects)
        }else if self.test ("segment", ua, &idx, &ok) {
          self.scanSegment (ua, &idx, &ok, &objects)
        }else{
          self.check ("end", ua, &idx, &ok)
          loop = false
        }
      }
      if ok {
        for (slavePad, masterPadID, errorLocation) in slavePadArray {
          if let masterPad = masterPadDictionary [masterPadID] {
            slavePad.master_property.setProp (masterPad)
          }else{
            self.raiseError (errorLocation, "no master pad with id = \(masterPadID)")
            ok = false
            break
          }
        }
      }
      if ok {
        self.clearError ()
        self.rootObject.packageObjects_property.setProp (objects)
        self.rootObject.selectedPageIndex = 0
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
