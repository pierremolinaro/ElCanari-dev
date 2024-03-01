//
//  EBSimpleObserver.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class EBSimpleObserver : EBObserverProtocol {

  //································································································

  weak private var mObservedObject : EBObservedObject?
  private var mCallBack : Optional < () -> Void >

  //································································································

  init (object inObject : EBObservedObject, _ inCallBack : @escaping () -> Void) {
    self.mObservedObject = inObject
    self.mCallBack = inCallBack
    noteObjectAllocation (self)
    inObject.startsBeingObserved (by: self)
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

  func invalidate () {
    self.mObservedObject?.stopsBeingObserved (by: self)
    self.mObservedObject = nil
    self.mCallBack = nil
  }

  //································································································

  func observedObjectDidChange () {
    self.mCallBack? ()
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
