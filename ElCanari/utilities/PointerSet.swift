//
//  PointerSet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/09/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PointerSet <T : AnyObject> : Sequence {

  //····················································································································

  private var mDictionary = Dictionary <Int, T> ()

  //····················································································································

  init () {
  }

  //····················································································································

  init (_ inObjects : [T]) {
    for object in inObjects {
      self.insert (object)
    }
  }

  //····················································································································

  mutating func insert (_ inObject : T) {
    let address : Int = unsafeBitCast (inObject, to: Int.self)
    self.mDictionary [address] = inObject
  }

  //····················································································································

  mutating func remove (_ inObject : T) {
    let address : Int = unsafeBitCast (inObject, to: Int.self)
    self.mDictionary [address] = nil
  }

  //····················································································································

  var first : T? { return self.mDictionary.first?.value }

  //····················································································································

  var count : Int { return self.mDictionary.count }

  //····················································································································

  func makeIterator () -> AnyIterator <T> {
    let values = self.mDictionary.values
    var index = values.startIndex
    return AnyIterator {
      if index != values.endIndex {
        let result = values [index]
        index = values.index (after: index)
        return result
      }else{
        return nil
      }
    }
  }

  //····················································································································

  func subtracting (_ inOtherSet : PointerSet <T>) -> PointerSet <T> {
     var result = self
     for (key, _) in inOtherSet.mDictionary {
       result.mDictionary [key] = nil
     }
     return result
  }

  //····················································································································

//  public static func == (lhs: PointerSet <T>, rhs: PointerSet <T>) -> Bool {
//    var equal = lhs.mDictionary.count == rhs.mDictionary.count
//    if equal {
//      var idx = 0
//      while idx < lhs.mPathes.count {
//        if lhs.mPathes [idx] != rhs.mPathes [idx] {
//          equal = false
//          idx = lhs.mPathes.count // For exiting loop
//        }
//        idx += 1
//      }
//    }
//    return equal
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
