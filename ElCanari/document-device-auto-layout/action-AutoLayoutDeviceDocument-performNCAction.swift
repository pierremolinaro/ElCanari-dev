//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//----------------------------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension AutoLayoutDeviceDocument {
  @objc func performNCAction (_ sender : NSObject?) {
//--- START OF USER ZONE 2
        if let selectedName = self.mUnconnectedPadsInDeviceTableView?.selectedPadName {
          for padProxy in self.rootObject.mPadProxies {
            if padProxy.mPadName == selectedName {
             padProxy.mPinInstance = nil
             padProxy.mIsNC = true
            }
          }
        }
//--- END OF USER ZONE 2
  }
}

//----------------------------------------------------------------------------------------------------------------------