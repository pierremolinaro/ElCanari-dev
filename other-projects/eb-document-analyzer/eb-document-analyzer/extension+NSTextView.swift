//
//  extension+NSTextView.swift
//  eb-document-analyzer
//
//  Created by Pierre Molinaro on 08/07/2015.
//  Copyright © 2015 Pierre Molinaro. All rights reserved.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    NSTExtView extension
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSTextView {

  //····················································································································

  func displayAndScrollToEndOfText () {
    if let unwrappedLayoutManager = layoutManager {
      if let ts = unwrappedLayoutManager.textStorage {
        let endOfText = NSRange (location:ts.length, length:0)
        scrollRangeToVisible (endOfText)
        displayIfNeeded ()
      }
    }
  }

  //····················································································································

  func clear () {
    let str = NSAttributedString (string:"", attributes:nil)
    if let unwrappedLayoutManager = layoutManager {
      if let ts = unwrappedLayoutManager.textStorage {
        ts.setAttributedString (str)
      }
    }
  }

  //····················································································································

  func appendAttributedString (_ inAttributedString : NSAttributedString) {
    if let unwrappedLayoutManager = layoutManager {
      if let ts = unwrappedLayoutManager.textStorage {
        ts.append (inAttributedString)
        displayAndScrollToEndOfText ()
      }
    }
  }

  //····················································································································

  func appendMessageString (_ inString : String) {
    let attributes : [String : NSObject] = [
      NSFontAttributeName : NSFont.systemFont (ofSize: NSFont.systemFontSize ()),
      NSForegroundColorAttributeName : NSColor.black
    ]
    let str = NSAttributedString (string:inString, attributes:attributes)
    if let unwrappedLayoutManager = layoutManager {
      if let ts = unwrappedLayoutManager.textStorage {
        ts.append (str)
        displayAndScrollToEndOfText ()
      }
    }
  }

  //····················································································································

  func appendMessageString (_ inString : String, color:NSColor) {
    let attributes : [String : NSObject] = [
      NSFontAttributeName : NSFont.systemFont (ofSize: NSFont.systemFontSize ()),
      NSForegroundColorAttributeName : color
    ]
    let str = NSAttributedString (string:inString, attributes:attributes)
    if let unwrappedLayoutManager = layoutManager {
      if let ts = unwrappedLayoutManager.textStorage {
        ts.append (str)
        displayAndScrollToEndOfText ()
      }
    }
  }

  //····················································································································

  func appendErrorString (_ inString : String) {
    appendMessageString (inString, color:NSColor.red)
  }
  
  //····················································································································

  func appendWarningString (_ inString : String) {
    appendMessageString (inString, color:NSColor.orange)
  }

  //····················································································································

  func appendSuccessString (_ inString : String) {
    appendMessageString (inString, color:NSColor.blue)
  }
  
  //····················································································································

  func appendByte (_ byte : UInt8) {
    appendMessageString (String (format:" %02X", byte))
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
