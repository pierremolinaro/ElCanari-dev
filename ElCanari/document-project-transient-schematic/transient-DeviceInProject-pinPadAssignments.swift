//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_DeviceInProject_pinPadAssignments (
       _ self_mPadAssignments_pinPadAssignment : [DevicePadAssignmentInProject_pinPadAssignment]
) -> ThreeStringArray {
//--- START OF USER ZONE 2
        var result = ThreeStringArray ()
        for p in self_mPadAssignments_pinPadAssignment {
          if let assignment = p.pinPadAssignment {
            result.append (assignment)
          }
        }
        return result
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————