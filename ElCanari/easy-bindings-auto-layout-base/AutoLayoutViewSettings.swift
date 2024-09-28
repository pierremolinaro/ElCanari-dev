//
//  AutoLayoutViewSettings.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

class AutoLayoutViewSettings : NSObject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let hLayoutInVerticalContainer : ALB_NSStackView.HorizontalLayoutInVerticalStackView
  let vLayoutInHorizontalContainer : ALB_NSStackView.VerticalLayoutInHorizontalStackView

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (vLayoutInHorizontalContainer inVerticalDisposition : ALB_NSStackView.VerticalLayoutInHorizontalStackView,
        hLayoutInVerticalContainer inHorizontalDisposition : ALB_NSStackView.HorizontalLayoutInVerticalStackView) {
    self.hLayoutInVerticalContainer = inHorizontalDisposition
    self.vLayoutInHorizontalContainer = inVerticalDisposition
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
