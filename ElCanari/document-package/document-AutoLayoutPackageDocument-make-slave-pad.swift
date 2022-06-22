//
//  PackageDocument-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/03/2020.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutPackageDocument {

  //····················································································································

  func makeSlavePad () -> (PackageSlavePad, NSDictionary, [EBManagedObject]) {
     let additionalDictionary = NSMutableDictionary ()
     for object in self.mPackageObjectsController.selectedArray.values {
       if let masterPad = object as? PackagePad {
         additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.objectIdentifier
       }
     }
     if additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] == nil {
       for object in self.rootObject.packageObjects.values {
         if let masterPad = object as? PackagePad {
           additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.objectIdentifier
         }
       }
     }
    return (PackageSlavePad (nil), additionalDictionary, [])
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
