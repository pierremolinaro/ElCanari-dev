//
//  checkEmbeddedDevicesAndFonts.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func checkEmbeddedDevicesAndFonts () {
    var messages = [String] ()
    self.checkDevices (&messages)
    self.checkFonts (&messages)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
