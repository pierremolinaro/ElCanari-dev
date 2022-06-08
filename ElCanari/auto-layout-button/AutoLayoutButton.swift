//
//  AutoLayoutButton.swift
//  ElCanari
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
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  private var mWidth : CGFloat? = nil
  private var mTemporaryWidthOnControlKey : CGFloat? = nil
  private var mHeight : CGFloat? = nil
  private var mSavedTitle = ""
  private var mEventMonitor : Any? = nil // For tracking option key change

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

  final func setEscapeKeyAsKeyEquivalent () -> Self {
    self.keyEquivalent = "\u{1b}"
    return self
  }

  //····················································································································

  final func setDeleteKeyAsKeyEquivalent () -> Self {
    self.keyEquivalent = "\u{7F}"
    return self
  }

  //····················································································································

  final func set (commandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = .command
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = "⌘\(me.keyEquivalent.uppercased ())"
        }else if !modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey != nil {
          me.title = me.mSavedTitle
          me.mTemporaryWidthOnControlKey = nil
        }
      }
      return inEvent
    }
    return self
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    if let w = self.mTemporaryWidthOnControlKey {
      s.width = w
    }
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
