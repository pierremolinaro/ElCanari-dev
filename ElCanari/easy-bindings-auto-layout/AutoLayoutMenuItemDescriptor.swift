//
//  AutoLayoutMenuItemDescriptor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutMenuItemDescriptor {

  //····················································································································

  let title : String
  let target : NSObject?
  let selector : Selector?
  let enableBinding : EBMultipleBindingBooleanExpression

  //····················································································································

  init (title inTitle : String,
        target inTarget : NSObject?,
        selector inSelector : Selector?,
        enableBinding inBinding : EBMultipleBindingBooleanExpression) {
    self.title = inTitle
    self.target = inTarget
    self.selector = inSelector
    self.enableBinding = inBinding
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
