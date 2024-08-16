//
//  PackageDocument-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/03/2020.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutPackageDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func makeSlavePad () -> AutoLayoutDragSourceButton.DraggedObjectFactoryDescriptor {
     var additionalDictionary = [String : Any] ()
     for object in self.mPackageObjectsController.selectedArray.values {
       if let masterPad = object as? PackagePad {
         additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.objectIndex
       }
     }
     if additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] == nil {
       for object in self.rootObject.packageObjects.values {
         if let masterPad = object as? PackagePad {
           additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.objectIndex
         }
       }
     }
    return AutoLayoutDragSourceButton.DraggedObjectFactoryDescriptor (PackageSlavePad (nil), optionDictionary: additionalDictionary)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
