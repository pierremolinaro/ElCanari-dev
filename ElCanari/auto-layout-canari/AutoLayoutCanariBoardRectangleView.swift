//
//  AutoLayoutCanariBoardRectangleView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariBoardRectangleView : AutoLayoutBase_NSView {

  //····················································································································

  private let mTopTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mBottomTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mLeftTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mRightTextField = AutoLayoutLabel (bold: false, size: .small)
  private let mUnitPopUpButton = AutoLayoutCanariUnitPopUpButton (size: .small)

  //····················································································································

  override init () {
    super.init ()

    self.setContentHuggingPriority (.init(rawValue: 1.0), for: .horizontal)

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
    var c = NSLayoutConstraint (item: self, attribute: .left, relatedBy: .equal, toItem: self.mLeftTextField, attribute: .left, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .centerY, relatedBy: .equal, toItem: self.mLeftTextField, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
  //--- Right
    c = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: self.mRightTextField, attribute: .right, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .centerY, relatedBy: .equal, toItem: self.mRightTextField, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
  //--- Top
    c = NSLayoutConstraint (item: self, attribute: .top, relatedBy: .equal, toItem: self.mTopTextField, attribute: .top, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .centerX, relatedBy: .equal, toItem: self.mTopTextField, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
  //--- Bottom
    c = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: self.mBottomTextField, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .centerX, relatedBy: .equal, toItem: self.mBottomTextField, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
  //--- Unit pop up
    c = NSLayoutConstraint (item: self, attribute: .centerY, relatedBy: .equal, toItem: self.mUnitPopUpButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .centerX, relatedBy: .equal, toItem: self.mUnitPopUpButton, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
  //---
    self.addConstraints (constraints)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    s.height = 64.0
    return s
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    let w = self.mTopTextField.frame.height / 2.0
    let r = self.bounds.insetBy (dx: w, dy: w)
    NSColor.black.setStroke ()
    let bp = NSBezierPath (rect: r)
    bp.lineWidth = 0.0
    bp.stroke ()
  }

  //····················································································································
  //  $top binding
  //····················································································································

  private var mTopController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_top (_ inModel : EBReadOnlyProperty_String) -> Self {
    self.mTopController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateTop (from: inModel) }
    )
    return self
  }

  //····················································································································

  private func updateTop (from inModel : EBReadOnlyProperty_String) {
    switch inModel.selection {
    case .empty :
      self.mTopTextField.stringValue = "—"
    case .single (let v) :
      self.mTopTextField.stringValue = v
    case .multiple :
      self.mTopTextField.stringValue = "—"
    }
  }

  //····················································································································
  //  $bottom binding
  //····················································································································

  private var mBottomController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_bottom (_ inModel : EBReadOnlyProperty_String) -> Self {
    self.mBottomController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateBottom (from: inModel) }
    )
    return self
  }

  //····················································································································

  private func updateBottom (from inModel : EBReadOnlyProperty_String) {
    switch inModel.selection {
    case .empty :
      self.mBottomTextField.stringValue = "—"
    case .single (let v) :
      self.mBottomTextField.stringValue = v
    case .multiple :
      self.mBottomTextField.stringValue = "—"
    }
  }

  //····················································································································
  //  $left binding
  //····················································································································

  private var mLeftController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_left (_ inModel : EBReadOnlyProperty_String) -> Self {
    self.mLeftController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateLeft (from: inModel) }
    )
    return self
  }

  //····················································································································

  private func updateLeft (from inModel : EBReadOnlyProperty_String) {
    switch inModel.selection {
    case .empty :
      self.mLeftTextField.stringValue = "—"
    case .single (let v) :
      self.mLeftTextField.stringValue = v
    case .multiple :
      self.mLeftTextField.stringValue = "—"
    }
  }

  //····················································································································
  //  $right binding
  //····················································································································

  private var mRightController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_right (_ inModel : EBReadOnlyProperty_String) -> Self {
    self.mRightController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateRight (from: inModel) }
    )
    return self
  }

  //····················································································································

  private func updateRight (from inModel : EBReadOnlyProperty_String) {
    switch inModel.selection {
    case .empty :
      self.mRightTextField.stringValue = "—"
    case .single (let v) :
      self.mRightTextField.stringValue = v
    case .multiple :
      self.mRightTextField.stringValue = "—"
    }
  }

  //····················································································································
  //  $unit binding
  //····················································································································

  final func bind_unit (_ inModel : EBReadWriteProperty_Int) -> Self {
    _ = self.mUnitPopUpButton.bind_unit (inModel)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
