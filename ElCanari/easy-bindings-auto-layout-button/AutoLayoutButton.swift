//
//  AutoLayoutButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//  https://apple.stackexchange.com/questions/55727/where-can-i-find-the-unicode-symbols-for-mac-functional-keys-command-shift-e
//HTML Entity     GLYPH  NAME
//   &#63743;              Apple
//   &#8984;         ⌘      Command, Cmd, Clover, (formerly) Apple
//   &#8963;         ⌃      Control, Ctl, Ctrl
//   &#8997;         ⌥      Option, Opt, (Windows) Alt
//   &#8679;         ⇧      Shift
//   &#8682;         ⇪      Caps lock
//   &#9167;         ⏏      Eject
//   &#8617;         ↩      Return, Carriage Return
//   &#8629; &crarr; ↵      Return, Carriage Return
//   &#9166;         ⏎      Return, Carriage Return
//   &#8996;         ⌤      Enter
//   &#9003;         ⌫      Delete, Backspace
//   &#8998;         ⌦      Forward Delete
//   &#9099;         ⎋      Escape, Esc
//   &#8594; &rarr;  →      Right arrow
//   &#8592; &larr;  ←      Left arrow
//   &#8593; &uarr;  ↑      Up arrow
//   &#8595; &darr;  ↓      Down arrow
//   &#8670;         ⇞      Page Up, PgUp
//   &#8671;         ⇟      Page Down, PgDn
//   &#8598;         ↖      Home
//   &#8600;         ↘      End
//   &#8999;         ⌧      Clear
//   &#8677;         ⇥      Tab, Tab Right, Horizontal Tab
//   &#8676;         ⇤      Shift Tab, Tab Left, Back-tab
//   &#9250;         ␢      Space, Blank
//   &#9251;         ␣      Space, Blank
//-------------- HEXADECIMAL
//⌘,&#x2318;,,command
//⇧,&#x21e7;,,shift
//⌥,&#x2325;,,option
//⌃,&#x2303;,,control
//↩,&#x21a9;,&hookleftarrow;,return
//⌤,&#x2324;,,enter
//⌫,&#x232b;,,delete
//⌦,&#x2326;,,forward delete
//⌧,&#x2327;,,clear
//⇥,&#x21e5;,&rarrb;,tab
//⇤,&#x21e4;,&larrb;,backtab
//␣,&#x2423;,&blank;,space
//⎋,&#x238b;,,escape
//⇪,&#x21ea;,,caps lock
//⏏,&#x23cf;,,eject
//⇞,&#x21de;,,page up
//⇟,&#x21df;,,page down
//↖,&#x2196;,&UpperLeftArrow;,home
//↘,&#x2198;,&LowerRightArrow;,end
//←,&#x2190;,&larr;,left
//→,&#x2192;,&rarr;,right
//↑,&#x2191;,&uarr;,up
//↓,&#x2193;,&darr;,down
//--------------------------------------------------------------------------------------------------

//let ESCAPE_KEY_STRING  = "\u{238B}"
let DELETE_KEY_STRING  = "\u{232B}"
let COMMAND_KEY_STRING = "\u{2318}"
let CONTROL_KEY_STRING = "\u{2303}"
//let OPTION_KEY_STRING  = "\u{2325}"
let SHIFT_KEY_STRING   = "\u{21E7}"

let LEFT_ARROW_STRING  = "\u{2190}"
let UP_ARROW_STRING    = "\u{2191}"
let RIGHT_ARROW_STRING = "\u{2192}"
let DOWN_ARROW_STRING  = "\u{2193}"

//--------------------------------------------------------------------------------------------------

final class AutoLayoutButton : ALB_NSButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mWidth : CGFloat? = nil
  private var mTemporaryWidthOnControlKey : CGFloat? = nil
  private var mHeight : CGFloat? = nil
  private var mSavedTitle = ""
  private var mEventMonitor : Any? = nil // For tracking option key change

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (width inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func set (height inHeight : Int) -> Self {
//    self.mHeight = CGFloat (inHeight)
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setTitleAsDownArrow () -> Self {
    self.title = DOWN_ARROW_STRING
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setTitleAsUpArrow () -> Self {
    self.title = UP_ARROW_STRING
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setTitleAsRightArrow () -> Self {
    self.title = RIGHT_ARROW_STRING
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setTitleAsLeftArrow () -> Self {
    self.title = LEFT_ARROW_STRING
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func setEscapeKeyAsKeyEquivalent () -> Self {
//    self.keyEquivalent = "\u{1b}"
//    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
//      if let me = self {
//        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
//        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
//          me.mSavedTitle = me.title
//          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
//          me.title = ESCAPE_KEY_STRING
//        }else if !modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey != nil {
//          me.title = me.mSavedTitle
//          me.mTemporaryWidthOnControlKey = nil
//        }
//      }
//      return inEvent
//    }
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (commandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = .command
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = COMMAND_KEY_STRING + " " + me.keyEquivalent.uppercased ()
        }else if !modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey != nil {
          me.title = me.mSavedTitle
          me.mTemporaryWidthOnControlKey = nil
        }
      }
      return inEvent
    }
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (shiftCommandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = [.command, .shift]
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = SHIFT_KEY_STRING + " " + COMMAND_KEY_STRING + " " + me.keyEquivalent.uppercased ()
        }else if !modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey != nil {
          me.title = me.mSavedTitle
          me.mTemporaryWidthOnControlKey = nil
        }
      }
      return inEvent
    }
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func set (optionCommandKeyEquivalent inKeyEquivalent : String) -> Self {
//    self.keyEquivalent = inKeyEquivalent
//    self.keyEquivalentModifierMask = [.command, .option]
//    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
//      if let me = self {
//        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
//        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
//          me.mSavedTitle = me.title
//          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
//          me.title = OPTION_KEY_STRING + " " + COMMAND_KEY_STRING + " " + me.keyEquivalent.uppercased ()
//        }else if !modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey != nil {
//          me.title = me.mSavedTitle
//          me.mTemporaryWidthOnControlKey = nil
//        }
//      }
//      return inEvent
//    }
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (controlCommandKeyEquivalent inKeyEquivalent : String) -> Self {
    self.keyEquivalent = inKeyEquivalent
    self.keyEquivalentModifierMask = [.command, .control]
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { [weak self] inEvent in
      if let me = self {
        let modifierFlagsContainsCommand = inEvent.modifierFlags.contains (.command)
        if modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey == nil {
          me.mSavedTitle = me.title
          me.mTemporaryWidthOnControlKey = me.alignmentRect (forFrame: me.frame).width
          me.title = CONTROL_KEY_STRING + " " + COMMAND_KEY_STRING + " " + me.keyEquivalent.uppercased ()
        }else if !modifierFlagsContainsCommand, me.mTemporaryWidthOnControlKey != nil {
          me.title = me.mSavedTitle
          me.mTemporaryWidthOnControlKey = nil
        }
      }
      return inEvent
    }
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
