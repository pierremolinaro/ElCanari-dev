//
//  CanariCancelButtonForSheet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariCancelButtonForSheet
// The style of the button should be "Push" (set it in interface builder)
// Key equivalent should be "escape" (set it in interface builder)
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariCancelButtonForSheet : EBButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.target = self
    self.action = #selector (CanariCancelButtonForSheet.dismissSheetAction (_:))
  }

  //····················································································································

  @objc func dismissSheetAction (_ sender : Any?) {
    if let myPanel = self.window, let parent = myPanel.sheetParent {
      parent.endSheet (myPanel, returnCode: .abort)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
