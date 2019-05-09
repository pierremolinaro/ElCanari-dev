//
//  ProjectDocument-customized-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func populateContextualClickOnSchematics (_ inMouseDownPoint : CanariPoint) -> NSMenu {
    let canariAlignedMouseDownLocation = inMouseDownPoint.point (alignedOnGrid: SCHEMATICS_GRID_IN_CANARI_UNIT)
    let menu = NSMenu ()
  //--- Add NC ?
     let points = self.pointsInSchematics (at: canariAlignedMouseDownLocation)
     if points.count == 1 {
       let point = points [0]
       if point.mNC == nil, point.mLabels.count == 0, point.mWiresP1s.count == 0, point.mWiresP2s.count == 0 {
         let menuItem = NSMenuItem (title: "Add NC", action: #selector (CustomizedProjectDocument.addNCToPin (_:)), keyEquivalent: "")
         menuItem.target = self
         menuItem.representedObject = point
         menu.addItem (menuItem)
       }
     }
  //--- Add Connect ? (only if no NC)
     if points.count > 1 {
       var hasNC = false
       var pinCount = 0
       for p in points {
         if p.mNC != nil {
           hasNC = true
         }
         if p.mSymbol != nil {
           pinCount += 1
         }
       }
       if !hasNC && (pinCount <= 1) {
         if menu.numberOfItems > 0 {
           menu.addItem (.separator ())
         }
         let menuItem = NSMenuItem (title: "Connect…", action: #selector (CustomizedProjectDocument.connect (_:)), keyEquivalent: "")
         menuItem.target = self
         menuItem.representedObject = points
         menu.addItem (menuItem)
       }
    }
  //--- Add Point to wire ?
    let wires = self.wiresAt (point: canariAlignedMouseDownLocation)
    if wires.count == 1 {
       if menu.numberOfItems > 0 {
         menu.addItem (.separator ())
       }
       let menuItem = NSMenuItem (title: "Add Point to Wire…", action: #selector (CustomizedProjectDocument.addPointToWire (_:)), keyEquivalent: "")
       menuItem.target = self
       menuItem.representedObject = canariAlignedMouseDownLocation
       menu.addItem (menuItem)

    }
  //--- Add Labels
     if menu.numberOfItems > 0 {
       menu.addItem (.separator ())
     }
     var menuItem = NSMenuItem (title: "Add Label with right flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 0 // Right
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
     menuItem = NSMenuItem (title: "Add Label with top flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 1 // Top
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
     menuItem = NSMenuItem (title: "Add Label with left flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 2 // Left
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
     menuItem = NSMenuItem (title: "Add Label with bottom flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 3 // Bottom
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
  //---
    return menu
  }

  //····················································································································

  @objc internal func connect (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematics], let window = self.windowForSheet {
      var netSet = Set <NetInProject> ()
      for point in points {
        if let net = point.mNet {
          netSet.insert (net)
        }
      }
    //---
      let netArray = Array (netSet).sorted { $0.mNetName > $1.mNetName }
      if netArray.count == 1 {
        self.propagateAndMerge (net: netArray [0], to: points)
      }else if netArray.count == 2 {
        let alert = NSAlert ()
        alert.messageText = "Performing connection will merge two nets."
        for net in netArray {
          alert.addButton (withTitle: net.mNetName)
        }
        alert.addButton (withTitle: "Cancel")
        alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
          self.handleAlertResponseForMergingNets (response, points, netArray)
        }
      }else if netArray.count == 3 {
        let alert = NSAlert ()
        alert.messageText = "Performing connection will merge three nets."
        for net in netArray {
          alert.addButton (withTitle: net.mNetName)
        }
        alert.addButton (withTitle: "Cancel")
        alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
          self.handleAlertResponseForMergingNets (response, points, netArray)
        }
      }else if netArray.count > 3 {
      }
    }
  }

  //····················································································································

  internal func handleAlertResponseForMergingNets (_ inResponse : NSApplication.ModalResponse,
                                                   _ inPoints : [PointInSchematics],
                                                   _ inNetArray : [NetInProject]) {
    let responseIndex = inResponse.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
    if responseIndex < inNetArray.count {
      // NSLog ("responseIndex \(responseIndex)")
      let newNet = inNetArray [responseIndex]
      self.propagateAndMerge (net: newNet, to: inPoints)
    }
  }

  //····················································································································

  @objc internal func addNCToPin (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematics {
      let nc = NCInSchematics (self.ebUndoManager)
      nc.mPoint = point
      nc.mOrientation = self.findPreferredNCOrientation (for: point)
      self.rootObject.mSelectedSheet?.mObjects.append (nc)
      self.mSchematicsObjectsController.setSelection ([nc])
    }
  }

  //····················································································································

  @objc internal func addLabelInSchematics (_ inSender : NSMenuItem) {
    if let mouseLocation = inSender.representedObject as? CanariPoint {
      let canariAlignedMouseDownLocation = mouseLocation.point (alignedOnGrid: SCHEMATICS_GRID_IN_CANARI_UNIT)
      let points = self.pointsInSchematics (at: canariAlignedMouseDownLocation)
      var possiblePoint : PointInSchematics? = nil
      if points.count == 1 {
        possiblePoint = points [0]
      }else if points.count == 0 {
        let point = PointInSchematics (self.ebUndoManager)
        point.mX = canariAlignedMouseDownLocation.x
        point.mY = canariAlignedMouseDownLocation.y
        point.mNet = self.createNetWithAutomaticName ()
        self.rootObject.mSelectedSheet?.mPoints.append (point)
        possiblePoint = point
      }
      if let point = possiblePoint {
        let label = LabelInSchematics (self.ebUndoManager)
        label.mPoint = point
        if inSender.tag == 1 {
          label.mOrientation = .rotation90
        }else if inSender.tag == 2 {
          label.mOrientation = .rotation180
        }else if inSender.tag == 3 {
          label.mOrientation = .rotation270
        }else{
          label.mOrientation = .rotation0
        }
        self.rootObject.mSelectedSheet?.mObjects.append (label)
        self.mSchematicsObjectsController.setSelection ([label])
      }
    }
  }

  //····················································································································

  private func findPreferredNCOrientation (for inPoint : PointInSchematics) -> QuadrantRotation {
  //--- Find the rectangle of all pins of current symbol
    let symbol = inPoint.mSymbol!
    let symbolInfo = symbol.symbolInfo!
//    var symbolPinLocationArray = [CanariPoint] ()
//    for pin in symbolInfo.pins {
//      symbolPinLocationArray.append (pin.pinLocation)
//    }
  //---
    var cocoaRect = NSRect.null
    if !symbolInfo.strokeBezierPath.isEmpty {
      cocoaRect = cocoaRect.union (symbolInfo.strokeBezierPath.bounds)
    }
    if !symbolInfo.filledBezierPath.isEmpty {
      cocoaRect = cocoaRect.union (symbolInfo.filledBezierPath.bounds)
    }
   // let symbolPinRect = CanariRect (points: symbolPinLocationArray)
    let relativeLocation = cocoaRect.relativeLocation (of: inPoint.location!.cocoaPoint)
    switch relativeLocation {
    case .above :
      return .rotation90
    case .left :
      return .rotation180
    case .below :
      return .rotation270
    case .right :
      return .rotation0
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
