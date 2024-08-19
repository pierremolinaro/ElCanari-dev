//
//  AutoLayoutVerticalStackView-separator.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutVerticalStackView {

  //--------------------------------------------------------------------------------------------------------------------

  final func appendHorizontalSeparator (ignoreHorizontalMargins inFlag : Bool = true) { // -> Self {
    let separator = Self.HorizontalSeparator (ignoreHorizontalMargins: inFlag)
    _ = self.appendView (separator)
//    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func prependVerticalSeparator (ignoreHorizontalMargins inFlag : Bool = true) -> Self {
    let separator = Self.HorizontalSeparator (ignoreHorizontalMargins: inFlag)
    _ = self.prependView (separator)
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------
  // HorizontalSeparator internal class
  //--------------------------------------------------------------------------------------------------------------------

  final class HorizontalSeparator : NSBox {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    let mIgnoreHorizontalMargins : Bool

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init (ignoreHorizontalMargins inFlag : Bool = true) {
      self.mIgnoreHorizontalMargins = inFlag
      let s = NSSize (width: 10, height: 1) // width > height means horizontal separator
      super.init (frame: NSRect (origin: NSPoint (), size: s))

      self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .highest)

      self.boxType = .separator
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize : NSSize { NSSize (width: 10, height: 1) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings {
      return AutoLayoutViewSettings (
        vLayoutInHorizontalContainer: .weakFill, // non significant, as vertical separator cannot be inside a vertical stack view
        hLayoutInVerticalContainer: self.mIgnoreHorizontalMargins ? .weakFillIgnoringMargins : .weakFill
      )
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
