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
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariOkButtonForSheet : EBButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
//    if let mySheet = self.window, let okCell = self.cell as? NSButtonCell {
//      mySheet.defaultButtonCell = okCell
//      mySheet.enableKeyEquivalentForDefaultButtonCell ()
//      self.keyEquivalent = "\r"
      self.target = self
      self.action = #selector (CanariOkButtonForSheet.dismissSheetAction (_:))
//    }
  }

  //····················································································································

  @objc func dismissSheetAction (_ sender : Any?) {
    if let mySheet = self.window, let parent = mySheet.sheetParent {
      parent.endSheet (mySheet, returnCode: NSApplication.ModalResponse.stop)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
