//
//  legacy-artwork.swift
//  canari
//
//  Created by Pierre Molinaro on 09/07/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let ARTWORK_LEGACY_ENTITY_NAME_DICTIONARY : [String : String] = [ // used in import-legacy-document.swift
  "ArtworkFileGenerationParameters" : "ArtworkFileGenerationParameters",
  "ArtworkRootEntity" : "ArtworkRootEntity",
  "ExcellonDrillDataWithSeparateToolListFileEntity" : "", // Empty string : no entity in El Canari Document
  "ExcellonDrillDataEntity" : ""
]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


extension ArtworkRootEntity {

  //····················································································································

  override func additionalSetUpOnLegacyImport (_ objectPropertyDictionary : NSDictionary,
                                               _ legacyImportContext : LegacyImportContext) throws {
//    NSLog ("\(self.className).\(#function)")
//    NSLog ("objectPropertyDictionary \(objectPropertyDictionary.count)")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


extension ArtworkFileGenerationParameters {

  //····················································································································

  override func additionalSetUpOnLegacyImport (_ objectPropertyDictionary : NSDictionary,
                                               _ legacyImportContext : LegacyImportContext) throws {
    // NSLog ("\(#function)")
    // NSLog ("objectPropertyDictionary \(objectPropertyDictionary)")

    drawComponentNamesTopSide.setProp ((objectPropertyDictionary ["drawComponentNames"] as! NSNumber).boolValue)
    drawComponentNamesBottomSide.setProp ((objectPropertyDictionary ["drawComponentNamesSolderSide"] as! NSNumber).boolValue)

    drawComponentValuesTopSide.setProp ((objectPropertyDictionary ["drawComponentValues"] as! NSNumber).boolValue)
    drawComponentValuesBottomSide.setProp ((objectPropertyDictionary ["drawComponentValuesSolderSide"] as! NSNumber).boolValue)

    drawPackageLegendTopSide.setProp ((objectPropertyDictionary ["drawPackageLegends"] as! NSNumber).boolValue)
    drawPackageLegendBottomSide.setProp ((objectPropertyDictionary ["drawPackageLegendsSolderSide"] as! NSNumber).boolValue)

    drawPadsTopSide.setProp ((objectPropertyDictionary ["drawPadsComponentSide"] as! NSNumber).boolValue)
    drawPadsBottomSide.setProp ((objectPropertyDictionary ["drawPadsSolderSide"] as! NSNumber).boolValue)

    drawTextsLayoutTopSide.setProp ((objectPropertyDictionary ["drawTextsLayoutComponentSide"] as! NSNumber).boolValue)
    drawTextsLayoutBottomSide.setProp ((objectPropertyDictionary ["drawTextsLayoutSolderSide"] as! NSNumber).boolValue)

    drawTextsLegendTopSide.setProp ((objectPropertyDictionary ["drawTextsLegendComponentSide"] as! NSNumber).boolValue)
    drawTextsLegendBottomSide.setProp ((objectPropertyDictionary ["drawTextsLegendSolderSide"] as! NSNumber).boolValue)

    drawTracksTopSide.setProp ((objectPropertyDictionary ["drawTracksComponentSide"] as! NSNumber).boolValue)
    drawTracksBottomSide.setProp ((objectPropertyDictionary ["drawTracksSolderSide"] as! NSNumber).boolValue)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

