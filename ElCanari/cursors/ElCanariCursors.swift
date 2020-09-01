//
//  ElCanariCursors.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/08/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

func upDownRightLeftCursor () -> NSCursor {
  let cursor = NSCursor (
    image: NSImage (imageLiteralResourceName: "upDownRightLeftCursor"),
    hotSpot: NSPoint (x: 8.0, y: 8.0)
  )
  return cursor
}

//----------------------------------------------------------------------------------------------------------------------

func rotationCursor () -> NSCursor {
  let cursor = NSCursor (
    image: NSImage (imageLiteralResourceName: "rotationCursor"),
    hotSpot: NSPoint (x: 8.0, y: 8.0)
  )
  return cursor
}

//----------------------------------------------------------------------------------------------------------------------
