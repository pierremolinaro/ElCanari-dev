//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutStaticLabel : NSTextField, EBUserClassNameProtocol {

  //····················································································································
  // INIT
  //····················································································································

  init (title inTitle : String, bold inBold : Bool, small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.stringValue = inTitle
    self.isBezeled = false
    self.isBordered = false
//    self.backgroundColor = debugBackgroundColor ()
//    self.drawsBackground = self.backgroundColor != nil
    self.drawsBackground = false
    self.textColor = .black
    self.isEnabled = true
    self.isEditable = false
    self.alignment = .right
    self.controlSize = inSmall ? .small : .regular
    let size = inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize
    self.font = inBold ? NSFont.boldSystemFont (ofSize:size) : NSFont.systemFont (ofSize: size)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if let color = debugBackgroundColor () {
      color.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
    super.draw (inDirtyRect)
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

//  func setTitleAlignment (_ inAlignment : NSTextAlignment) -> Self {
//    self.alignment = inAlignment
//    return self
//  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

