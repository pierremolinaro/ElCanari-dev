//
//  CanariBoardComponentPackagePopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 1/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariBoardComponentPackagePopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardComponentPackagePopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mSelectedObjects : ReadOnlyArrayOf_ComponentInProject? = nil
  private var mObserver : EBOutletEvent? = nil

  //····················································································································

  func register (selectionController inSelectedObjects : ReadOnlyArrayOf_ComponentInProject) {
    self.mSelectedObjects = inSelectedObjects
    let observer = EBOutletEvent ()
    self.mObserver = observer
    observer.mEventCallBack = { self.buildPopUpButton () }
    inSelectedObjects.addEBObserver (observer)
    inSelectedObjects.addEBObserverOf_selectedPackageName (observer)
    inSelectedObjects.addEBObserverOf_mPackages (observer)
  }

  //····················································································································

  func unregister () {
    if let observer = self.mObserver {
      observer.mEventCallBack = nil
      self.mSelectedObjects?.removeEBObserver (observer)
      self.mSelectedObjects?.removeEBObserverOf_selectedPackageName (observer)
      self.mSelectedObjects?.removeEBObserverOf_mPackages (observer)
      self.mObserver = nil
    }
    self.mSelectedObjects = nil
  }

  //····················································································································

  private func buildPopUpButton () {
    self.removeAllItems ()
    var packageNameNameSet = Set <String> ()
    if let selectedComponents = self.mSelectedObjects?.propval, selectedComponents.count == 1 {
      let component = selectedComponents [0]
      if let packageNameName = component.selectedPackageName {
        packageNameNameSet.insert (packageNameName)
      }
    //---
      for package in component.mPackages {
        self.addItem (withTitle: package.mPackageName)
        self.lastItem?.representedObject = package
        self.lastItem?.target = self
        self.lastItem?.action = #selector (CanariBoardComponentPackagePopUpButton.changePackageAction (_:))
        self.lastItem?.isEnabled = true
        if packageNameNameSet.contains (package.mPackageName) {
          self.select (self.lastItem)
        }else{
          let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize),
            NSAttributedString.Key.obliqueness : 0.2
          ]
          let attributedString = NSAttributedString (string: package.mPackageName, attributes: attributes)
          self.lastItem?.attributedTitle = attributedString
        }
      }
    }
  }

  //····················································································································

  @objc private func changePackageAction (_ inSender : NSMenuItem) {
    if let selectedComponents = self.mSelectedObjects?.propval, let package = inSender.representedObject as? DevicePackageInProject {
      for component in selectedComponents {
        component.mSelectedPackage = package
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
