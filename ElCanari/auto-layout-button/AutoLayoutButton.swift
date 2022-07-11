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
//  https://apple.stackexchange.com/questions/55727/where-can-i-find-the-unicode-symbols-for-mac-functional-keys-command-shift-e
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let ESCAPE_KEY_STRING  = "\u{238B}"
private let DELETE_KEY_STRING  = "\u{232B}"
private let COMMAND_KEY_STRING = "\u{2318}"
private let CONTROL_KEY_STRING = "\u{2303}"
private let OPTION_KEY_STRING  = "\u{2325}"
private let SHIFT_KEY_STRING   = "\u{21E7}"

private let RIGHT_ARROW_STRING = "\u{2192}"
private let LEFT_ARROW_STRING  = "\u{2191}"
private let UP_ARROW_STRING    = "\u{2192}"
private let DOWN_ARROW_STRING  = "\u{2193}"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutButton : AutoLayoutBase_NSButton {

  //····················································································································

//  override init (title inTitle : String, size inSize : EBControlSize) {
//    super.init (title: inTitle, size: inSize)
//  }

  //····················································································································

//  required init? (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }

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

  func setTitleAsDownArrow () -> Self {
    self.title = DOWN_ARROW_STRING
    return self
  }

  //····················································································································

  func setTitleAsUpArrow () -> Self {
    self.title = UP_ARROW_STRING
    return self
  }

  //····················································································································

  func setTitleAsRightArrow () -> Self {
    self.title = RIGHT_ARROW_STRING
    return self
  }

  //····················································································································

  func setTitleAsLeftArrow () -> Self {
    self.title = LEFT_ARROW_STRING
    return self
  }

  //····················································································································

  final func setEscapeKeyAsKeyEquivalent () -> Self {
    self.keyEquivalent = "\u{1b}"
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = ESCAPE_KEY_STRING
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

  final func setDeleteKeyAsKeyEquivalent () -> Self {
    self.keyEquivalent = "\u{7F}"
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = DELETE_KEY_STRING
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

  final func set (commandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = .command
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = COMMAND_KEY_STRING + " \(me.keyEquivalent.uppercased ())"
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

  final func set (shiftCommandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = [.command, .shift]
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = SHIFT_KEY_STRING + " " + COMMAND_KEY_STRING + " \(me.keyEquivalent.uppercased ())"
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

  final func set (optionCommandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = [.command, .option]
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = OPTION_KEY_STRING + " " + COMMAND_KEY_STRING + " \(me.keyEquivalent.uppercased ())"
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

  final func set (controlCommandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = [.command, .control]
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = CONTROL_KEY_STRING + " " + COMMAND_KEY_STRING + " \(me.keyEquivalent.uppercased ())"
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
