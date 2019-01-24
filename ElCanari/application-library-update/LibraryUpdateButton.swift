//
//  LibraryUpdateButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryUpdateButton : NSButton {

  //····················································································································
  //  Properties
  //····················································································································

  private var mRegularTitle = "" // Set by awakeFromNib
  private var mOptionTitle = "Update Library ro Revision…"

  //····················································································································
  //   awakeFromNib
  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.mRegularTitle = self.title
  }

  //····················································································································
  //  Hilite when mouse is within button
  //····················································································································

  override func updateTrackingAreas () { // This is required for receiving mouseEntered and mouseExited events
  //--- Remove all tracking areas
    for trackingArea in self.trackingAreas {
      self.removeTrackingArea (trackingArea)
    }
  //--- Add Updated tracking area
    let trackingArea = NSTrackingArea (
      rect: self.bounds,
      options: [.mouseEnteredAndExited,.activeInKeyWindow],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea (trackingArea)
  //---
    super.updateTrackingAreas ()
  }

  //····················································································································

  private var mUsesOptionTitle = false { didSet { self.needsDisplay = true } }

  //····················································································································

  override func mouseEntered (with inEvent : NSEvent) {
    if self.isEnabled {
      self.window?.makeFirstResponder (self)
      let optionKey = inEvent.modifierFlags.contains (.option)
      if optionKey {
        self.title = self.mOptionTitle
        self.mUsesOptionTitle = true
      }

    }
    super.mouseEntered (with: inEvent)
  }

  //····················································································································

  override func flagsChanged (with inEvent : NSEvent) {
    let optionKey = inEvent.modifierFlags.contains (.option)
    // Swift.print ("optionKey \(optionKey)")
    if self.mUsesOptionTitle != optionKey {
      self.mUsesOptionTitle = optionKey
      self.title = optionKey ? self.mOptionTitle : self.mRegularTitle
    }
    super.flagsChanged (with: inEvent)
  }

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.resignFirstResponder ()
    if self.mUsesOptionTitle {
      self.mUsesOptionTitle = false
      self.title = self.mRegularTitle
    }
    super.mouseExited (with: inEvent)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
