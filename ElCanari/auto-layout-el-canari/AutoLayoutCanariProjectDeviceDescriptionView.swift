//
//  AutoLayoutCanariProjectDeviceDescriptionView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariProjectDeviceDescriptionView : AutoLayoutVerticalStackViewWithScrollBar {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Populate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTrigger = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func triggerPopulate () {
    if !self.mTrigger {
      self.mTrigger = true
      DispatchQueue.main.async {
        self.populate ()
        self.mTrigger = false
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func populate () {
    self.removeAllItems ()
  //--- Symbol Type names
    if self.mSymbolTypeNameArray.count > 0 {
      let vStack = AutoLayoutVerticalStackView ()
      let s = AutoLayoutStaticLabel (
        title: "Symbol Type Names",
        bold: true,
        size: .regular,
        alignment: .right
      )
      let hStack = AutoLayoutHorizontalStackView ().appendView (s).appendGutter ().appendFlexibleSpace ()
      _ = vStack.appendView (hStack)
      for name in self.mSymbolTypeNameArray {
        let s = AutoLayoutStaticLabel (
          title: name,
          bold: false,
          size: .regular,
          alignment: .right
        )
        let hStack = AutoLayoutHorizontalStackView ().appendView (s).appendGutter ().appendFlexibleSpace ()
        _ = vStack.appendView (hStack)
      }
      _ = self.appendView (vStack).appendSeparator ()
    }
  //--- Symbol Instance names
    if self.mSymbolInstanceNameArray.count > 0 {
      let vStack = AutoLayoutVerticalStackView ()
      do{
        let s1 = AutoLayoutStaticLabel (
          title: "Symbol Instance Name",
          bold: true,
          size: .regular,
          alignment: .right
        )
        let s2 = AutoLayoutStaticLabel (
          title: "Symbol Type Name",
          bold: true,
          size: .regular,
          alignment: .left
        )
        let hStack = AutoLayoutHorizontalStackView ()
          .appendView (s1).appendGutter ().appendView (s2).appendFlexibleSpace ()
        _ = vStack.appendView (hStack)
      }
      for symbolInstance in self.mSymbolInstanceNameArray {
        let s1 = AutoLayoutStaticLabel (
          title: symbolInstance.left,
          bold: false,
          size: .regular,
          alignment: .right
        )
         let s2 = AutoLayoutStaticLabel (
          title: symbolInstance.right,
          bold: false,
          size: .regular,
          alignment: .right
        )
        let hStack = AutoLayoutHorizontalStackView ()
          .appendView (s1).appendGutter ().appendView (s2).appendFlexibleSpace ()
        _ = vStack.appendView (hStack)
      }
      _ = self.appendView (vStack).appendSeparator ()
    }
  //--- Package names
    if self.mPackageNameArray.count > 0 {
      let vStack = AutoLayoutVerticalStackView ()
      let s = AutoLayoutStaticLabel (
        title: "Package Names",
        bold: true,
        size: .regular,
        alignment: .right
      )
      let hStack = AutoLayoutHorizontalStackView ().appendView (s).appendGutter ().appendFlexibleSpace ()
      _ = vStack.appendView (hStack)
      for name in self.mPackageNameArray {
        let s = AutoLayoutStaticLabel (
          title: name,
          bold: false,
          size: .regular,
          alignment: .right
        )
        let hStack = AutoLayoutHorizontalStackView ().appendView (s).appendGutter ().appendFlexibleSpace ()
        _ = vStack.appendView (hStack)
      }
      _ = self.appendView (vStack).appendSeparator ()
    }
  //--- Pad Assignments names
    if self.mPinPadAssignmentArray.count > 0 {
      let vStack = AutoLayoutVerticalStackView ()
      let s1 = AutoLayoutStaticLabel (
        title: "Pad",
        bold: true,
        size: .regular,
        alignment: .right
      )
      let s2 = AutoLayoutStaticLabel (
        title: "Symbol Type",
        bold: true,
        size: .regular,
        alignment: .center
      )
      let s3 = AutoLayoutStaticLabel (
        title: "Pin",
        bold: true,
        size: .regular,
        alignment: .left
      )
      let hStack = AutoLayoutHorizontalStackView ()
          .appendView (s1).appendGutter ()
          .appendView (s2).appendGutter ()
          .appendView (s3).appendFlexibleSpace ()
      _ = vStack.appendView (hStack)
      for assignment in self.mPinPadAssignmentArray {
        let s1 = AutoLayoutStaticLabel (
          title: assignment.left,
          bold: false,
          size: .regular,
          alignment: .right
        )
        let s2 = AutoLayoutStaticLabel (
          title: assignment.center,
          bold: false,
          size: .regular,
          alignment: .center
        )
        let s3 = AutoLayoutStaticLabel (
          title: assignment.right,
          bold: false,
          size: .regular,
          alignment: .left
        )
        let hStack = AutoLayoutHorizontalStackView ()
            .appendView (s1).appendGutter ()
            .appendView (s2).appendGutter ()
            .appendView (s3).appendFlexibleSpace ()
        _ = vStack.appendView (hStack)
      }
      _ = self.appendView (vStack).appendSeparator ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    $symbolInstanceNameArray binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSymbolInstanceNameArrayController : EBObservablePropertyController? = nil
  private var mSymbolInstanceNameArray = TwoStringArray ()

  final func bind_symbolInstanceNameArray (_ inModel : EBObservableProperty <TwoStringArray>) -> Self {
    self.mSymbolInstanceNameArrayController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateSymbolInstanceNameArray (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateSymbolInstanceNameArray (from inModel : EBObservableProperty <TwoStringArray>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mSymbolInstanceNameArray.removeAll ()
    case .single (let v) :
      self.mSymbolInstanceNameArray = v
    }
    self.triggerPopulate ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    $symbolTypeNameArray binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSymbolTypeNameArrayController : EBObservablePropertyController? = nil
  private var mSymbolTypeNameArray = [String] ()

  final func bind_symbolTypeNameArray (_ inModel : EBObservableProperty <StringArray>) -> Self {
    self.mSymbolTypeNameArrayController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateSymbolTypeNameArray (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateSymbolTypeNameArray (from inModel : EBObservableProperty <StringArray>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mSymbolTypeNameArray.removeAll ()
    case .single (let v) :
      self.mSymbolTypeNameArray = v
    }
    self.triggerPopulate ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    $packageNameArray binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mPackageNameArrayController : EBObservablePropertyController? = nil
  private var mPackageNameArray = [String] ()

  final func bind_packageNameArray (_ inModel : EBObservableProperty <StringArray>) -> Self {
    self.mPackageNameArrayController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updatePackageNameArray (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updatePackageNameArray (from inModel : EBObservableProperty <StringArray>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mPackageNameArray.removeAll ()
    case .single (let v) :
      self.mPackageNameArray = v
    }
    self.triggerPopulate ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    $packageNameArray binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mPinPadAssignmentArrayController : EBObservablePropertyController? = nil
  private var mPinPadAssignmentArray = ThreeStringArray ()

  final func bind_pinPadAssignmentArray (_ inModel : EBObservableProperty <ThreeStringArray>) -> Self {
    self.mPinPadAssignmentArrayController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updatePinPadAssignmentArray (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updatePinPadAssignmentArray (from inModel : EBObservableProperty <ThreeStringArray>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mPinPadAssignmentArray.removeAll ()
    case .single (let v) :
      self.mPinPadAssignmentArray = v
    }
    self.triggerPopulate ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

