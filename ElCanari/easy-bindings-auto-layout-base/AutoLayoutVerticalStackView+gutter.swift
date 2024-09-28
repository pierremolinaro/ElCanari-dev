//
//  AutoLayoutVerticalStackView+gutter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let GUTTER_HEIGHT = 4.0

//--------------------------------------------------------------------------------------------------

extension AutoLayoutVerticalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // GutterSeparator internal class
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class GutterSeparator : ALB_NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize : NSSize {
      NSSize (width: NSView.noIntrinsicMetric, height: GUTTER_HEIGHT)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings {
      return AutoLayoutViewSettings (
        vLayoutInHorizontalContainer: .fill, // non significant, as h separator cannot be inside a vertical stack view
        hLayoutInVerticalContainer: .fillIgnoringMargins
      )
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
