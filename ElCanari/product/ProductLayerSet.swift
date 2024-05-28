//
//  ProductLayerSet.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct ProductLayerSet : Codable, OptionSet {
  let rawValue : Int

  static let drawBoardLimits               = Self (rawValue: 1 <<  0)
  static let drawInternalBoardLimits       = Self (rawValue: 1 <<  1)
  static let drawComponentNamesTopSide     = Self (rawValue: 1 <<  2)
  static let drawComponentNamesBottomSide  = Self (rawValue: 1 <<  3)
  static let drawComponentValuesTopSide    = Self (rawValue: 1 <<  4)
  static let drawComponentValuesBottomSide = Self (rawValue: 1 <<  5)
  static let drawPackageLegendTopSide      = Self (rawValue: 1 <<  6)
  static let drawPackageLegendBottomSide   = Self (rawValue: 1 <<  7)
  static let drawPadsTopSide               = Self (rawValue: 1 <<  8)
  static let drawPadsBottomSide            = Self (rawValue: 1 <<  9)
  static let drawTextsLayoutTopSide        = Self (rawValue: 1 << 10)
  static let drawTextsLayoutBottomSide     = Self (rawValue: 1 << 11)
  static let drawTextsLegendTopSide        = Self (rawValue: 1 << 12)
  static let drawTextsLegendBottomSide     = Self (rawValue: 1 << 13)
  static let drawTracksTopSide             = Self (rawValue: 1 << 14)
  static let drawTracksInner1Layer         = Self (rawValue: 1 << 15)
  static let drawTracksInner2Layer         = Self (rawValue: 1 << 16)
  static let drawTracksInner3Layer         = Self (rawValue: 1 << 17)
  static let drawTracksInner4Layer         = Self (rawValue: 1 << 18)
  static let drawTracksBottomSide          = Self (rawValue: 1 << 19)
  static let drawTraversingPads            = Self (rawValue: 1 << 20)
  static let drawVias                      = Self (rawValue: 1 << 21)
  static let drawPadHoles                  = Self (rawValue: 1 << 22)
//  static let horizontalMirror              = Self (rawValue: 1 << 22)
}

//--------------------------------------------------------------------------------------------------
