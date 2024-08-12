//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutStaticLabel : ALB_NSTextField_enabled_hidden_bindings {

  //································································································
  // INIT
  //································································································

  init (title inTitle : String, bold inBold : Bool, size inSize : EBControlSize, alignment inAlignment : TextAlignment) {
    super.init (optionalWidth: nil, bold: inBold, size: inSize.cocoaControlSize)

    self.stringValue = inTitle
    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false

    self.isEditable = false
    self.alignment = inAlignment.cocoaAlignment
    self.frame.size = self.intrinsicContentSize
    _ = self.expandableWidth ()
  }

  //································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
    super.draw (inDirtyRect)
  }

  //································································································
  // SET TEXT color
  //································································································

  final func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  //································································································

  final func setOrangeTextColor () -> Self {
    self.textColor = .orange
    return self
  }

  //································································································

  final func setRedTextColor () -> Self {
    self.textColor = .red
    return self
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
