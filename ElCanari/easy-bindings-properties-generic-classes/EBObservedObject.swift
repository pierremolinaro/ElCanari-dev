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

  private final var mDictionary = [ObjectIdentifier : EBWeakObserverSetElement] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func startsBeingObserved (by inObserver : any EBObserverProtocol) {
    let key = ObjectIdentifier (inObserver)
    self.mDictionary [key] = EBWeakObserverSetElement (observer: inObserver)
    inObserver.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func stopsBeingObserved (by inObserver : any EBObserverProtocol) {
    let key = ObjectIdentifier (inObserver)
    self.mDictionary [key] = nil
    inObserver.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func currentObjectDidChange () {
    self.mObserverCallback? ()
    for (key, entry) in self.mDictionary {
      if let observer = entry.possibleObserver {
        observer.observedObjectDidChange ()
      }else{
        self.mDictionary [key] = nil
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mObserverCallback : (() -> Void)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   EBWeakObserverSetElement
//--------------------------------------------------------------------------------------------------

fileprivate struct EBWeakObserverSetElement {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mObserver : (any EBObserverProtocol)? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var possibleObserver : (any EBObserverProtocol)? { return self.mObserver }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (observer inObserver : any EBObserverProtocol) {
    self.mObserver = inObserver
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
