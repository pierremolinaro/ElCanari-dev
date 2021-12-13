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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
