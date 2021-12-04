//
//  AutoLayoutVerticalScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutVerticalScrollView : NSScrollView, EBUserClassNameProtocol {

  //····················································································································
  //   INIT
  //····················································································································

  init (content inContentView : NSView) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.drawsBackground = false
    self.documentView = inContentView
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
