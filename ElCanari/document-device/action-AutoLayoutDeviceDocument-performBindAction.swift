//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutDeviceDocument {
  @objc func performBindAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
        var possiblePadProxy : PadProxyInDevice? = nil
        if let selectedName = self.mUnconnectedPadsInDeviceTableView?.selectedPadName {
          for padProxy in self.rootObject.mPadProxies.values {
            if padProxy.mPadName == selectedName {
              possiblePadProxy = padProxy
            }
          }
        }
        var possibleSymbolPin : SymbolPinInstanceInDevice? = nil
        if let selectedSymbolPin = self.mUnconnectedSymbolPinsInDeviceTableView?.selectedSymbolPin {
          for symbolInstance in self.rootObject.mSymbolInstances.values {
            for symbolPin in symbolInstance.mPinInstances.values {
              if (symbolPin.pinName! == selectedSymbolPin.pinName) && (symbolPin.symbolName! == selectedSymbolPin.symbolInstanceName) {
                possibleSymbolPin = symbolPin
              }
            }
          }
        }
        if let padProxy = possiblePadProxy, let symbolPin = possibleSymbolPin {
          padProxy.mPinInstance = symbolPin
          padProxy.mIsNC = false
          padProxy.mPinInstanceName = symbolPin.pinName!
        }
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
