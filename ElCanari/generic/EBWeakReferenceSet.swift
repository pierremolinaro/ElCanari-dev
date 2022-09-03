//
//  EBWeakReferenceSet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/09/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct EBWeakReferenceSet <T : ObjectIndexProtocol> {

  //····················································································································

  private var mDictionary : [Int : EBWeakReferenceSetElement <T>]

  //····················································································································

  init () {
    self.mDictionary = [Int : EBWeakReferenceSetElement <T>] ()
  }

  //····················································································································

  mutating func insert (_ inObject : T) {
    let address = inObject.objectIndex
    self.mDictionary [address] = EBWeakReferenceSetElement (inObject)
  }

  //····················································································································

  mutating func remove (_ inObject : T) {
    let address = inObject.objectIndex
    self.mDictionary [address] = nil
  }

  //····················································································································

  mutating func values () -> [T] {
    var result = [T] ()
    for (key, weakElement) in self.mDictionary {
      if let element = weakElement.element {
        result.append (element)
      }else{
        self.mDictionary [key] = nil
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct EBWeakReferenceSetElement <T : ObjectIndexProtocol> {

  private weak var mElement : T?

  init (_ inElement : T) {
    self.mElement = inElement
  }

  var element : T?  { return self.mElement }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
