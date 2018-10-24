//
//  CanariCharacterView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariFontSampleStringView : NSView, EBUserClassNameProtocol {

  //····················································································································

  override init(frame frameRect: NSRect) {
    super.init (frame: frameRect)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
  //····················································································································
  //  update display
  //····················································································································

  private var mSampleStringBezierPath = NSBezierPath ()

  //····················································································································

  func updateDisplayFromBezierPathController (_ inBezierPath : NSBezierPath) {
    self.mSampleStringBezierPath = inBezierPath
    self.needsDisplay = true
  }


  //····················································································································
  //  isOpaque
  //····················································································································

  override var isOpaque : Bool { return true }

  //····················································································································
  //  drawRect
  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
    NSColor.white.setFill ()
    __NSRectFill (inDirtyRect)
    NSColor.black.setStroke ()
    var bp = NSBezierPath (rect:self.bounds.insetBy(dx: 0.5, dy: 0.5))
    bp.lineWidth = 1.0
    bp.stroke ()
    if !self.mSampleStringBezierPath.isEmpty {
      let size = self.mSampleStringBezierPath.bounds.size
      let tr = NSAffineTransform ()
      tr.translateX (by: (self.bounds.size.width - size.width) * 0.5, yBy: (self.bounds.size.height - size.height) * 0.5)
      bp = tr.transform (self.mSampleStringBezierPath)
      NSColor.black.setStroke ()
      bp.lineJoinStyle = .round
      bp.lineCapStyle = .round
      bp.stroke ()
    }
  }

  //····················································································································
  //  $bezierPath binding
  //····················································································································

  private var mBezierPathBindingController : Controller_CanariFontSampleStringView_bezierPath?

  final func bind_bezierPath (_ object:EBReadOnlyProperty_NSBezierPath, file:String, line:Int) {
    mBezierPathBindingController = Controller_CanariFontSampleStringView_bezierPath (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_bezierPath () {
    mBezierPathBindingController?.unregister ()
    mBezierPathBindingController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
