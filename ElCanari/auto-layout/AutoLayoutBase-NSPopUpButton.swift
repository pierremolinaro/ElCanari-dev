//
//  AutoLayoutBase-NSPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (pullsDown inPullsDown : Bool, size inSize : EBControlSize) {
    super.init (frame: NSRect (), pullsDown: inPullsDown)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.autoenablesItems = false
    if let cell = self.cell as? NSPopUpButtonCell {
      cell.arrowPosition = .arrowAtBottom
    }

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override final func updateAutoLayoutUserInterfaceStyle () {
    super.updateAutoLayoutUserInterfaceStyle ()
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
  }

  //····················································································································
  //  $enabled binding
  //····················································································································

  private var mEnabledBindingController : EnabledBindingController? = nil
  var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //····················································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //····················································································································
  //  $hidden binding
  //····················································································································

  private var mHiddenBindingController : HiddenBindingController? = nil
  var hiddenBindingController : HiddenBindingController? { return self.mHiddenBindingController }

  //····················································································································

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
