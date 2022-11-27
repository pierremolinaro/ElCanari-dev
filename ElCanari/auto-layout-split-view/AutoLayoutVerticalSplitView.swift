//
//  AutoLayoutVerticalSplitView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutVerticalSplitView : AutoLayoutBase_NSSplitView {

  //····················································································································

  init () {
    super.init (dividersAreVertical: false)

    self.setContentHuggingPriority (.required, for: .horizontal)
//    self.setContentHuggingPriority (.required, for: .vertical)
//    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
