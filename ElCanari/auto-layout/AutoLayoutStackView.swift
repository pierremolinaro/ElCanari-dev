//----------------------------------------------------------------------------------------------------------------------

import Cocoa

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

  init (orientation inOrientation : NSUserInterfaceLayoutOrientation) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.orientation = inOrientation
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func ebCleanUp () {
    for view in self.subviews {
      view.ebCleanUp ()
    }
    super.ebCleanUp ()
  }

  //····················································································································

  final func appendView (_ inView : NSView) {
    self.addView (inView, in: .leading)
  }

  //····················································································································
  //  MARGINS
  //····················································································································

  func noMargin () -> Self {
    self.edgeInsets.left   = 0.0
    self.edgeInsets.top    = 0.0
    self.edgeInsets.right  = 0.0
    self.edgeInsets.bottom = 0.0
    return self
  }

  //····················································································································

  func set (margins inValue : Int) -> Self {
    let v = CGFloat (inValue)
    self.edgeInsets.left   = v
    self.edgeInsets.top    = v
    self.edgeInsets.right  = v
    self.edgeInsets.bottom = v
    return self
  }

  //····················································································································

  func setTopMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.top = inValue
    return self
  }

  //····················································································································

  func setBottomMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.bottom = inValue
    return self
  }

  //····················································································································

  func setLeftMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.left = inValue
    return self
  }

  //····················································································································

  func setRightMargin (_ inValue : CGFloat) -> Self {
    self.edgeInsets.right = inValue
    return self
  }

  //····················································································································

  func setSpacing (_ inValue : CGFloat) -> Self {
    self.spacing = inValue
    return self
  }

  //····················································································································

  func flexibleSpace () -> Self {
    self.appendView (AutoLayoutFlexibleSpace ())
    return self
  }

  //····················································································································

  func add (item inView : NSView) -> Self {
    self.appendView (inView)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
