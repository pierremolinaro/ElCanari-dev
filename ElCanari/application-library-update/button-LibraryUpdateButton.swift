//
//  LibraryUpdateButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/36622263/programatically-changing-button-text-and-actions-when-a-modifier-key-is-pressed
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class LibraryUpdateButton : NSButton {

  //····················································································································
  //  Properties
  //····················································································································

  private var mRegularTitle = "" // Set by awakeFromNib
  private var mOptionTitle = "Update System Library to Revision…"
  private var mEventMonitor : Any? = nil // For tracking option key change

  //····················································································································
  //   awakeFromNib
  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.mRegularTitle = self.title
    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .flagsChanged) { inEvent in
      let optionKey = inEvent.modifierFlags.contains (.option)
      self.title = optionKey ? self.mOptionTitle : self.mRegularTitle
      return inEvent
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
