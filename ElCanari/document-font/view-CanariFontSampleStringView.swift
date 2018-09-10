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
  private var mSampleStringSize : CGFloat = 1.0

  //····················································································································

  func updateDisplayFromBezierPathController (_ inBezierPath : NSBezierPath) {
    self.mSampleStringBezierPath = inBezierPath
    self.needsDisplay = true
  }

  //····················································································································
  
  func updateDisplayFromFontSizeController (_ fontSize : Double) {
    self.mSampleStringSize = 2.0 * CGFloat (fontSize) / 14.0
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
    NSRectFill (inDirtyRect)
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
      bp.lineWidth = self.mSampleStringSize
      bp.lineJoinStyle = .roundLineJoinStyle
      bp.lineCapStyle = .roundLineCapStyle
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
  //  $sampleStringFontSize binding
  //····················································································································

  private var mSampleStringFontSizeBindingController : Controller_CanariFontSampleStringView_sampleStringFontSize?

  final func bind_sampleStringFontSize (_ object:EBReadOnlyProperty_Double, file:String, line:Int) {
    mSampleStringFontSizeBindingController = Controller_CanariFontSampleStringView_sampleStringFontSize (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_sampleStringFontSize () {
    mSampleStringFontSizeBindingController?.unregister ()
    mSampleStringFontSizeBindingController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
