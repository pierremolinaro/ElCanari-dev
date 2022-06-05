//
//  AutoLayoutHorizontalSplitView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutHorizontalSplitView : AutoLayoutBase_NSSplitView {

  //····················································································································

  init () {
    super.init (dividersAreVertical: true)

    self.setContentHuggingPriority (.required, for: .vertical)
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
