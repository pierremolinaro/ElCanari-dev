//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Build PDF image
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func buildPDFimage (frame inFrame : CGRect,
                    shape inShape : EBShape,
                    backgroundColor inBackColor : NSColor? = nil) -> Data {
  let view = EBOffscreenView (frame: inFrame)
  view.setBackColor (inBackColor)
  view.setShape (inShape)
  return view.dataWithPDF (inside: inFrame)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBOffscreenView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class EBOffscreenView : NSView, EBUserClassNameProtocol {

  private var mShape = EBShape ()
  private var mBackColor : NSColor? = nil

  //····················································································································

  override init (frame frameRect: NSRect) {
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
  //  Set paths
  //····················································································································

  func setShape (_ inShape : EBShape) {
    self.mShape = inShape
  }

  //····················································································································
  //  Set back color
  //····················································································································

  func setBackColor (_ inColor : NSColor?) {
    self.mBackColor = inColor
  }

  //····················································································································
  //  Draw Rect
  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
    if let backColor = mBackColor {
      backColor.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
  //--- Bezier paths
    self.mShape.draw (inDirtyRect)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————