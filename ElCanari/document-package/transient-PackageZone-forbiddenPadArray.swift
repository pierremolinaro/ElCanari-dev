//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PackageZone_forbiddenPadArray (
       _ self_forbiddenPadNumbers_padNumber : [any ForbiddenPadNumber_padNumber]
) -> StringArray {
//--- START OF USER ZONE 2
    var padNumberSet = Set <Int> ()
    for f in self_forbiddenPadNumbers_padNumber {
      padNumberSet.insert (f.padNumber)
    }
    let padNumberArray = Array (padNumberSet).sorted ()
    var stringArray = [String] ()
    for n in padNumberArray {
      stringArray.append ("\(n)")
    }
    return stringArray
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
