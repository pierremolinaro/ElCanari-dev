//
//  AutoLayoutDatePicker.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 11/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutBase_DatePicker : NSDatePicker {

  //································································································

  init (size inSize : EBControlSize) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.controlSize = inSize.cocoaControlSize
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
