//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObjectProtocol
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//protocol EBObservedObjectProtocol : AnyObject {
//  func addEBObserver (_ inObserver : EBObserverProtocol)
//  func removeEBObserver (_ inObserver : EBObserverProtocol)
//  func observedObjectDidChange ()
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//actor EBObservedObjectActor {
//
//  //····················································································································
//
//  private final var mObservers = EBWeakEventSet ()
//
//  //····················································································································
//
//  func addEBObserver (_ inObserver : EBObserverProtocol) {
//    self.mObservers.insert (inObserver)
//    inObserver.observedObjectDidChange ()
//  }
//
//  //····················································································································
//
//  func removeEBObserver (_ inObserver : EBObserverProtocol) {
//    self.mObservers.remove (inObserver)
//  }
//
//  //····················································································································
//
//  func observedObjectDidChange () {
//    for (_, entry) in self.mObservers.dictionary {
//      if let observer = entry.observer {
//        observer.observedObjectDidChange ()
//      }else{
//        self.mObservers.triggerPacking ()
//      }
//    }
//  }
//
//  //····················································································································
//
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservedObject : EBSwiftBaseObject {

  //····················································································································

  private final var mObservers = EBWeakEventSet ()

  //····················································································································

  final func addEBObserver (_ inObserver : EBObserverProtocol) {
    self.mObservers.insert (inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  final func removeEBObserver (_ inObserver : EBObserverProtocol) {
    self.mObservers.remove (inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  func observedObjectDidChange () {
    for (_, entry) in self.mObservers.dictionary {
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
