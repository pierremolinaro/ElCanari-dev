//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {
  @objc func removeNetClassAction (_ sender : NSObject?) {
//--- START OF USER ZONE 2
        for netClass in self.netClassController.selectedArray.values {
          if let idx = self.rootObject.mNetClasses.firstIndex (of: netClass) {
            self.rootObject.mNetClasses.remove (at: idx)
          }
        }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————