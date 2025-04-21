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

  init (size inSize : EBControlSize) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .high, vStrechingResistance: .high)

    self.controlSize = inSize.cocoaControlSize
    let size = NSFont.systemFontSize (for: self.controlSize)
    self.font = NSFont.systemFont (ofSize: size)
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

  func setItems (_ inItemArray : [String]) {
    self.removeAllItems ()
    for item in inItemArray {
      self.addItem (withObjectValue: item)
    }
    self.numberOfVisibleItems = inItemArray.count
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

