//
//  ALB_NSComboBox.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   ALB_NSComboBox
//--------------------------------------------------------------------------------------------------

class ALB_NSComboBox : NSComboBox {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .high, vStrechingResistance: .high)
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
    objectDidDeinitSoReleaseEnabledBindingController ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Changing isHidden does not invalidate constraints !!!!
  // So we perform this operation manually
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidHide () {
    if let superview = self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
      buildResponderKeyChainForWindowThatContainsView (self)
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

  override func removeFromSuperview () {
    buildResponderKeyChainForWindowThatContainsView (self)
    super.removeFromSuperview ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

