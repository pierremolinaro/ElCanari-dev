//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutStaticLabel : ALB_NSTextField {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (title inTitle : String,
        bold inBold : Bool,
        size inSize : EBControlSize,
        alignment inAlignment : TextAlignment) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // SET TEXT color
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setOrangeTextColor () -> Self {
    self.textColor = .orange
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setRedTextColor () -> Self {
    self.textColor = .red
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
