//
//  AutoLayoutVerticalStackView-separator.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class VerticalStackSeparator : NSBox {

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mIgnoreHorizontalMargins : Bool

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (ignoreHorizontalMargins inFlag : Bool = true) {
    self.mIgnoreHorizontalMargins = inFlag
    let s = NSSize (width: 10, height: 1) // width > height means horizontal separator
    super.init (frame: NSRect (origin: NSPoint (), size: s))
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .highest)

    self.boxType = .separator
  }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize { NSSize (width: NSView.noIntrinsicMetric, height: 1.0) }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLayoutSettings : AutoLayoutViewSettings {
    return AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .fill, // non significant, as vertical separator cannot be inside a vertical stack view
      hLayoutInVerticalContainer: self.mIgnoreHorizontalMargins ? .fillIgnoringMargins : .fill
    )
  }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
