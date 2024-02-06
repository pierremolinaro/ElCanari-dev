//
//  AutoLayoutScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutScrollView : NSScrollView {

  //····················································································································

  init () {
    super.init (frame: NSRect (x: 0, y: 0, width: 10, height: 10))
    self.translatesAutoresizingMaskIntoConstraints = false
    noteObjectAllocation (self)

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
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

//——————————————————————————————————————————————————————————————————————————————————————————————————
