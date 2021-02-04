//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

var gCurrentStack : AutoLayoutStackView? = nil

//----------------------------------------------------------------------------------------------------------------------

func addAutoLayoutView (_ inView : NSView) {
  gCurrentStack?.addView (inView, in: .leading)
}

//----------------------------------------------------------------------------------------------------------------------

func showDebugBackground () {
  gDebugBackground = NSColor.black.withAlphaComponent (0.05)
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate var gDebugBackground : NSColor? = nil

//----------------------------------------------------------------------------------------------------------------------

func debugBackgroundColor () -> NSColor? {
  return gDebugBackground
}

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutStackView : NSStackView, EBUserClassNameProtocol {

  //····················································································································
  //   INIT
  //····················································································································

  init (orientation inOrientation : NSUserInterfaceLayoutOrientation, margin inMargin : UInt) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.orientation = inOrientation
    let margin = CGFloat (inMargin)
    self.edgeInsets.left   = margin
    self.edgeInsets.top    = margin
    self.edgeInsets.right  = margin
    self.edgeInsets.bottom = margin
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  //  MARGINS
  //····················································································································

  @discardableResult func noMargin () -> Self {
    self.edgeInsets.left   = 0.0
    self.edgeInsets.top    = 0.0
    self.edgeInsets.right  = 0.0
    self.edgeInsets.bottom = 0.0
    return self
  }

  //····················································································································

  @discardableResult func setMargins (_ inValue : CGFloat) -> Self {
    self.edgeInsets.left   = inValue
    self.edgeInsets.top    = inValue
    self.edgeInsets.right  = inValue
    self.edgeInsets.bottom = inValue
    return self
  }

  //····················································································································

  @discardableResult func setTopMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.top = inValue
    return self
  }

  //····················································································································

  @discardableResult func setBottomMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.bottom = inValue
    return self
  }

  //····················································································································

  @discardableResult func setLeftMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.left = inValue
    return self
  }

  //····················································································································

  @discardableResult func setRightMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.right = inValue
    return self
  }

  //····················································································································

  @discardableResult func setSpacing (_ inValue : CGFloat) -> Self {
    self.spacing = inValue
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
