//
//  ALB_NSSlider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   ALB_NSSlider
//——————————————————————————————————————————————————————————————————————————————————————————————————

class ALB_NSSlider : NSSlider {

  //································································································

  init (min inMin : Int, max inMax : Int, ticks inMarkCount : Int) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.minValue = Double (inMin)
    self.maxValue = Double (inMax)
    self.numberOfTickMarks = inMarkCount
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································
  //  $enabled binding
  //································································································

  private final var mEnabledBindingController : EnabledBindingController? = nil
  final var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //································································································
  //  $hidden binding
  //································································································

  private final var mHiddenBindingController : HiddenBindingController? = nil

  //································································································

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
    return self
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————