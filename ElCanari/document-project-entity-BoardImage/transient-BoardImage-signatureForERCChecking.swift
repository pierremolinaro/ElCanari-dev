//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func transient_BoardImage_signatureForERCChecking (
       _ self_mLayer : BoardQRCodeLayer,                      
       _ self_mCenterX : Int,                                 
       _ self_mCenterY : Int,                                 
       _ self_mImageData : Data,                              
       _ self_mRotation : Int
) -> UInt32 {
//--- START OF USER ZONE 2
        var crc : UInt32 = 0
        crc.accumulate (u32: self_mCenterX.ebHashValue ())
        crc.accumulate (u32: self_mCenterY.ebHashValue ())
        crc.accumulate (u32: self_mRotation.ebHashValue ())
        crc.accumulate (u32: self_mImageData.ebHashValue ())
        return crc
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————