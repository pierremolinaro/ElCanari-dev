//
//  CanariComponentsMenuItem.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

class CanariComponentsMenuItem : NSMenuItem, EBUserClassNameProtocol {

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
  //  Project
  //····················································································································

  private weak var mProject : ProjectDocument? = nil

  //····················································································································

  func set (project inProject : ProjectDocument) {
    self.mProject = inProject
  }

  //····················································································································
  //  $components binding
  //····················································································································

  private var mComponentsController : EBSimpleController? = nil

  //····················································································································

  func bind_components (_ model : EBReadOnlyProperty_StringTagArray, file : String, line : Int) {
    self.mComponentsController = EBSimpleController (
      observedObjects: [model],
      callBack: { self.update (from: model) }
    )
  }

  //····················································································································

  func unbind_components () {
    self.mComponentsController?.unregister ()
    self.mComponentsController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_StringTagArray) {
  //--- Empty submenu
    let submenu = self.submenu
    submenu?.removeAllItems ()
    switch model.selection {
    case .empty, .multiple :
      ()
    case .single (let components) :
      var componentNameSet = [String : [Int]] ()
      for component in components {
        let prefix = component.string
        let index = component.tag
        componentNameSet [prefix] = (componentNameSet [prefix] ?? []) + [index]
      }
      let prefixes : [String] = Array (componentNameSet.keys).sorted ()
      for prefix in prefixes {
        let prefixMenuItem = submenu?.addItem (withTitle: prefix, action: nil, keyEquivalent: "")
        let prefixSubMenu = NSMenu (title: "")
        prefixMenuItem?.submenu = prefixSubMenu
        for idx in componentNameSet [prefix]!.sorted () {
          let componentName = prefix + "\(idx)"
          let menuItem = prefixSubMenu.addItem (withTitle: componentName, action: #selector (self.addComponentToSelection (_:)), keyEquivalent: "")
          menuItem.target = self
        }
      }
    }
  }

  //····················································································································

  @objc private func addComponentToSelection (_ inSender : NSMenuItem) {
     if let project = self.mProject {
       var objectsToSelect = [BoardObject] ()
       for component in project.rootObject.mComponents {
         if let componentName = component.componentName, componentName == inSender.title {
           objectsToSelect.append (component)
         }
       }
       project.boardObjectsController.addToSelection (objects: objectsToSelect)
       project.windowForSheet?.makeFirstResponder (project.mBoardView)
     }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
