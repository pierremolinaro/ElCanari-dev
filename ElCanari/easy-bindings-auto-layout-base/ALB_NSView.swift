//
//  ALB_NSView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   ALB_NSView
//--------------------------------------------------------------------------------------------------

class ALB_NSView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .low, vStrechingResistance: .low)
//    self.translatesAutoresizingMaskIntoConstraints = false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinitSoReleaseHiddenControllers ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Changing isHidden does not invalidate constraints !!!!
  // So we perform this operation manually
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidHide () {
    if let superview = self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
    }
    super.viewDidHide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidUnhide () {
    if let superview = self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
    }
    super.viewDidUnhide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
