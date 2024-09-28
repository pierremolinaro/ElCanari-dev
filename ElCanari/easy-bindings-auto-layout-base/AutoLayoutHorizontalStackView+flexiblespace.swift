//
//  AutoLayoutHorizontalStackView+flexiblespace.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // FlexibleSpace internal class
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class FlexibleSpace : NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init () {
      super.init (frame: .zero)
      noteObjectAllocation (self)
      self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder: NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    deinit {
      noteObjectDeallocation (self)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private static let mFlexibleSpaceLayoutSettings = AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .fill,
      hLayoutInVerticalContainer: .fill
    )

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings { Self.mFlexibleSpaceLayoutSettings }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
