//
//  Preferences_SuperClass.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Preferences_SuperClass : EBObjcBaseObject {

  //····················································································································

  var mLibraryUpdateLogWindow : EBWindow? = nil
  var mLibraryUpdateLogTextView : AutoLayoutStaticTextView? = nil

  //····················································································································

  var mLibraryConsistencyLogWindow : EBWindow? = nil
  var mLibraryConsistencyLogTextView : AutoLayoutStaticTextView? = nil

  //····················································································································

  final func setUpLibraryUpdateLogWindow () -> EBWindow {
    if let window = self.mLibraryUpdateLogWindow {
      return window
    }else{
      let window = EBWindow (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 400),
        styleMask: [.closable, .resizable, .titled],
        backing: .buffered,
        defer: false
      )
      self.mLibraryUpdateLogWindow = window
      window.setFrameAutosaveName ("LibraryUpdateLogWindowSettings")
      window.title = "Library Update Log"
      window.isReleasedWhenClosed = false
      let textView = AutoLayoutStaticTextView (string: "")
        .expandableWidth ()
        .expandableHeight ()
        .setScroller (horizontal: true, vertical: true)

      self.mLibraryUpdateLogTextView = textView
      window.contentView = textView
//      window.contentView = AutoLayoutWindowContentView (view: textView)
      return window
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
