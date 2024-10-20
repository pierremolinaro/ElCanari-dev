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

  public static var statusSuccess : NSImage {
    return NSImage (named: NSImage.statusAvailableName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  public static var statusWarning : NSImage {
    return NSImage (named: NSImage.statusPartiallyAvailableName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  public static var statusNone : NSImage {
    return NSImage (named: NSImage.statusNoneName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  public static var statusError : NSImage {
    return NSImage (named: NSImage.statusUnavailableName)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
