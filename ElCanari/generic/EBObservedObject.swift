//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservedObject : EBSwiftBaseObject {

  //····················································································································

  private var mDictionary = [Int : EBWeakObserverSetElement] ()

  //····················································································································

  final func startsToBeObserved (by inObserver : EBObserverProtocol) {
    let address = inObserver.objectIndex
    self.mDictionary [address] = EBWeakObserverSetElement (observer: inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  final func stopsBeingObserved (by inObserver : EBObserverProtocol) {
    let address = inObserver.objectIndex
    self.mDictionary [address] = nil
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  func observedObjectDidChange () {
    for (key, entry) in self.mDictionary {
      if let observer = entry.possibleObserver {
        observer.observedObjectDidChange ()
      }else{
        self.mDictionary [key] = nil
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//@MainActor struct EBWeakEventSet {
//
//  //····················································································································
//
//  private var mDictionary = [Int : EBWeakObserverSetElement] ()
//
//  //····················································································································
//
//  mutating func values () -> Dictionary <Int, EBWeakObserverSetElement>.Values {
//    self.pack ()
//    return self.mDictionary.values
//  }
//
//  //····················································································································
//
//  private var mPackingTriggered = false
//
//  //····················································································································
//
//  mutating func triggerPacking () {
//    self.mPackingTriggered = true
//  }
//
//  //····················································································································
//
//  private mutating func pack () {
//    if self.mPackingTriggered {
//      self.mPackingTriggered = false
//      for (key, entry) in self.mDictionary {
//        if entry.possibleObserver == nil {
//          self.mDictionary [key] = nil
//        }
//      }
//    }
//  }
//
//  //····················································································································
//
//  mutating func insert (observer inObserver : EBObserverProtocol) {
//    let address = inObserver.objectIndex
//    self.mDictionary [address] = EBWeakObserverSetElement (observer: inObserver)
//    inObserver.observedObjectDidChange ()
//  }
//
//  //····················································································································
//
//  mutating func remove (observer inObserver : EBObserverProtocol) {
//    let address = inObserver.objectIndex
//    self.mDictionary [address] = nil
//    inObserver.observedObjectDidChange ()
//  }
//
//  //····················································································································
//
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
