//
//  Created by Pierre Molinaro on 01/10/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func changePackageOfSelectedComponents () {
    var possiblePackages = StringArray ()
    var componentNames = [String] ()
    var currentSelectedPackageSet = Set <String> ()
    let selectedComponents = self.componentController.selectedArray_property.propval
    if selectedComponents.count > 0 {
      var intersectionOfPackageSet = Set (selectedComponents [0].availablePackages!)
      for component in selectedComponents.values {
        componentNames.append (component.componentName!)
        currentSelectedPackageSet.insert (component.mSelectedPackage!.mPackageName)
        if let availablePackages = component.availablePackages {
          intersectionOfPackageSet.formIntersection (availablePackages)
        }
      }
      possiblePackages = Array (intersectionOfPackageSet)
    }
    componentNames.sort ()
  //---
    if possiblePackages.count > 0, let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 180),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
      let okButton = AutoLayoutSheetDefaultOkButton (title: "", size: .regular, sheet: panel)
    //---
      _ = layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Change Package", bold: true, size: .regular, alignment: .center))
      _ = layoutView.appendFlexibleSpace ()
      let gridView = AutoLayoutGridView2 ()
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "Components", bold: false, size: .regular, alignment: .right)
        let right = AutoLayoutStaticLabel (title: componentNames.joined (separator: ", "), bold: true, size: .regular, alignment: .center)
          .expandableWidth().set (alignment: .left)
        _ = gridView.addFirstBaseLineAligned (left: left, right: right)
      }
      let popupButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: .regular).expandableWidth ()
      let stringAttributes : [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: 0.0)
      ]
      for packageName in possiblePackages.sorted () {
        popupButton.addItem (withTitle: packageName)
        if let item = popupButton.lastItem {
          item.target = self
          item.action = #selector (Self.changeSelectedPackageAction (_:))
          item.representedObject = okButton
          if currentSelectedPackageSet.contains (packageName) {
            item.attributedTitle = NSAttributedString (string: packageName, attributes: stringAttributes)
            popupButton.select (item)
            self.changeSelectedPackageAction (item)
          }
        }
      }
      do{
        let left = AutoLayoutStaticLabel (title: "Package", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: popupButton)
      }
      _ = layoutView.appendView (gridView)
      _ = layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
        _ = hStack.appendFlexibleSpace ()
        _ = hStack.appendView (okButton)
        _ = layoutView.appendView (hStack)
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newPackageName = popupButton.titleOfSelectedItem {
          for component in selectedComponents.values {
            var newPossiblePackage : DevicePackageInProject? = nil
            for candidatePackage in component.mDevice?.mPackages_property.propval.values ?? [] {
              if candidatePackage.mPackageName == newPackageName {
                newPossiblePackage = candidatePackage
              }
            }
            if let newPackage = newPossiblePackage {
              component.set (package: newPackage)
            }
          }
        }
      }
    }
  }

  //····················································································································

  @objc func changeSelectedPackageAction (_ inSender : NSMenuItem) {
    if let okButton = inSender.representedObject as? AutoLayoutSheetDefaultOkButton {
      okButton.title = "Change to '\(inSender.title)'"
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension ComponentInProject {

  //····················································································································

  func set (package inPackage : DevicePackageInProject) {
    if self.isPlacedInBoard! {
    //--- Check the corresponding pad does exist in new package
      for currentConnector in self.mConnectors_property.propval.values {
        var found = false
        for (padName, masterPadDescriptor) in inPackage.packagePadDictionary! {
          if (currentConnector.mComponentPadName == padName) && (currentConnector.mPadIndex <= masterPadDescriptor.slavePads.count) {
            found = true
          }
        }
        if !found { // If not found, new package does not accept this slave pad: detach pad from component
          let p = currentConnector.location!
          currentConnector.mX = p.x
          currentConnector.mY = p.y
          currentConnector.mComponent = nil
          currentConnector.mComponentPadName = ""
          currentConnector.mPadIndex = 0
          if (currentConnector.mTracksP1.count == 0) && (currentConnector.mTracksP2.count == 0) {
            currentConnector.mRoot = nil // Remove from board
          }
        }
      }
    //--- Check a slave pad does exist for the new package
//      let padNetDictionary = self.padNetDictionary!
      for (padName, masterPadDescriptor) in inPackage.packagePadDictionary! {
        if masterPadDescriptor.slavePads.count > 0 {
          for slavePadIndex in 1 ... masterPadDescriptor.slavePads.count {
            var found = false
            for currentConnector in self.mConnectors_property.propval.values {
              if (currentConnector.mComponentPadName == padName) && (currentConnector.mPadIndex == slavePadIndex) {
                found = true
              }
            }
            if !found { // There is not connector for this slave pad: create one
//              let p = masterPadDescriptor.slavePads [slavePadIndex - 1].center
//              let style = masterPadDescriptor.slavePads [slavePadIndex - 1].style
//              let side : ConnectorSide
//              switch style {
//              case .componentSide :
//                switch self.mSide {
//                case .back : side = .back
//                case .front : side = .front
//                }
//              case .oppositeSide :
//                switch self.mSide {
//                case .back : side = .front
//                case .front : side = .back
//                }
//              case .traversing :
//                side = .both
//              }
//              if let possibleConnectors = self.mRoot?.connectors (at: p, connectorSide: side),
//                 possibleConnectors.count == 1,
//                 possibleConnectors [0].mComponent == nil,
//                 let connectorNetName = possibleConnectors [0].netNameFromTracks,
//                 let padNetName = padNetDictionary [padName],
//                 connectorNetName == padNetName {
//                possibleConnectors [0].mComponent = self
//                possibleConnectors [0].mComponentPadName = padName
//                possibleConnectors [0].mPadIndex = slavePadIndex
//              }else{ // Create a new connector
                let newConnector = BoardConnector (self.undoManager)
                newConnector.mComponent = self
                newConnector.mComponentPadName = padName
                newConnector.mPadIndex = slavePadIndex
                newConnector.mRoot = self.mRoot
//              }
            }
          }
        }
      }
    }
  //--- Assign new package
    self.mSelectedPackage = inPackage
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
