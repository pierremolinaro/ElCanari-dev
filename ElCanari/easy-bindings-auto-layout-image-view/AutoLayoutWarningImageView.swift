//
//  AutoLayoutWarningImageView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutWarningImageView
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutWarningImageView : ALB_NSImageView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()

    self.image = NSImage (named: warningStatusImageName)
    self.imageScaling = .scaleProportionallyUpOrDown
    self.imageFrameStyle = .none

    self.frame.size = self.intrinsicContentSize
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $hidden binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private var mHiddenBindingController : HiddenBindingController? = nil
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
//    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
