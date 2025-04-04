//
//  ProjectRoot-remove-unused-devices.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 11/12/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension ProjectRoot {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeUnusedDevices () {
    for device in self.mDevices.values {
      if device.mComponents.count == 0 {
        self.mDevices_property.remove (device)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//--------------------------------------------------------------------------------------------------

