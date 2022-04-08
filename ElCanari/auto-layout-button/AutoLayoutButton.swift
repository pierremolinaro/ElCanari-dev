//
//  AutoLayoutButton.swift
//  essai-custom-stack-view
//
//  Created by Pierre Molinaro on 19/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutButton : AutoLayoutBase_NSButton {

  //····················································································································

  override init (title inTitle : String, size inSize : EBControlSize) {
    super.init (title: inTitle, size: inSize)

//    self.setContentCompressionResistancePriority (.required, for: .horizontal)
//    self.setContentCompressionResistancePriority (.required, for: .vertical)
//    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
//    self.setContentHuggingPriority (.defaultLow, for: .vertical)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  private var mWidth : CGFloat? = nil
  private var mHeight : CGFloat? = nil

  //····················································································································

  final func set (width inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
    return self
  }

  //····················································································································

  final func set (height inHeight : Int) -> Self {
    self.mHeight = CGFloat (inHeight)
    return self
  }

  //····················································································································

  final func set (commandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = .command
    self.title += " [⌘\(inKeyEquivalent.uppercased ())]"
    return self
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    if let w = self.mWidth {
      s.width = w
    }
    if let h = self.mHeight {
      s.height = h
    }
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
