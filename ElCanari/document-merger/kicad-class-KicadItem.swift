//
//  kicad-class-KicadItem.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/09/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let DEBUG_PARSING = false

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class KicadItem {
  let key : String
  let items : [KicadItem]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inKey : String, _ inValue : [KicadItem]) { key = inKey ; items = inValue }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func display (_ inIndentationString : String, _ ioString : inout String) {
//    if self.items.count == 0 {
//      ioString += inIndentationString + "'\(self.key)'\n"
//    }else{
//      ioString += inIndentationString + "('\(self.key)'\n"
//      for item in self.items {
//        item.display (inIndentationString + " ", &ioString)
//      }
//      ioString += inIndentationString + ")\n"
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> CGFloat? {
    var result : CGFloat? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if let r = Double (self.items [inIndex].key) {
          result = CGFloat (r)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func getOptionalFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> CGFloat? {
    var result : CGFloat? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if inIndex < self.items.count {
          if let r = Double (self.items [inIndex].key) {
            result = CGFloat (r)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func getOptionalString (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> String? {
//    var result : String? = nil
//    if inPath [0] == self.key {
//      if inPath.count == 1 {
//        result = self.items [inIndex].key
//      }else{
//        var search = true
//        var idx = 0
//        while search {
//          let item = self.items [idx]
//          if item.key == inPath [1] {
//            result = item.getOptionalString ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray, inLine)
//            search = false
//          }else{
//            idx += 1
//            search = idx < self.items.count
//          }
//        }
//      }
//    }else{
//      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", inLine))
//    }
//    return result
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func getOptionalItemContents (_ inName : String) -> [KicadItem] {
    for item in self.items {
      if inName == item.key {
        return item.items
      }
    }
    return [KicadItem] ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func getItem (_ inName : String, _ ioErrorArray : inout [(String, Int)], _ inLine : Int) -> KicadItem {
    for item in self.items {
      if inName == item.key {
        return item
      }
    }
    ioErrorArray.append (("Invalid key \(inName)", inLine))
    return KicadItem ("", [])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func getOptionalItem (_ inName : String) -> KicadItem {
    for item in self.items {
      if inName == item.key {
        return item
      }
    }
    return KicadItem ("", [])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

func parseKicadString (_ inContentString : [UnicodeScalar], _ ioIndex : inout Int) -> KicadItem? {
  passSeparators (inContentString, &ioIndex)
  var result : KicadItem? = nil
  if !atEnd (inContentString, ioIndex) {
    if inContentString [ioIndex] == "(" {
      if DEBUG_PARSING { print ("FIND (") }
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
      if DEBUG_PARSING { print ("KEY '\(key)'") }
      var items = [KicadItem] ()
      var parseItems = true
      while parseItems {
        passSeparators (inContentString, &ioIndex)
        if atEnd (inContentString, ioIndex) {
          parseItems = false
        }else if inContentString [ioIndex] == ")" {
          if DEBUG_PARSING { print ("FIND )") }
          parseItems = false
          ioIndex += 1
        }else if let item = parseKicadString (inContentString, &ioIndex) {
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
      if DEBUG_PARSING { print ("STRING '\(str)'") }
      result = KicadItem (str, [])
    }else if (inContentString [ioIndex] > " ") && (inContentString [ioIndex] != ")") && (inContentString [ioIndex] != "(") {
      var str = String (inContentString [ioIndex])
      ioIndex += 1
      var c = inContentString [ioIndex]
      let space : Unicode.Scalar = " "
      let closePar : Unicode.Scalar = ")"
      let openPar : Unicode.Scalar = "("
      let tilde : Unicode.Scalar = "~"
      while (c > space) && (c < tilde) && (c != closePar) && (c != openPar) {
        str += String (c)
        ioIndex += 1
        c = inContentString [ioIndex]
      }
      result = KicadItem (str, [])
    }
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func atEnd (_ inContentString : [UnicodeScalar], _ inIndex : Int) -> Bool {
  return inIndex == inContentString.count
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
