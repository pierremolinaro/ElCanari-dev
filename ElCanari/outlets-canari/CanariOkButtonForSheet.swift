//
//  CanariOkButtonForSheet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariOkButtonForSheet
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Button/Articles/MakingaButtontheDefaultButton.html
// The style of the button should be "Push" (set it in interface builder)
// Key equivalent should be "carriage return" (set it in interface builder)
// If sheet has text field(s), their "Action" should be "Sent on End Editing"
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariOkButtonForSheet : EBButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.target = self
    self.action = #selector (CanariOkButtonForSheet.dismissSheetAction (_:))
  }

  //····················································································································

  @objc func dismissSheetAction (_ sender : Any?) {
    if let mySheet = self.window, let parent = mySheet.sheetParent {
      mySheet.endEditing (for: nil)
      parent.endSheet (mySheet, returnCode: NSApplication.ModalResponse.stop)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
