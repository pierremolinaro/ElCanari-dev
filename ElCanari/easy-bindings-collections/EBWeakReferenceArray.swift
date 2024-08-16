//
//  EBWeakReferenceArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct EBWeakReferenceArray <Element : AnyObject> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mArray : [EBWeakElement <Element>]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.mArray = [EBWeakElement <Element>] ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var values : [Element] {
    var result = [Element] ()
    for weakElement in self.mArray {
      if let element = weakElement.possibleElement {
        result.append (element)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func contains (_ inElement : Element) -> Bool {
    for weakElement in self.mArray {
      if let element = weakElement.possibleElement, element === inElement {
        return true
      }
    }
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

