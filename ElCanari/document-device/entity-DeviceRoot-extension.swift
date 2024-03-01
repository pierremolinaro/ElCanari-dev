//
//  entity-DeviceRoot-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 11/12/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension DeviceRoot {

  //································································································

  func updatePadProxies () {
 //   Swift.print ("updatePadProxies")
  //--- Inventory of current pad names
    var currentPackagePadNameSet = Set <String> ()
    for package in self.mPackages.values {
      for masterPad in package.mMasterPads.values {
        currentPackagePadNameSet.insert (masterPad.mName)
      }
    }
  //--- Inventory of current pad proxies
    var currentProxyPadNameSet = Set <String> ()
    var padProxyDictionary = [String : PadProxyInDevice] ()
    for padProxy in self.mPadProxies.values {
      padProxyDictionary [padProxy.mPadName] = padProxy
      currentProxyPadNameSet.insert (padProxy.mPadName)
    }
  //--- Remove pad proxies without corresponding pad
    for padName in currentProxyPadNameSet.subtracting (currentPackagePadNameSet) {
   //   Swift.print ("removing pad proxy \(padName)")
      let padProxy = padProxyDictionary [padName]!
      padProxy.mPinInstance = nil // No observation on weak release, so we release explicitely, it iis observed
      self.mPadProxies_property.remove (padProxy)
    }
  //--- Add missing pad proxies
    for padName in currentPackagePadNameSet.subtracting (currentProxyPadNameSet) {
      let newPadProxy = PadProxyInDevice (self.undoManager)
      newPadProxy.mPadName = padName
      self.mPadProxies_property.add (newPadProxy)
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
