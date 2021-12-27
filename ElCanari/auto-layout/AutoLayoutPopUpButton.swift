//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (frame: NSRect (), pullsDown: false)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
