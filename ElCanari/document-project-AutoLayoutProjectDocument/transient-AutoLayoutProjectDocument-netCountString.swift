//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_AutoLayoutProjectDocument_netCountString (
       _ root_netsDescription : NetInfoArray
) -> String {
//--- START OF USER ZONE 2
        if root_netsDescription.count == 0 {
          return "No net"
        }else if root_netsDescription.count == 1 {
          return "1 net"
        }else{
          return "\(root_netsDescription.count) nets"
        }
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————