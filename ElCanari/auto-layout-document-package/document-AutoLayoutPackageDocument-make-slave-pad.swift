//
//  PackageDocument-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/03/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension AutoLayoutPackageDocument {

  //····················································································································

  func makeSlavePad () -> (PackageSlavePad, NSDictionary) {
     let additionalDictionary = NSMutableDictionary ()
     for object in self.mPackageObjectsController.selectedArray {
       if let masterPad = object as? PackagePad {
         additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.ebObjectIndex
       }
     }
     if additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] == nil {
       for object in self.rootObject.packageObjects {
         if let masterPad = object as? PackagePad {
           additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.ebObjectIndex
         }
       }
     }
    return (PackageSlavePad (nil), additionalDictionary)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
