//
//  CanariNetsMenuItem.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

class CanariNetsMenuItem : NSMenuItem, EBUserClassNameProtocol {

  //····················································································································

  override init (title inString : String, action inSelector : Selector?, keyEquivalent inCharCode : String) {
    super.init (title: inString, action: inSelector, keyEquivalent: inCharCode)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  Project
  //····················································································································

  private weak var mProject : ProjectDocument? = nil

  //····················································································································

  func set (project inProject : ProjectDocument) {
    self.mProject = inProject
  }

  //····················································································································
  //  $nets binding
  //····················································································································

  private var mComponentsController : EBSimpleController? = nil

  //····················································································································

  func bind_nets (_ model : EBReadOnlyProperty_StringArray, file : String, line : Int) {
    self.mComponentsController = EBSimpleController (
      observedObjects: [model],
      callBack: { self.update (from: model) }
     )
  }

  //····················································································································

  func unbind_nets () {
    self.mComponentsController?.unregister ()
    self.mComponentsController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_StringArray) {
  //--- Empty submenu
    let submenu = self.submenu
    submenu?.removeAllItems ()
    switch model.prop {
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
      let prefixMenuItem = submenu?.addItem (withTitle: "$", action: nil, keyEquivalent: "")
      let prefixSubMenu = NSMenu (title: "")
      prefixMenuItem?.submenu = prefixSubMenu
      for netName in dollarNetNames.numericallySorted () {
        let menuItem = prefixSubMenu.addItem (withTitle: netName, action: #selector (self.addTracksToSelection (_:)), keyEquivalent: "")
        menuItem.target = self
      }
      for netName in otherNetNames.numericallySorted () {
        let menuItem = submenu?.addItem (withTitle: netName, action: #selector (self.addTracksToSelection (_:)), keyEquivalent: "")
        menuItem?.target = self
      }
    }
  }

  //····················································································································

  @objc private func addTracksToSelection (_ inSender : NSMenuItem) {
     if let project = self.mProject {
       var objectsToSelect = [BoardObject] ()
       for object in project.rootObject.mBoardObjects {
         if let track = object as? BoardTrack, let net = track.mNet, net.mNetName == inSender.title {
           objectsToSelect.append (object)
         }
       }
       project.boardObjectsController.addToSelection (objects: objectsToSelect)
     }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
