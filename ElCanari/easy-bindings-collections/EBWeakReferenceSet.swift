//
//  EBWeakReferenceArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/11/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct EBWeakReferenceSet <T : AnyObject> {

  //································································································

  private var mDictionary : [ObjectIdentifier : EBWeakElement <T>]

  //································································································

  init () {
    self.mDictionary = [ObjectIdentifier : EBWeakElement <T>] ()
  }

  //································································································

  mutating func insert (_ inObject : T) {
    let key = ObjectIdentifier (inObject)
    self.mDictionary [key] = EBWeakElement (inObject)
  }

  //································································································

  mutating func remove (_ inObject : T) {
    let key = ObjectIdentifier (inObject)
    self.mDictionary [key] = nil
  }

  //································································································

  mutating func values () -> [T] {
    var result = [T] ()
    for (key, weakElement) in self.mDictionary {
      if let element = weakElement.possibleElement {
        result.append (element)
      }else{
        self.mDictionary [key] = nil
      }
    }
    return result
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct EBWeakElement <Element : AnyObject> {

  //································································································

  private weak var mWeakElement : Element? // SHOULD BE Weak

  //································································································

  init (_ inElement : Element) {
    self.mWeakElement = inElement
  }

  //································································································

  var possibleElement : Element?  { return self.mWeakElement }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
