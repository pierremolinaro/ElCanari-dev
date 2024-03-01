//
//  AutoLayoutProgressIndicator.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutProgressIndicator : NSProgressIndicator {

  //································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.isIndeterminate = false
  }

  //································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
