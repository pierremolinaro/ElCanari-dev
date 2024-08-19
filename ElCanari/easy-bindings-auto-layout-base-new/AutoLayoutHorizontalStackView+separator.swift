//
//  PMHorizontalStackView-separator.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutHorizontalStackView {

  //--------------------------------------------------------------------------------------------------------------------

  final func appendVerticalSeparator (ignoreVerticalMargins inFlag : Bool = true) -> Self{
    let separator = Self.VerticalSeparator (ignoreVerticalMargins: inFlag)
    return self.appendView (separator)
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func prependVerticalSeparator (ignoreVerticalMargins inFlag : Bool = true) -> Self {
    let separator = Self.VerticalSeparator (ignoreVerticalMargins: inFlag)
    return self.prependView (separator)
  }

  //--------------------------------------------------------------------------------------------------------------------
  // VerticalSeparator internal class
  //--------------------------------------------------------------------------------------------------------------------

  final class VerticalSeparator : NSBox {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    let mIgnoreVerticalMargins : Bool

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init (ignoreVerticalMargins inFlag : Bool = true) {
      self.mIgnoreVerticalMargins = inFlag
      let s = NSSize (width: 0, height: 10) // width < height means vertical separator
      super.init (frame: NSRect (origin: NSPoint (), size: s))
      self.pmConfigureForAutolayout (hStretchingResistance: .highest, vStrechingResistance: .lowest)

      self.boxType = .separator
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize : NSSize { NSSize (width: 1, height: 10) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings {
      return AutoLayoutViewSettings (
        vLayoutInHorizontalContainer: self.mIgnoreVerticalMargins ? .weakFillIgnoringMargins : .weakFill,
        hLayoutInVerticalContainer: .weakFill // non significant, as vertical separator cannot be inside a vertical stack view
      )
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
