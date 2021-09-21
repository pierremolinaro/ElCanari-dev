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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
