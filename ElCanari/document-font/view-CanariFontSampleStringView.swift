//
//  CanariCharacterView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/11/2015.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

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
    NSBezierPath.fill (inDirtyRect)
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

  final private func updateBezierPath (_ object : EBReadOnlyProperty_NSBezierPath) {
    switch object.prop {
    case .empty, .multiple :
      break ;
    case .single (let bezierPath) :
      self.updateDisplayFromBezierPathController (bezierPath)
    }
  }

  //····················································································································

  private var mBezierPathBindingController : EBSimpleController?

  final func bind_bezierPath (_ object : EBReadOnlyProperty_NSBezierPath, file : String, line : Int) {
    self.mBezierPathBindingController = EBSimpleController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateBezierPath (object) }
    )
  }

  //····················································································································

  final func unbind_bezierPath () {
    self.mBezierPathBindingController?.unregister ()
    self.mBezierPathBindingController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
