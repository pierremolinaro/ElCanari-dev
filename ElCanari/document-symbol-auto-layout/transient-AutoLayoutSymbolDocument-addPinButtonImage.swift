//----------------------------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//----------------------------------------------------------------------------------------------------------------------

func transient_AutoLayoutSymbolDocument_addPinButtonImage (
       _ prefs_symbolColor : NSColor
) -> NSImage {
//--- START OF USER ZONE 2
        let temporaryObject = SymbolPin (nil)
        temporaryObject.xName = 2_286_00 / 2
        temporaryObject.yName = 0
        temporaryObject.yNumber = -2_286_00 / 2
        if let displayShape = temporaryObject.objectDisplay {
          let r = displayShape.boundingBox
          if !r.isEmpty {
            return buildPDFimage (frame: r.insetBy(dx: -2.0, dy: -2.0), shape: displayShape)
          }else{
            return NSImage (named: NSImage.statusPartiallyAvailableName)!
          }
        }else{
          return NSImage (named: NSImage.statusPartiallyAvailableName)!
        }//--- END OF USER ZONE 2
}

//----------------------------------------------------------------------------------------------------------------------