//
//  ProjectDocument-customized-nets.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func newNetWithAutomaticName () -> NetInProject {
  //--- Find a new net name
    var newNetName = ""
    var idx = 1
    while newNetName == "" {
      let tentativeNetName = "$\(idx)"
      var ok = true
      for netClass in self.rootObject.mNetClasses {
        for net in netClass.mNets {
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
  //--- Create new
    let newNet = NetInProject (self.ebUndoManager)
    newNet.mNetName = newNetName
    newNet.mNetClass = self.rootObject.mNetClasses [0]
  //---
    return newNet
  }

  //····················································································································

  internal func removeUnusedNets () {
    for netClass in self.rootObject.mNetClasses {
      var idx = 0
      while idx < netClass.mNets.count {
        let net = netClass.mNets [0]
        if net.mPoints.count == 0 {
          net.mNetClass = nil
          netClass.mNets.remove (at: idx)
        }else{
          idx += 1
        }
      }

    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
