//
//  AutoLayoutCanariBoardOperationPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariBoardOperationPullDownButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (pullsDown: true, size: inSize)

    self.addItem (withTitle: "")
    self.lastItem?.image = NSImage (named: NSImage.smartBadgeTemplateName)
 }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  private weak var mDocument : AutoLayoutProjectDocument? = nil
  private let mSelectComponentSubMenu = NSMenu ()
  private let mSelectNetTrackSubMenu = NSMenu ()

  //····················································································································

  func setDocument (_ inDocument : AutoLayoutProjectDocument) {
    self.mDocument = inDocument
    self.bind_componentsPlacedInBoardArray (inDocument.rootObject.componentsPlacedInBoard_property)
    self.bind_netNamesArray (inDocument.rootObject.netNamesArray_property)
  //--- Select All Components
    self.addItem (withTitle: "Select all Components")
    self.lastItem?.target = inDocument
    self.lastItem?.action = #selector (AutoLayoutProjectDocument.selectAllComponentsAction (_:))
    self.lastItem?.keyEquivalent = "a"
    self.lastItem?.keyEquivalentModifierMask = [.control, .command]
  //--- Rename all Components
    self.addItem (withTitle: "Select Component")
    self.lastItem?.submenu = self.mSelectComponentSubMenu
  //--- Select All Tracks
    self.addItem (withTitle: "Select all Tracks of")
    let submenu = NSMenu ()
    submenu.addItem (
      withTitle: "Visible Layers",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfVisibleLayersAction (_:)),
      keyEquivalent: ""
    )
    submenu.addItem (
      withTitle: "Front Side Layer",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfFrontLayerAction (_:)),
      keyEquivalent: ""
    )
    submenu.addItem (
      withTitle: "Back Side Layer",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfBackLayerAction (_:)),
      keyEquivalent: ""
    )
    submenu.addItem (
      withTitle: "Inner 1 Layer",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfInner1LayerAction (_:)),
      keyEquivalent: ""
    )
    submenu.addItem (
      withTitle: "Inner 2 Layer",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfInner2LayerAction (_:)),
      keyEquivalent: ""
    )
    submenu.addItem (
      withTitle: "Inner 3 Layer",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfInner3LayerAction (_:)),
      keyEquivalent: ""
    )
    submenu.addItem (
      withTitle: "Inner 4 Layer",
      action: #selector (AutoLayoutProjectDocument.selectAllTracksOfInner4LayerAction (_:)),
      keyEquivalent: ""
    )
    for item in submenu.items {
      item.target = inDocument
    }
    self.lastItem?.submenu = submenu
  //--- Select Tracks from Selected Track Net
    self.addItem (withTitle: "Select Tracks from Selected Track Nets")
    self.lastItem?.target = inDocument
    self.lastItem?.action = #selector (AutoLayoutProjectDocument.selectAllTracksOfSelectedTracksNetsAction (_:))
    self.lastItem?.keyEquivalent = "t"
    self.lastItem?.keyEquivalentModifierMask = [.option, .command]
  //--- Select Tracks of Net
    self.addItem (withTitle: "Select Tracks of Net")
    self.lastItem?.submenu = self.mSelectNetTrackSubMenu
  //--- Select All Vias
    self.addItem (withTitle: "Select all Vias")
    self.lastItem?.target = inDocument
    self.lastItem?.action = #selector (AutoLayoutProjectDocument.selectAllViasAction (_:))
  //--- Select All Restrict Rectangles
    self.addItem (withTitle: "Select all Restrict Rectangles")
    self.lastItem?.target = inDocument
    self.lastItem?.action = #selector (AutoLayoutProjectDocument.selectAllRestrictRectanglesAction (_:))
  //--- Separator
    self.menu?.addItem (.separator ())
  //--- Rename all Components
    do{
      let menuItem = NSMenuItem (title: "Rename all Components", action: nil, keyEquivalent: "")
      self.menu?.addItem (menuItem)
      let submenu = NSMenu ()
      menuItem.submenu = submenu
      submenu.addItem (
        withTitle: "Left to Right, Upwards",
        action: #selector (AutoLayoutProjectDocument.renameComponentsLeftToRightUpwardsAction (_:)),
        keyEquivalent: ""
      )
      submenu.items.last?.target = inDocument
      submenu.addItem (
        withTitle: "Left to Right, Downwards",
        action: #selector (AutoLayoutProjectDocument.renameComponentsLeftToRightDownwardsAction (_:)),
        keyEquivalent: ""
      )
      submenu.items.last?.target = inDocument
    }
  //--- Separator
    self.menu?.addItem (.separator ())
  //--- Remove all Tracks and Vias
    self.addItem (withTitle: "Remove all Tracks and Vias")
    self.lastItem?.target = inDocument
    self.lastItem?.action = #selector (AutoLayoutProjectDocument.removeAllViasAndTracksAction (_:))
    self.lastItem?.keyEquivalent = "r"
    self.lastItem?.keyEquivalentModifierMask = [.option, .command]
  //--- Separator
    self.menu?.addItem (.separator ())
  //--- Sort Objects following Layers
    self.addItem (withTitle: "Sort Objects following Layers")
    self.lastItem?.target = inDocument
    self.lastItem?.action = #selector (AutoLayoutProjectDocument.sortBoardObjectsFollowingBoardLayersAction (_:))
  }

  //····················································································································
  //  mSelectComponentController
  //····················································································································

  private var mSelectComponentController : EBObservablePropertyController? = nil

  //····················································································································

  private func bind_componentsPlacedInBoardArray (_ inModel : EBTransientProperty <StringTagArray>) {
    self.mSelectComponentController = EBObservablePropertyController (
      observedObjects : [inModel],
      callBack: { [weak self] in self?.updateComponentsPlacedInBoard (inModel) }
    )
  }
  
  //····················································································································

  private func updateComponentsPlacedInBoard (_ inModel : EBTransientProperty <StringTagArray>) {
    self.mSelectComponentSubMenu.removeAllItems ()
    switch inModel.selection {
    case .empty, .multiple :
      ()
    case .single (let components) :
      var componentNameSet = [String : [Int]] ()
      for component in components {
        let prefix = component.string
        let index = component.tag
        componentNameSet [prefix] = componentNameSet [prefix, default: []] + [index]
      }
      let prefixes : [String] = Array (componentNameSet.keys).sorted ()
      for aPrefix in prefixes {
        let prefixMenuItem = self.mSelectComponentSubMenu.addItem (withTitle: aPrefix, action: nil, keyEquivalent: "")
        let prefixSubMenu = NSMenu (title: "")
        prefixMenuItem.submenu = prefixSubMenu
        for idx in componentNameSet [aPrefix]!.sorted () {
          let componentName = aPrefix + "\(idx)"
          let menuItem = prefixSubMenu.addItem (
            withTitle: componentName,
            action: #selector (AutoLayoutProjectDocument.addComponentToSelection (_:)),
            keyEquivalent: ""
          )
          menuItem.target = self.mDocument
        }
      }
    }
  }

  //····················································································································
  //  mUpdateNetNamesArrayController
  //····················································································································

  private var mUpdateNetNamesArrayController : EBObservablePropertyController? = nil

  //····················································································································

  private func bind_netNamesArray (_ inModel : EBTransientProperty <StringArray>) {
    self.mUpdateNetNamesArrayController = EBObservablePropertyController (
      observedObjects : [inModel],
      callBack: { [weak self] in self?.updateNetNamesArray (inModel) }
    )
  }

  //····················································································································

  private func updateNetNamesArray (_ inModel : EBTransientProperty <StringArray>) {
    self.mSelectNetTrackSubMenu.removeAllItems ()
    switch inModel.selection {
    case .empty, .multiple :
      ()
    case .single (let netNames) :
      var dollarNetNames = [String] ()
      var otherNetNames = [String] ()
      for netName in netNames {
        if netName.hasPrefix ("$") {
          dollarNetNames.append (netName)
        }else{
          otherNetNames.append (netName)
        }
      }
      let prefixMenuItem = self.mSelectNetTrackSubMenu.addItem (withTitle: "$", action: nil, keyEquivalent: "")
      let prefixSubMenu = NSMenu (title: "")
      prefixMenuItem.submenu = prefixSubMenu
      for netName in dollarNetNames.numericallySorted () {
        let menuItem = prefixSubMenu.addItem (withTitle: netName, action: #selector (AutoLayoutProjectDocument.addTracksToSelection (_:)), keyEquivalent: "")
        menuItem.target = self.mDocument
      }
      for netName in otherNetNames.numericallySorted () {
        let menuItem = self.mSelectNetTrackSubMenu.addItem (withTitle: netName, action: #selector (AutoLayoutProjectDocument.addTracksToSelection (_:)), keyEquivalent: "")
        menuItem.target = self.mDocument
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
