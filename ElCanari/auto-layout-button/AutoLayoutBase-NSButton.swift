//
//  AutoLayoutBase-NSButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSButton : NSButton {

  //····················································································································

  final private var mClosureAction : Optional < () -> Void > = nil

  //····················································································································

  init (title inTitle : String, size inSize : EBControlSize) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.title = inTitle
    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.bezelStyle = .rounded

    self.lineBreakMode = .byTruncatingTail

    self.setContentCompressionResistancePriority (.required, for: .vertical)
    self.setContentHuggingPriority (.required, for: .vertical)
    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentHuggingPriority (.defaultHigh, for: .horizontal)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  Closure action
  //····················································································································

  final func setClosureAction (_ inClosureAction : @escaping () -> Void) {
    self.mClosureAction = inClosureAction
    self.target = self
    self.action = #selector (Self.runClosureAction (_:))
  }

  //····················································································································

   @objc private final func runClosureAction (_ _ : Any?) {
     self.mClosureAction? ()
  }

  //····················································································································
  //  $enabled binding
  //····················································································································

  private final var mEnabledBindingController : EnabledBindingController? = nil
  final var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //····················································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //····················································································································
  //  $hidden binding
  //····················································································································

  private final var mHiddenBindingController : HiddenBindingController? = nil

  //····················································································································

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
