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

  static let boardLimits               = Self (rawValue: 1 <<  0)
  static let internalBoardLimits       = Self (rawValue: 1 <<  1)
  static let componentNamesTopSide     = Self (rawValue: 1 <<  2)
  static let componentNamesBottomSide  = Self (rawValue: 1 <<  3)
  static let componentValuesTopSide    = Self (rawValue: 1 <<  4)
  static let componentValuesBottomSide = Self (rawValue: 1 <<  5)
  static let packageLegendTopSide      = Self (rawValue: 1 <<  6)
  static let packageLegendBottomSide   = Self (rawValue: 1 <<  7)
  static let padsTopSide               = Self (rawValue: 1 <<  8)
  static let padsBottomSide            = Self (rawValue: 1 <<  9)
  static let textsLayoutTopSide        = Self (rawValue: 1 << 10)
  static let textsLayoutBottomSide     = Self (rawValue: 1 << 11)
  static let textsLegendTopSide        = Self (rawValue: 1 << 12)
  static let textsLegendBottomSide     = Self (rawValue: 1 << 13)
  static let tracksTopSide             = Self (rawValue: 1 << 14)
  static let tracksInner1Layer         = Self (rawValue: 1 << 15)
  static let tracksInner2Layer         = Self (rawValue: 1 << 16)
  static let tracksInner3Layer         = Self (rawValue: 1 << 17)
  static let tracksInner4Layer         = Self (rawValue: 1 << 18)
  static let tracksBottomSide          = Self (rawValue: 1 << 19)
  static let traversingPads            = Self (rawValue: 1 << 20)
  static let vias                      = Self (rawValue: 1 << 21)
  static let padHoles                  = Self (rawValue: 1 << 22)
}

//--------------------------------------------------------------------------------------------------
