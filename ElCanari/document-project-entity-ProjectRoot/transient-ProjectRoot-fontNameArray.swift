//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_fontNameArray (
       _ self_mFonts_mFontName : [any FontInProject_mFontName]
) -> StringArray {
//--- START OF USER ZONE 2
        var result = StringArray ()
        for object in self_mFonts_mFontName {
          result.append (object.mFontName)
        }
        return result
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
