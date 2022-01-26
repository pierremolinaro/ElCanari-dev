//
//  AutoLayoutVerticalScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/53239922/nsscrollview-vertical-align
// https://github.com/mattiasjahnke/NSStackView-Scroll
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutVerticalScrollView : NSScrollView, EBUserClassNameProtocol {

  //····················································································································
  //   INIT
  //····················································································································

  init (content inDocumentView : NSView) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.contentView = MyFlippedClipView () // So is aligned to top (instead of bottom)
    self.drawsBackground = false
    self.documentView = inDocumentView
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
    self.automaticallyAdjustsContentInsets = true
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class MyFlippedClipView : NSClipView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
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

  override var isFlipped : Bool { return true }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
