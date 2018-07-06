//
//  PMOkButtonForPanel.m
//  canari
//
//  Created by Pierre Molinaro on 06/03/05.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariPanelOkButton : NSButton {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    if let myPanel = self.window as? NSPanel, let myCell = self.cell as? NSButtonCell {
      myPanel.defaultButtonCell = myCell
    }
  }

  //····················································································································

  override func sendAction (_ inAction: Selector?, to inTarget: Any?) -> Bool {
    if let myPanel = self.window as? NSPanel {
      myPanel.orderOut (self)
      NSApp.endSheet (myPanel, returnCode:NSModalResponseStop)
    }
    return super.sendAction (inAction, to:inTarget)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
