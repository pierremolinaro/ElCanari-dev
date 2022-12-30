//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservedObject : EBSwiftBaseObject {

  //····················································································································

  private final var mObservers = EBWeakEventSet ()

  //····················································································································

  final func startsToBeObserved (by inObserver : EBObserverProtocol) {
    self.mObservers.insert (observer: inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  final func stopsBeingObserved (by inObserver : EBObserverProtocol) {
    self.mObservers.remove (observer: inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  func observedObjectDidChange () {
    for entry in self.mObservers.values () {
      if let observer = entry.possibleObserver {
        observer.observedObjectDidChange ()
      }else{
        self.mObservers.triggerPacking ()
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor struct EBWeakEventSet {

  //····················································································································

  private var mDictionary = [Int : EBWeakObserverSetElement] ()

  //····················································································································

  mutating func values () -> Dictionary <Int, EBWeakObserverSetElement>.Values {
    self.pack ()
    return self.mDictionary.values
  }

  //····················································································································

  private var mPackingTriggered = false

  //····················································································································

  mutating func triggerPacking () {
    self.mPackingTriggered = true
  }

  //····················································································································

  private mutating func pack () {
    if self.mPackingTriggered {
      self.mPackingTriggered = false
      for (key, entry) in self.mDictionary {
        if entry.possibleObserver == nil {
          self.mDictionary [key] = nil
        }
      }
    }
  }

  //····················································································································

  mutating func insert (observer inObserver : EBObserverProtocol) {
    let address = inObserver.objectIndex
    self.mDictionary [address] = EBWeakObserverSetElement (observer: inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  mutating func remove (observer inObserver : EBObserverProtocol) {
    let address = inObserver.objectIndex
    self.mDictionary [address] = nil
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
