//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutLabel : NSTextField, EBUserClassNameProtocol {

  //····················································································································
  // INIT
  //····················································································································

  init () {
    let inTitle = "ESSAI"
//    let inBold = true
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.stringValue = inTitle
    self.isBezeled = false
    self.isBordered = false
    self.backgroundColor = debugBackgroundColor ()
    self.drawsBackground = self.backgroundColor != nil
    self.textColor = .black
    self.isEnabled = true
    self.isEditable = false
    //self.font = inBold ? NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize) : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    self.font = NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // SET TEXT color
  //····················································································································

  func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  //····················································································································
  // SET TITLE ALIGNMENT
  //····················································································································

  func setTitleAlignment (_ inAlignment : NSTextAlignment) -> Self {
    self.alignment = inAlignment
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

