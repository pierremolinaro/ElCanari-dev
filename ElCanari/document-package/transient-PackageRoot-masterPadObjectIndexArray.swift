//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PackageRoot_masterPadObjectIndexArray (
       _ self_packagePads_masterPadObjectIndex : [any PackagePad_masterPadObjectIndex]
) -> IntArray {
//--- START OF USER ZONE 2
        var result = IntArray ()
        for object in self_packagePads_masterPadObjectIndex {
          if let idx = object.masterPadObjectIndex {
            result.append (idx)
          }
        }
        return result
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
