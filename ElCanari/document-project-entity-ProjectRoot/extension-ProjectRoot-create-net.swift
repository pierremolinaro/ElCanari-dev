//
//  extension-ProjectRoot-create-net.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectRoot {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Find a new unique name
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func findUniqueNetName () -> String {
    var newNetName = ""
    var idx = 1
    while newNetName.isEmpty {
      let tentativeNetName = "$\(idx)"
      var ok = true
      for netClass in self.mNetClasses.values {
        for net in netClass.mNets.values {
          if net.mNetName == tentativeNetName {
            ok = false
          }
        }
      }
      if ok {
        newNetName = tentativeNetName
      }else{
        idx += 1
      }
    }
  //---
    return newNetName
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Create a new net with automatic name
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func createNetWithAutomaticName () -> NetInProject {
  //--- Find a new net name
    let newNetName = self.findUniqueNetName ()
  //--- Find net class
    var selectedNetClass : NetClassInProject? = nil
    for netClass in self.mNetClasses.values {
      if netClass.mNetClassName == self.mDefaultNetClassName {
        selectedNetClass = netClass
      }
    }
  //--- Create new net
    let newNet = NetInProject (self.undoManager)
    newNet.mNetName = newNetName
    if let netClass = selectedNetClass {
      newNet.mNetClass = netClass
    }else{
      newNet.mNetClass = self.mNetClasses [0]
    }
  //---
    return newNet
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
