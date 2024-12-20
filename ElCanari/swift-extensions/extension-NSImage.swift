//
//  NSImage-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/09/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSImage {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var statusSuccess : NSImage {
    return NSImage (named: NSImage.statusAvailableName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var statusWarning : NSImage {
    return NSImage (named: NSImage.statusPartiallyAvailableName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var statusNone : NSImage {
    return NSImage (named: NSImage.statusNoneName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var statusError : NSImage {
    return NSImage (named: NSImage.statusUnavailableName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
