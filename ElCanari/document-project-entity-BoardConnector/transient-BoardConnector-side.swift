//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_BoardConnector_side (
       _ self_mComponent_componentPadDictionary : ComponentPadDescriptorDictionary?,
       _ self_mComponentPadName : String,      
       _ self_mPadIndex : Int,                 
       _ self_mTracksP1_mSide : [any BoardTrack_mSide],
       _ self_mTracksP2_mSide : [any BoardTrack_mSide]
) -> ConnectorSide {
//--- START OF USER ZONE 2
        var padSideSet = Set <TrackSide> ()
//        var frontSide = false
//        var backSide = false
        for track in self_mTracksP1_mSide {
          padSideSet.insert (track.mSide)
//          switch track.mSide {
//          case .back  :
//            backSide  = true
//          case .front :
//            frontSide = true
//          case .inner1, .inner2, .inner3, .inner4 :
//            frontSide = true
//            backSide  = true
//          }
        }
        for track in self_mTracksP2_mSide {
          padSideSet.insert (track.mSide)
//          switch track.mSide {
//          case .back  :
//             backSide  = true
//          case .front :
//            frontSide = true
//          case .inner1, .inner2, .inner3, .inner4 :
//            frontSide = true
//            backSide  = true
//          }
        }
        if let descriptor = self_mComponent_componentPadDictionary? [self_mComponentPadName] {
 //         padSideSet.insert (descriptor.pads [self_mPadIndex].side)
          switch descriptor.pads [self_mPadIndex].side {
          case .back  :
            padSideSet.insert (.back)
//            backSide  = true
          case .front :
            padSideSet.insert (.front)
//            frontSide = true
          case .inner1 :
            padSideSet.insert (.inner1)
          case .inner2 :
            padSideSet.insert (.inner2)
          case .inner3 :
            padSideSet.insert (.inner3)
          case .inner4 :
            padSideSet.insert (.inner2)
          case .traversing  :
            padSideSet.insert (.back)
            padSideSet.insert (.front)
//            backSide  = true ;
//            frontSide = true
          }
        }
        if padSideSet.count == 1 {
          switch padSideSet.first! {
          case .front :
            return .front
          case .back :
            return .back
          case .inner1 :
            return .inner1
          case .inner2 :
            return .inner2
          case .inner3 :
            return .inner3
          case .inner4 :
            return .inner4
          }
        }else{
          return .traversing
        }
//        if backSide && frontSide {
//          return  .both
//        }else if backSide {
//          return .back
//        }else if frontSide {
//          return .front
//        }else{
//          return  .both
//        }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
