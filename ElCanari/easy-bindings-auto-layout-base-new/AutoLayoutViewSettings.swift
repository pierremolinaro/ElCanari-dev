//
//  AutoLayoutViewSettings.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutViewSettings : NSObject {

  //--------------------------------------------------------------------------------------------------------------------

  let hLayoutInVerticalContainer : ALB_NSStackView.HorizontalLayoutInVerticalCollectionView
  let vLayoutInHorizontalContainer : ALB_NSStackView.VerticalLayoutInHorizontalCollectionView

  //--------------------------------------------------------------------------------------------------------------------

  init (vLayoutInHorizontalContainer inVerticalDisposition : ALB_NSStackView.VerticalLayoutInHorizontalCollectionView,
        hLayoutInVerticalContainer inHorizontalDisposition : ALB_NSStackView.HorizontalLayoutInVerticalCollectionView) {
    self.hLayoutInVerticalContainer = inHorizontalDisposition
    self.vLayoutInHorizontalContainer = inVerticalDisposition
  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
