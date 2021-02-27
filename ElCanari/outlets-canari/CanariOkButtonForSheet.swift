//
//  CanariOkButtonForSheet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariOkButtonForSheet
//----------------------------------------------------------------------------------------------------------------------
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Button/Articles/MakingaButtontheDefaultButton.html
// The style of the button should be "Push" (set it in interface builder)
// Key equivalent should be "carriage return" (set it in interface builder)
// If sheet has text field(s), their "Action" should be "Sent on End Editing"
//----------------------------------------------------------------------------------------------------------------------

class CanariOkButtonForSheet : EBButton {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    self.setButtonType (.momentaryPushIn)
    self.bezelStyle = .rounded
    self.title = "Done"
 //   self.keyEquivalent = "\r"
    self.target = self
    self.action = #selector (Self.dismissSheetAction (_:))
  }

  //····················································································································

  override init (frame inFrame : NSRect) {
    super.init (frame: inFrame)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    super.init (coder: inCoder)
  }

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.target = self
    self.action = #selector (Self.dismissSheetAction (_:))
  }

  //····················································································································

  @objc func dismissSheetAction (_ sender : Any?) {
    if let mySheet = self.window, let parent = mySheet.sheetParent {
      mySheet.endEditing (for: nil)
      parent.endSheet (mySheet, returnCode: .stop)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
