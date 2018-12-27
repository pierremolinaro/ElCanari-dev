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

  private func scanPoint (_ inString : [UnicodeScalar],
                          _ ioIndex : inout Int,
                          _ ioOk : inout Bool) -> (CanariPoint, Int, Int) {
    let x = self.scanNumber (inString, &ioIndex, &ioOk)
    let xUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    self.check (":", inString, &ioIndex, &ioOk)
    let y = self.scanNumber (inString, &ioIndex, &ioOk)
    let yUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    return (CanariPoint (x: x, y: y), xUnit, yUnit)
  }

  //····················································································································

  private func scanPad (_ inString : [UnicodeScalar],
                        _ ioIndex : inout Int,
                        _ ioOk : inout Bool,
                        _ ioObjects : inout [PackageObject]) {
    let (center, centerXUnit, centerYUnit) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("size", inString, &ioIndex, &ioOk)
    let (size, widthUnit, heightUnit) = self.scanPoint (inString, &ioIndex, &ioOk)
    self.check ("shape", inString, &ioIndex, &ioOk)
    if self.test ("rectangular", inString, &ioIndex, &ioOk) {
    }else if self.test ("round", inString, &ioIndex, &ioOk) {
    }else{
      self.check ("octo", inString, &ioIndex, &ioOk)
    }
    self.check ("style", inString, &ioIndex, &ioOk)
    if self.test ("traversing", inString, &ioIndex, &ioOk) {
    }else{
      self.check ("surface", inString, &ioIndex, &ioOk)
    }
    self.check ("hole", inString, &ioIndex, &ioOk)
    let holeDiameter = self.scanNumber (inString, &ioIndex, &ioOk)
    let holeDiameterUnit = self.scanUnit (inString, &ioIndex, &ioOk)
    self.check ("\n", inString, &ioIndex, &ioOk)
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
      while loop && ok {
        if self.test ("pad", ua, &idx, &ok) {
          self.scanPad (ua, &idx, &ok, &objects)
        }else{
          self.check ("end", ua, &idx, &ok)
          loop = false
        }
      }
      if ok {
        self.clearError ()
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
