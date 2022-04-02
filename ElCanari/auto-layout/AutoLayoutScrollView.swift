//
//  AutoLayoutScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutScrollView : NSScrollView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect (x: 0, y: 0, width: 10, height: 10))
    self.translatesAutoresizingMaskIntoConstraints = false
    noteObjectAllocation (self)

    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 100, height: 100)
  }

  //····················································································································

//  func clipViewOrigin () -> NSPoint? {
//    if let clipView = self.contentView () {
//      return clipView.convert (clipView.frame.origin, to: self)
//    }else{
//      return nil
//    }
//  }

  //····················································································································

//  func setClipViewOrigin (_ inCurrentClipViewOrigin : NSPoint?) {
//    if let currentClipViewOrigin = inCurrentClipViewOrigin, let clipView = self.contentView () as? NSClipView {
//      self.scroll (clipView, to: NSPoint (x: currentClipViewOrigin.x, y: -currentClipViewOrigin.y))
////      var f = clipView.frame
////      f.origin = currentClipViewOrigin
////      clipView.frame = f
//    }
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
