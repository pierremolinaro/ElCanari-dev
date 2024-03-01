//
//  AutoLayoutHorizontalStackView-separator.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutHorizontalStackView {

  //································································································

  final func appendVerticalSeparator () {
    let separator = Self.VerticalSeparator ()
    _ = self.appendView (separator)
  }

  //································································································

  final func prependVerticalSeparator () {
    let separator = Self.VerticalSeparator ()
    _ = self.prependView (separator)
  }

  //································································································
  // VerticalSeparator internal class
  //································································································

  final class VerticalSeparator : NSBox {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init () {
      let s = NSSize (width: 0, height: 10) // width == 0, height > 0 means vertical separator
      super.init (frame: NSRect (origin: NSPoint (), size: s))
      noteObjectAllocation (self)
      self.translatesAutoresizingMaskIntoConstraints = false
      self.boxType = .separator
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    deinit {
      noteObjectDeallocation (self)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
