//
//  AutoLayoutCanariBoardRectangleView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor final class AutoLayoutCanariBoardRectangleView : ALB_NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mTopTextField : AutoLayoutLabel
  private let mBottomTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mLeftTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mRightTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mUnitPopUpButton = AutoLayoutCanariUnitPopUpButton (size: .small)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor override init () {
    self.mTopTextField = AutoLayoutLabel (bold: false, size: .small)
    super.init ()

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)

    self.mTopTextField.backgroundColor = NSColor.textBackgroundColor
    self.mTopTextField.drawsBackground = true
    self.mBottomTextField.backgroundColor = NSColor.textBackgroundColor
    self.mBottomTextField.drawsBackground = true
    self.mLeftTextField.backgroundColor = NSColor.textBackgroundColor
    self.mLeftTextField.drawsBackground = true
    self.mRightTextField.backgroundColor = NSColor.textBackgroundColor
    self.mRightTextField.drawsBackground = true

    self.addSubview (self.mTopTextField)
    self.addSubview (self.mBottomTextField)
    self.addSubview (self.mLeftTextField)
    self.addSubview (self.mRightTextField)
    self.addSubview (self.mUnitPopUpButton)

    var constraints = [NSLayoutConstraint] ()
  //--- Left
    constraints.add (x: self.leftAnchor, equalTo: self.mLeftTextField.leftAnchor)
    constraints.add (y: self.centerYAnchor, equalTo: self.mLeftTextField.centerYAnchor)
  //--- Right
    constraints.add (x: self.rightAnchor, equalTo: self.mRightTextField.rightAnchor)
    constraints.add (y: self.centerYAnchor, equalTo: self.mRightTextField.centerYAnchor)
  //--- Top
    constraints.add (y: self.topAnchor, equalTo: self.mTopTextField.topAnchor)
    constraints.add (x: self.centerXAnchor, equalTo: self.mTopTextField.centerXAnchor)
  //--- Bottom
    constraints.add (y: self.bottomAnchor, equalTo: self.mBottomTextField.bottomAnchor)
    constraints.add (x: self.centerXAnchor, equalTo: self.mBottomTextField.centerXAnchor)
  //--- Unit pop up
    constraints.add (y: self.centerYAnchor, equalTo: self.mUnitPopUpButton.centerYAnchor)
    constraints.add (x: self.centerXAnchor, equalTo: self.mUnitPopUpButton.centerXAnchor)
  //---
    self.addConstraints (constraints)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    s.height = 64.0
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect : NSRect) {
    let w = self.mTopTextField.frame.height / 2.0
    let r = self.bounds.insetBy (dx: w, dy: w)
    NSColor.black.setStroke ()
    let bp = NSBezierPath (rect: r)
    bp.lineWidth = 0.0
    bp.stroke ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $top binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTopController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_top (_ inModel : EBObservableProperty <String>) -> Self {
    self.mTopController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateTop (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateTop (from inModel : EBObservableProperty <String>) {
    switch inModel.selection {
    case .empty :
      self.mTopTextField.stringValue = "—"
    case .single (let v) :
      self.mTopTextField.stringValue = v
    case .multiple :
      self.mTopTextField.stringValue = "—"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $bottom binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mBottomController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_bottom (_ inModel : EBObservableProperty <String>) -> Self {
    self.mBottomController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateBottom (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateBottom (from inModel : EBObservableProperty <String>) {
    switch inModel.selection {
    case .empty :
      self.mBottomTextField.stringValue = "—"
    case .single (let v) :
      self.mBottomTextField.stringValue = v
    case .multiple :
      self.mBottomTextField.stringValue = "—"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $left binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mLeftController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_left (_ inModel : EBObservableProperty <String>) -> Self {
    self.mLeftController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateLeft (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateLeft (from inModel : EBObservableProperty <String>) {
    switch inModel.selection {
    case .empty :
      self.mLeftTextField.stringValue = "—"
    case .single (let v) :
      self.mLeftTextField.stringValue = v
    case .multiple :
      self.mLeftTextField.stringValue = "—"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $right binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mRightController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_right (_ inModel : EBObservableProperty <String>) -> Self {
    self.mRightController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateRight (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateRight (from inModel : EBObservableProperty <String>) {
    switch inModel.selection {
    case .empty :
      self.mRightTextField.stringValue = "—"
    case .single (let v) :
      self.mRightTextField.stringValue = v
    case .multiple :
      self.mRightTextField.stringValue = "—"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $unit binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_unit (_ inModel : EBObservableMutableProperty <Int>) -> Self {
    _ = self.mUnitPopUpButton.bind_unit (inModel)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
