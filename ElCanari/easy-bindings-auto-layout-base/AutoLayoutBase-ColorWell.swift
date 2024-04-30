//
//  AutoLayoutBase-ColorWell.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_ColorWell : NSColorWell {

  //································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentCompressionResistancePriority (.required, for: .vertical)
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
