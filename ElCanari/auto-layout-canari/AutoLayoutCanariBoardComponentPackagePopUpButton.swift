//
//  AutoLayoutCanariBoardComponentPackagePopUpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 16/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariBoardComponentPackagePopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariBoardComponentPackagePopUpButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  init () {
    super.init (pullsDown: false, size: .small)
    self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mSelectedObjects : ReadOnlyArrayOf_ComponentInProject? = nil
  private var mObserver : EBOutletEvent? = nil

  //····················································································································

  func register (selectionController inSelectedObjects : ReadOnlyArrayOf_ComponentInProject) {
    self.mSelectedObjects = inSelectedObjects
    let observer = EBOutletEvent ()
    self.mObserver = observer
    observer.mEventCallBack = { [weak self] in self?.buildPopUpButton () }
    inSelectedObjects.addEBObserver (observer)
    inSelectedObjects.addEBObserverOf_selectedPackageName (observer)
    inSelectedObjects.addEBObserverOf_mPackages (observer)
  }

  //····················································································································

  private func buildPopUpButton () {
    self.removeAllItems ()
    var selectedPackageNameSet = Set <String> ()
    if let selectedComponents = self.mSelectedObjects?.propval, selectedComponents.count > 0 {
    //--- Check all selected components have the same available package set
      var referencePackageSet : Set <String>? = nil
      var ok = true
      for component in selectedComponents.values {
        var packageSet = Set <String> ()
        for package in component.mPackages.values {
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
        for package in selectedComponents [0].mPackages.values {
          self.addItem (withTitle: package.mPackageName)
          self.lastItem?.representedObject = package
          self.lastItem?.target = self
          self.lastItem?.action = #selector (Self.changePackageAction (_:))
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
      for component in selectedComponents.values {
        component.set (package: package)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
