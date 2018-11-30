//
//  CanariClipView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariClipView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariClipView : NSClipView, EBUserClassNameProtocol {

  //····················································································································
  //   init
  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  DRAW
  //····················································································································

//  override func draw (_ inDirtyRect : NSRect) {
//    NSColor.green.setFill ()
//    __NSRectFill (inDirtyRect)
//    super.draw (inDirtyRect)
//  }

  //····················································································································

}