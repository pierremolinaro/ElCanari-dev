//
//  EBWeakReferenceArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/11/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct EBWeakReferenceArray <Element : AnyObject> {

  //····················································································································

  private var mArray : [EBWeakElement <Element>]

  //····················································································································

  init () {
    self.mArray = [EBWeakElement <Element>] ()
  }

  //····················································································································

  mutating func append (_ inObject : Element) {
  //--- Remove nil elements
    let array = self.mArray
    self.mArray.removeAll ()
    for entry in array {
      if entry.possibleElement != nil {
        self.mArray.append (entry)
      }
    }
  //--- Append
    self.mArray.append (EBWeakElement (inObject))
  }

  //····················································································································

  var values : [Element] {
    var result = [Element] ()
    for weakElement in self.mArray {
      if let element = weakElement.possibleElement {
        result.append (element)
      }
    }
    return result
  }

  //····················································································································

  func contains (_ inElement : Element) -> Bool {
    for weakElement in self.mArray {
      if let element = weakElement.possibleElement, element === inElement {
        return true
      }
    }
    return false
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor struct EBWeakReferenceSet <T : AnyObject> {

  //····················································································································

  private var mDictionary : [ObjectIdentifier : EBWeakElement <T>]

  //····················································································································

  init () {
    self.mDictionary = [ObjectIdentifier : EBWeakElement <T>] ()
  }

  //····················································································································

  mutating func insert (_ inObject : T) {
    let key = ObjectIdentifier (inObject)
    self.mDictionary [key] = EBWeakElement (inObject)
  }

  //····················································································································

  mutating func remove (_ inObject : T) {
    let key = ObjectIdentifier (inObject)
    self.mDictionary [key] = nil
  }

  //····················································································································

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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct EBWeakElement <Element : AnyObject> {

  //····················································································································

  private weak var mWeakElement : Element? // SHOULD BE Weak

  //····················································································································

  init (_ inElement : Element) {
    self.mWeakElement = inElement
  }

  //····················································································································

  var possibleElement : Element?  { return self.mWeakElement }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
