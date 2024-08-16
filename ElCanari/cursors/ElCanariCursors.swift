//
//  ElCanariCursors.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/08/2020.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EXTENSION NSCursor
//--------------------------------------------------------------------------------------------------

extension NSCursor {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var upDownRightLeftCursor : NSCursor {
    let cursor = NSCursor (
      image: NSImage (imageLiteralResourceName: "upDownRightLeftCursor"),
      hotSpot: NSPoint ()
    )
    return cursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var rotationCursor : NSCursor {
    let cursor = NSCursor (
      image: NSImage (imageLiteralResourceName: "rotationCursor"),
      hotSpot: NSPoint ()
    )
    return cursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
