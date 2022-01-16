//
//  AutoLayoutHorizontalSplitView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutHorizontalSplitView : AutoLayoutBase_NSSplitView {

  //····················································································································

  init () {
    super.init (dividersAreVertical: true)

//    self.setContentHuggingPriority (.required, for: .horizontal)
    self.setContentHuggingPriority (.required, for: .vertical)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
//    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
