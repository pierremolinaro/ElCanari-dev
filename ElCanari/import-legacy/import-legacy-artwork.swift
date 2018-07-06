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


extension ArtworkRoot {

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

    drawComponentNamesTopSide = (objectPropertyDictionary ["drawComponentNames"] as! NSNumber).boolValue
    drawComponentNamesBottomSide = ((objectPropertyDictionary ["drawComponentNamesSolderSide"] as! NSNumber).boolValue)

    drawComponentValuesTopSide = ((objectPropertyDictionary ["drawComponentValues"] as! NSNumber).boolValue)
    drawComponentValuesBottomSide = ((objectPropertyDictionary ["drawComponentValuesSolderSide"] as! NSNumber).boolValue)

    drawPackageLegendTopSide = ((objectPropertyDictionary ["drawPackageLegends"] as! NSNumber).boolValue)
    drawPackageLegendBottomSide = ((objectPropertyDictionary ["drawPackageLegendsSolderSide"] as! NSNumber).boolValue)

    drawPadsTopSide = ((objectPropertyDictionary ["drawPadsComponentSide"] as! NSNumber).boolValue)
    drawPadsBottomSide = ((objectPropertyDictionary ["drawPadsSolderSide"] as! NSNumber).boolValue)

    drawTextsLayoutTopSide = ((objectPropertyDictionary ["drawTextsLayoutComponentSide"] as! NSNumber).boolValue)
    drawTextsLayoutBottomSide = ((objectPropertyDictionary ["drawTextsLayoutSolderSide"] as! NSNumber).boolValue)

    drawTextsLegendTopSide = ((objectPropertyDictionary ["drawTextsLegendComponentSide"] as! NSNumber).boolValue)
    drawTextsLegendBottomSide = ((objectPropertyDictionary ["drawTextsLegendSolderSide"] as! NSNumber).boolValue)

    drawTracksTopSide = ((objectPropertyDictionary ["drawTracksComponentSide"] as! NSNumber).boolValue)
    drawTracksBottomSide = ((objectPropertyDictionary ["drawTracksSolderSide"] as! NSNumber).boolValue)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

