//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservedObject : EBSwiftBaseObject, EBObserverProtocol {

  //····················································································································

  private final var mDictionary = [Int : EBWeakObserverSetElement] ()

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
//   EBWeakObserverSetElement
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct EBWeakObserverSetElement {

  //····················································································································

  private weak var mObserver : EBObserverProtocol? = nil // SOULD BE WEAK

  //····················································································································

  var possibleObserver : EBObserverProtocol? { return self.mObserver }

  //····················································································································

  init (observer inObserver : EBObserverProtocol) {
    self.mObserver = inObserver
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
