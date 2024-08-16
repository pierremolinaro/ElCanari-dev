//
//  retained-properties.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/08/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func performRetain (property inProperty : AnyObject, forObject inObject : NSView) {
  gArray.append (Entry (inObject, inProperty))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

nonisolated func objectDidDeinit () {
  DispatchQueue.main.async {
    if !gNeedToUpdateArray {
      gNeedToUpdateArray = true
      DispatchQueue.main.async {
        gNeedToUpdateArray = false
        var newArray = [Entry] ()
        for entry in gArray {
          if entry.mObject != nil {
            newArray.append (entry)
          }
        }
        gArray = newArray
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct Entry {
  weak var mObject : NSView?
  let mProperty : AnyObject

  init (_ inObject : NSView, _ inProperty : AnyObject) {
    self.mObject = inObject
    self.mProperty = inProperty
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate var gNeedToUpdateArray = false
@MainActor fileprivate var gArray = [Entry] ()

//——————————————————————————————————————————————————————————————————————————————————————————————————
