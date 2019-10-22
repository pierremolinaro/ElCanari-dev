//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_ProjectRoot_signatureForERCChecking (
       _ self_mBoardObjects_signatureForERCChecking : [BoardObject_signatureForERCChecking],
       _ self_mArtwork_signatureForERCChecking : UInt32?
) -> UInt32 {
//--- START OF USER ZONE 2
       var crc : UInt32 = 0
       for object in self_mBoardObjects_signatureForERCChecking {
         if let signature = object.signatureForERCChecking {
           crc.accumulateUInt32 (signature)
         }
       }
       if let s = self_mArtwork_signatureForERCChecking {
        crc.accumulateUInt32 (s)
       }
       return crc
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————