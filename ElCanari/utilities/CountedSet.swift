//
//  CountedSet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/04/2025.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct CountedSet <Element : Hashable> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mDictionary : [Element : Int] = [:]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func insert (_ inElement : Element) {
    self.mDictionary [inElement, default: 0] += 1
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func remove (_ inElement : Element) {
    if let count = self.mDictionary [inElement] {
      if count == 1 {
        self.mDictionary [inElement] = nil
      }else{
        self.mDictionary [inElement] = count - 1
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func removeAllOccurences (of inElement : Element) {
    self.mDictionary [inElement] = nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removingAllOccurences (of inElement : Element) -> CountedSet {
    var result = self
    result.removeAllOccurences (of: inElement)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func count (for inElement : Element) -> Int {
    return self.mDictionary [inElement] ?? 0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var keys : [Element] { Array (self.mDictionary.keys) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var values : [(Element, Int)] {
    var result = [(Element, Int)] ()
    for (element, count) in self.mDictionary {
      result.append ((element, count))
    }
    return result
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var totalCount : Int {
    var result = 0
    for (_, count) in self.mDictionary {
      result += count
    }
    return result
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
