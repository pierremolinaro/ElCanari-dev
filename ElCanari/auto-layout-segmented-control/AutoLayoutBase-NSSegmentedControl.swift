//
//  AutoLayoutBase-NSSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSSegmentedControl : NSSegmentedControl {

  //····················································································································

  init (equalWidth inEqualWidth : Bool, size inSize : EBControlSize) {
    super.init (frame: .zero)
    noteObjectAllocation (self)

    self.translatesAutoresizingMaskIntoConstraints = false
    self.segmentStyle = .rounded

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))

    if inEqualWidth {
      self.segmentDistribution = .fillEqually // #available (OSX 10.13, *)
    }
    self.setContentCompressionResistancePriority (.required, for: .vertical)
    self.setContentHuggingPriority (.required, for: .vertical)
    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentHuggingPriority (.defaultHigh, for: .horizontal)
  }

  //····················································································································

  required init? (coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
