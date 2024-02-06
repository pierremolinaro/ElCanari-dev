//
//  AutoLayoutCanariRestrictRectangleView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 15/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariRestrictRectangleView : AutoLayoutVerticalStackView {

  //····················································································································

  private let mFrontLayerCheckBox = AutoLayoutCheckbox (title: "Front Layer", size: .small)
  private let mBackLayerCheckBox = AutoLayoutCheckbox (title: "Back Layer", size: .small)
  private let mInner1LayerCheckBox = AutoLayoutCheckbox (title: "Inner1 Layer", size: .small)
  private let mInner2LayerCheckBox = AutoLayoutCheckbox (title: "Inner2 Layer", size: .small)
  private let mInner3LayerCheckBox = AutoLayoutCheckbox (title: "Inner3 Layer", size: .small)
  private let mInner4LayerCheckBox = AutoLayoutCheckbox (title: "Inner4 Layer", size: .small)
  private var mModelObserver : EBObservablePropertyController? = nil

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override init () {
    super.init ()
    _ = self.appendView (self.mFrontLayerCheckBox)
    _ = self.appendView (self.mBackLayerCheckBox)
    _ = self.appendView (self.mInner1LayerCheckBox)
    _ = self.appendView (self.mInner2LayerCheckBox)
    _ = self.appendView (self.mInner3LayerCheckBox)
    _ = self.appendView (self.mInner4LayerCheckBox)
  }

  //····················································································································

  func bind_frontBackInner1Inner2Inner3Inner4 (_ inFrontModel : EBObservableMutableProperty <Bool>,
                                               _ inBackModel : EBObservableMutableProperty <Bool>,
                                               _ inInner1Model : EBObservableMutableProperty <Bool>,
                                               _ inInner2Model : EBObservableMutableProperty <Bool>,
                                               _ inInner3Model : EBObservableMutableProperty <Bool>,
                                               _ inInner4Model : EBObservableMutableProperty <Bool>) -> Self {
    self.mModelObserver = EBObservablePropertyController (
      observedObjects: [inFrontModel, inBackModel, inInner1Model, inInner2Model, inInner3Model, inInner4Model],
      callBack: { [weak self] in self?.deferredUpdateCheckboxes (nil) }
    )

    _ = self.mFrontLayerCheckBox.bind_value (inFrontModel)
      .bind_run (target: self, selector: #selector (Self.deferredUpdateCheckboxes (_:)))

    _ = self.mBackLayerCheckBox.bind_value (inBackModel)
      .bind_run (target: self, selector: #selector (Self.deferredUpdateCheckboxes (_:)))

    _ = self.mInner1LayerCheckBox.bind_value (inInner1Model)
      .bind_run (target: self, selector: #selector (Self.deferredUpdateCheckboxes (_:)))

    _ = self.mInner2LayerCheckBox.bind_value (inInner2Model)
      .bind_run (target: self, selector: #selector (Self.deferredUpdateCheckboxes (_:)))

    _ = self.mInner3LayerCheckBox.bind_value (inInner3Model)
      .bind_run (target: self, selector: #selector (Self.deferredUpdateCheckboxes (_:)))

    _ = self.mInner4LayerCheckBox.bind_value (inInner4Model)
      .bind_run (target: self, selector: #selector (Self.deferredUpdateCheckboxes (_:)))

    return self
  }

  //····················································································································

  private var mRegistered = false

  @objc private func deferredUpdateCheckboxes (_ _ : Any?) {
    if !self.mRegistered {
      self.mRegistered = true
      DispatchQueue.main.async { self.updateCheckboxes () }
    }
  }

  //····················································································································

  private func updateCheckboxes () {
    self.mRegistered = false
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

//——————————————————————————————————————————————————————————————————————————————————————————————————
