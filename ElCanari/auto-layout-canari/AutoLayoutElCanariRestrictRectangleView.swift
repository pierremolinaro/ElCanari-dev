//
//  AutoLayoutElCanariRestrictRectangleView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 15/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutElCanariRestrictRectangleView : AutoLayoutVerticalStackView {

  //····················································································································

  private let mFrontLayerCheckBox = AutoLayoutCheckbox (title: "Front Layer", size: .small)
  private let mBackLayerCheckBox = AutoLayoutCheckbox (title: "Back Layer", size: .small)
  private let mInner1LayerCheckBox = AutoLayoutCheckbox (title: "Inner1 Layer", size: .small)
  private let mInner2LayerCheckBox = AutoLayoutCheckbox (title: "Inner2 Layer", size: .small)
  private let mInner3LayerCheckBox = AutoLayoutCheckbox (title: "Inner3 Layer", size: .small)
  private let mInner4LayerCheckBox = AutoLayoutCheckbox (title: "Inner4 Layer", size: .small)

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override init () {
    super.init ()
    self.appendView (self.mFrontLayerCheckBox)
    self.appendView (self.mBackLayerCheckBox)
    self.appendView (self.mInner1LayerCheckBox)
    self.appendView (self.mInner2LayerCheckBox)
    self.appendView (self.mInner3LayerCheckBox)
    self.appendView (self.mInner4LayerCheckBox)
  }

  //····················································································································

  func bind_front (_ inModel : EBReadWriteProperty_Bool) -> Self {
    _ = self.mFrontLayerCheckBox.bind_value (inModel)
      .bind_run (target: self, selector: #selector (Self.checkBoxAction (_:)))
    return self
  }

  //····················································································································

  func bind_back (_ inModel : EBReadWriteProperty_Bool) -> Self {
    _ = self.mBackLayerCheckBox.bind_value (inModel)
      .bind_run (target: self, selector: #selector (Self.checkBoxAction (_:)))
    return self
  }

  //····················································································································

  func bind_inner1 (_ inModel : EBReadWriteProperty_Bool) -> Self {
    _ = self.mInner1LayerCheckBox.bind_value (inModel)
      .bind_run (target: self, selector: #selector (Self.checkBoxAction (_:)))
    return self
  }

  //····················································································································

  func bind_inner2 (_ inModel : EBReadWriteProperty_Bool) -> Self {
    _ = self.mInner2LayerCheckBox.bind_value (inModel)
      .bind_run (target: self, selector: #selector (Self.checkBoxAction (_:)))
    return self
  }

  //····················································································································

  func bind_inner3 (_ inModel : EBReadWriteProperty_Bool) -> Self {
    _ = self.mInner3LayerCheckBox.bind_value (inModel)
      .bind_run (target: self, selector: #selector (Self.checkBoxAction (_:)))
    return self
  }

  //····················································································································

  func bind_inner4 (_ inModel : EBReadWriteProperty_Bool) -> Self {
    _ = self.mInner4LayerCheckBox.bind_value (inModel)
      .bind_run (target: self, selector: #selector (Self.checkBoxAction (_:)))
    return self
  }

  //····················································································································

  @objc private func checkBoxAction (_ inSender : Any?) {
    let front  = self.mFrontLayerCheckBox.state == .on
    let back   = self.mBackLayerCheckBox.state == .on
    let inner1 = self.mInner1LayerCheckBox.state == .on
    let inner2 = self.mInner2LayerCheckBox.state == .on
    let inner3 = self.mInner3LayerCheckBox.state == .on
    let inner4 = self.mInner4LayerCheckBox.state == .on
    let count = (front ? 1 : 0) + (back ? 1 : 0) + (inner1 ? 1 : 0) + (inner2 ? 1 : 0) + (inner3 ? 1 : 0) + (inner4 ? 1 : 0)
    if count > 1 {
      self.mFrontLayerCheckBox.enable  (fromEnableBinding: true, nil)
      self.mBackLayerCheckBox.enable   (fromEnableBinding: true, nil)
      self.mInner1LayerCheckBox.enable (fromEnableBinding: true, nil)
      self.mInner2LayerCheckBox.enable (fromEnableBinding: true, nil)
      self.mInner3LayerCheckBox.enable (fromEnableBinding: true, nil)
      self.mInner4LayerCheckBox.enable (fromEnableBinding: true, nil)
    }else{
      self.mFrontLayerCheckBox.enable  (fromEnableBinding: !front, nil)
      self.mBackLayerCheckBox.enable   (fromEnableBinding: !back, nil)
      self.mInner1LayerCheckBox.enable (fromEnableBinding: !inner1, nil)
      self.mInner2LayerCheckBox.enable (fromEnableBinding: !inner2, nil)
      self.mInner3LayerCheckBox.enable (fromEnableBinding: !inner3, nil)
      self.mInner4LayerCheckBox.enable (fromEnableBinding: !inner4, nil)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
