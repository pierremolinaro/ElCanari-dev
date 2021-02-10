//
//  CanariBoardComponentPackagePopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 1/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariBoardComponentPackagePopUpButton
//----------------------------------------------------------------------------------------------------------------------

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
    var selectedPackageNameSet = Set <String> ()
    if let selectedComponents = self.mSelectedObjects?.propval, selectedComponents.count > 0 {
    //--- Check all selected components have the same available package set
      var referencePackageSet : Set <String>? = nil
      var ok = true
      for component in selectedComponents {
        var packageSet = Set <String> ()
        for package in component.mPackages {
          packageSet.insert (package.mPackageName)
        }
        if let ps = referencePackageSet, ok {
          ok = ps == packageSet
        }else{
          referencePackageSet = packageSet
        }
        if let packageNameName = component.selectedPackageName {
          selectedPackageNameSet.insert (packageNameName)
        }
      }
    //---
      if ok {
        let attributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize),
          NSAttributedString.Key.obliqueness : 0.2
        ]
        for package in selectedComponents [0].mPackages {
          self.addItem (withTitle: package.mPackageName)
          self.lastItem?.representedObject = package
          self.lastItem?.target = self
          self.lastItem?.action = #selector (CanariBoardComponentPackagePopUpButton.changePackageAction (_:))
          self.lastItem?.isEnabled = true
          if selectedPackageNameSet.contains (package.mPackageName) {
            self.select (self.lastItem)
         }else{
            let attributedString = NSAttributedString (string: package.mPackageName, attributes: attributes)
            self.lastItem?.attributedTitle = attributedString
          }
        }
      }
    }
  }

  //····················································································································

  @objc private func changePackageAction (_ inSender : NSMenuItem) {
    if let selectedComponents = self.mSelectedObjects?.propval, let package = inSender.representedObject as? DevicePackageInProject {
      for component in selectedComponents {
        component.set (package: package)
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
