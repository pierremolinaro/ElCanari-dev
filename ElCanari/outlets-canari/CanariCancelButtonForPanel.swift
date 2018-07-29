//
//  CanariCancelButtonForPanel.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariCancelButtonForPanel
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariCancelButtonForPanel : EBButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.target = self
    self.action = #selector (CanariCancelButtonForPanel.dismissPanelAction (_:))
  }

  //····················································································································

  @objc func dismissPanelAction (_ sender : Any?) {
    if let myPanel = self.window, let parent = myPanel.sheetParent {
      #if swift(>=4)
        parent.endSheet (myPanel, returnCode: .abort)
      #else
        parent.endSheet (myPanel, returnCode: NSModalResponseAbort)
      #endif
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
