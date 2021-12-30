//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutStaticLabel : AutoLayoutBase_NSTextField {

  //····················································································································
  // INIT
  //····················································································································

  init (title inTitle : String, bold inBold : Bool, size inSize : EBControlSize) {
    super.init (optionalWidth: nil, bold: inBold, size: inSize)

    self.stringValue = inTitle
    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false

    self.isEditable = false
    self.alignment = .right
    self.frame.size = self.intrinsicContentSize
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
//      DEBUG_FILL_COLOR.setFill ()
//      NSBezierPath.fill (inDirtyRect)
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
    super.draw (inDirtyRect)
  }

  //····················································································································
  // SET TEXT color
  //····················································································································

  final func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  //····················································································································

//  final func set (alignment inAlignment : TextAlignment) -> Self {
//    self.alignment = inAlignment.cocoaAlignment
//    return self
//  }

  //····················································································································

  private var mWidth : CGFloat? = nil
  
  //····················································································································

  final func set (width inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
    return self
  }

  //····················································································································

  final func setOrangeTextColor () -> Self {
    self.textColor = .orange
    return self
  }

  //····················································································································

  final func setRedTextColor () -> Self {
    self.textColor = .red
    return self
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    if let w = self.mWidth {
      s.width = w
    }
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

