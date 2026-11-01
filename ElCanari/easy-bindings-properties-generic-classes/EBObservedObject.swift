//
//  EBObservedObject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/03/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBObservedObject
//--------------------------------------------------------------------------------------------------

class EBObservedObject : EBObservableObjectProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mObserverCallback : (() -> Void)? = nil
//  private final var mDictionary = [ObjectIdentifier : EBWeakObserverSetElement] ()
  private final var mWeakObservers = NSHashTable <AnyObject> (options: [.weakMemory, .objectPointerPersonality])

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var objectIndex : Int { return Int (bitPattern: ObjectIdentifier (self)) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func startsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mWeakObservers.add (inObserver)
//    let key = ObjectIdentifier (inObserver)
//    self.mDictionary [key] = EBWeakObserverSetElement (observer: inObserver)
    inObserver.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func stopsBeingObserved (by inObserver : any EBObserverProtocol) {
    self.mWeakObservers.remove (inObserver)
//    let key = ObjectIdentifier (inObserver)
//    self.mDictionary [key] = nil
    inObserver.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func currentObjectDidChange () {
    self.mObserverCallback? ()
    for observer in self.mWeakObservers.allObjects {
      if let obs = observer as? any EBObserverProtocol {
        obs.observedObjectDidChange ()
      }
    }
//    for (key, entry) in self.mDictionary {
//      if let observer = entry.possibleObserver {
//        observer.observedObjectDidChange ()
//      }else{
//        self.mDictionary [key] = nil
//      }
//    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   EBWeakObserverSetElement
//--------------------------------------------------------------------------------------------------

//fileprivate struct EBWeakObserverSetElement {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  private weak var mObserver : (any EBObserverProtocol)? = nil // SOULD BE WEAK
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  var possibleObserver : (any EBObserverProtocol)? { return self.mObserver }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init (observer inObserver : any EBObserverProtocol) {
//    self.mObserver = inObserver
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------
