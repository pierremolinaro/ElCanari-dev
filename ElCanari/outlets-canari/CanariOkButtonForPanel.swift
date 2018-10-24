//
//  CanariOkButtonForPanel.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariOkButtonForPanel
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariOkButtonForPanel : EBButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    if let myPanel = self.window {
  //    NSLog ("myPanel \(myPanel)")
      if let okCell = self.cell as? NSButtonCell {
        myPanel.defaultButtonCell = okCell
      }
      self.target = self
      self.action = #selector (CanariOkButtonForPanel.dismissPanelAction (_:))
    }
  }

  //····················································································································

  @objc func dismissPanelAction (_ sender : Any?) {
    if let myPanel = self.window, let parent = myPanel.sheetParent {
      parent.endSheet (myPanel, returnCode: NSApplication.ModalResponse.stop)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
