//
//  AutoLayoutHorizontalStackView+gutter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let GUTTER_WIDTH = 4.0

//--------------------------------------------------------------------------------------------------

extension AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // GutterSeparator internal class
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class GutterSeparator : ALB_NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize : NSSize { NSSize (width: GUTTER_WIDTH, height: NSView.noIntrinsicMetric) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings {
      return AutoLayoutViewSettings (
        vLayoutInHorizontalContainer: .fillIgnoringMargins,
        hLayoutInVerticalContainer: .fill // non significant, as vertical separator cannot be inside a vertical stack view
      )
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
