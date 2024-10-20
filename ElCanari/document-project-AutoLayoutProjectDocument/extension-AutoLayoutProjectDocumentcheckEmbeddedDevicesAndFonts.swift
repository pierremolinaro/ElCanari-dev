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

  func triggerStandAlonePropertyComputationForProject () {
    if !self.mStandAlonePropertyComputationIsTriggered {
      self.mStandAlonePropertyComputationIsTriggered = true
      DispatchQueue.main.async {
        var messages = [String] ()
        self.checkDevices (&messages)
        self.checkFonts (&messages)
        self.checkArtwork ()
        self.mStandAlonePropertyComputationIsTriggered = false
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func registerUndoForTriggeringStandAlonePropertyComputationForProject () {
    self.undoManager?.registerUndo (withTarget: self) { (inOwner) in
      inOwner.triggerStandAlonePropertyComputationForProject ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
