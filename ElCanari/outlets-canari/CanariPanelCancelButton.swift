//
//  PMCancelButtonForPanel.m
//  canari
//
//  Created by Pierre Molinaro on 06/03/05.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariPanelCancelButton : NSButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
 //   self.setKeyEquivalent ("\E")
  }

  //····················································································································

  override func sendAction(_ inAction: Selector?, to inTarget: Any?) -> Bool {
    if let myPanel = self.window as? NSPanel {
      myPanel.orderOut (self)
      NSApp.endSheet (myPanel, returnCode:NSModalResponseAbort)
    }
    return super.sendAction (inAction, to:inTarget)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
