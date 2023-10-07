//
//  AutoLayoutVerticalScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/53239922/nsscrollview-vertical-align
// https://github.com/mattiasjahnke/NSStackView-Scroll
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutVerticalScrollView : NSScrollView {

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

  //  Swift.print ("Vertical Scroller \(self.verticalScroller)")
    if let verticalScroller = self.verticalScroller {
      let c = NSLayoutConstraint (
        item: self,
        attribute: .width,
        relatedBy: .equal,
        toItem: inDocumentView,
        attribute: .width,
        multiplier: 1.0,
        constant: verticalScroller.frame.size.width
      )
      self.addConstraint (c)
    }
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

fileprivate final class MyFlippedClipView : NSClipView {

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
