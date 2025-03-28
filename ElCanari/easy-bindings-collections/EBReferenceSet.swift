//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

struct EBReferenceSet <T : AnyObject> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mDictionary : [ObjectIdentifier : T]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.mDictionary = [ObjectIdentifier : T] ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (minimumCapacity inMinimumCapacity : Int) {
    self.mDictionary = [ObjectIdentifier : T] (minimumCapacity: inMinimumCapacity)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inObjects : [T]) {
    self.mDictionary = [ObjectIdentifier : T] (minimumCapacity: inObjects.count)
    for object in inObjects {
      self.insert (object)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inObject : T) {
    self.mDictionary = [ObjectIdentifier : T] ()
    self.insert (inObject)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func insert (_ inObject : T) {
    let address = ObjectIdentifier (inObject)
    _ = self.mDictionary.updateValue (inObject, forKey: address)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func remove (_ inObject : T) {
    let address = ObjectIdentifier (inObject)
    _ = self.mDictionary.removeValue (forKey: address)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func contains (_ inObject : T) -> Bool {
    let address = ObjectIdentifier (inObject)
    return self.mDictionary [address] != nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func intersection (_ inOtherSet : EBReferenceSet <T>) -> EBReferenceSet <T> {
//    var result = EBReferenceSet <T> ()
//    if self.mDictionary.count < inOtherSet.mDictionary.count {
//      for value in self.mDictionary.values {
//        if inOtherSet.contains (value) {
//          result.insert (value)
//        }
//      }
//    }else{
//      for value in inOtherSet.mDictionary.values {
//        if self.contains (value) {
//          result.insert (value)
//        }
//      }
//    }
//    return result
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func intersection (_ inArray : [T]) -> EBReferenceSet <T> {
    var result = EBReferenceSet <T> ()
    for value in inArray {
      if self.contains (value) {
        result.insert (value)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var first : T? { return self.mDictionary.first?.value }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func removeFirst () -> T {
    let address = ObjectIdentifier (self.first!)
    let result = self.mDictionary [address]!
    self.mDictionary [address] = nil
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var isEmpty : Bool { return self.mDictionary.isEmpty }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var count : Int { return self.mDictionary.count }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var values : Dictionary <ObjectIdentifier, T>.Values { return self.mDictionary.values }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func subtracting (_ inOtherSet : EBReferenceSet <T>) -> EBReferenceSet <T> {
     var result = self
     for key in inOtherSet.mDictionary.keys {
       result.mDictionary [key] = nil
     }
     return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func subtract (_ inOtherSet : EBReferenceSet <T>) {
     for key in inOtherSet.mDictionary.keys {
       self.mDictionary [key] = nil
     }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
