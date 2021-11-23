//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutAbstractStackView : NSStackView, EBUserClassNameProtocol {

  //····················································································································
  //   INIT
  //····················································································································

  init (orientation inOrientation : NSUserInterfaceLayoutOrientation) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.orientation = inOrientation
    self.distribution = .fill
    self.edgeInsets.left   = 0.0
    self.edgeInsets.top    = 0.0
    self.edgeInsets.right  = 0.0
    self.edgeInsets.bottom = 0.0
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func ebCleanUp () {
    for view in self.subviews {
      view.ebCleanUp ()
    }
    super.ebCleanUp ()
  }

  //····················································································································

  @discardableResult final func appendView (_ inView : NSView) -> Self {
    self.addView (inView, in: .leading)
    return self
  }

  //····················································································································

  @discardableResult final func appendFlexibleSpace () -> Self {
    self.addView (AutoLayoutFlexibleSpace (), in: .leading)
    return self
  }

  //····················································································································
  //   DRAW
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
      DEBUG_FILL_COLOR.setFill ()
      NSBezierPath.fill (inDirtyRect)
      var r = self.bounds
      r.origin.x += self.edgeInsets.left
      r.origin.y += self.edgeInsets.bottom
      r.size.width -= self.edgeInsets.left + self.edgeInsets.right
      r.size.height -= self.edgeInsets.top + self.edgeInsets.bottom
      var bp = NSBezierPath (rect: r)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      let array : [CGFloat] = [1.0, 1.0]
      bp.setLineDash (array, count: array.count, phase: 0.0)
      bp.stroke ()
      bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      bp.stroke ()
    }
    super.draw (inDirtyRect)
  }
  
  //····················································································································
  //  MARGINS
  //····················································································································

  final func set (spacing inValue : Int) -> Self {
    let v = CGFloat (inValue)
    self.spacing = v
    return self
  }

  //····················································································································

//  final func noMargin () -> Self {
//    self.edgeInsets.left   = 0.0
//    self.edgeInsets.top    = 0.0
//    self.edgeInsets.right  = 0.0
//    self.edgeInsets.bottom = 0.0
//    return self
//  }

  //····················································································································

  final func set (margins inValue : Int) -> Self {
    let v = CGFloat (inValue)
    self.edgeInsets.left   = v
    self.edgeInsets.top    = v
    self.edgeInsets.right  = v
    self.edgeInsets.bottom = v
    return self
  }

  //····················································································································

  final func set (topMargin inValue : Int) -> Self {
    self.edgeInsets.top = CGFloat (inValue)
    return self
  }

  //····················································································································

  final func set (bottomMargin inValue : Int) -> Self {
    self.edgeInsets.bottom = CGFloat (inValue)
    return self
  }

  //····················································································································

  final func set (leftMargin inValue : Int) -> Self {
    self.edgeInsets.left = CGFloat (inValue)
    return self
  }

  //····················································································································

  final func set (rightMargin inValue : Int) -> Self {
    self.edgeInsets.right = CGFloat (inValue)
    return self
  }

  //····················································································································

  final func setSpacing (_ inValue : Int) -> Self {
    self.spacing = CGFloat (inValue)
    return self
  }

  //····················································································································

  final func flexibleSpace () -> Self {
    self.appendView (AutoLayoutFlexibleSpace ())
    return self
  }

  //····················································································································

  final func add (item inView : NSView) -> Self {
    self.appendView (inView)
    return self
  }

  //····················································································································

  override func observeValue (forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
    if keyPath == "hidden" {
      var allAreHidden = true
      for view in self.subviews {
        if !view.isHidden && !(view is AutoLayoutFlexibleSpace) {
          allAreHidden = false
        }
      }
      if self.isHidden != allAreHidden {
        self.isHidden = allAreHidden
      }
    }
    super.observeValue (forKeyPath: keyPath, of: object, change: change, context: context)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
