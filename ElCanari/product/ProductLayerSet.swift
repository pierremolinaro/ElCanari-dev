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
//--- Component names
  static let frontSideComponentName    = Self (rawValue: 1 <<  2)
  static let backSideComponentName     = Self (rawValue: 1 <<  3)
//--- Component values
  static let frontSideComponentValue   = Self (rawValue: 1 <<  4)
  static let backSideComponentValue    = Self (rawValue: 1 <<  5)
//--- Package Legends
  static let frontSidePackageLegend    = Self (rawValue: 1 <<  6)
  static let backSidePackageLegend     = Self (rawValue: 1 <<  7)
//--- Line Legends
  static let frontSideLegendLine       = Self (rawValue: 1 <<  8)
  static let backSideLegendLine        = Self (rawValue: 1 <<  9)
//--- Texts
  static let frontSideLayoutText       = Self (rawValue: 1 << 10)
  static let backSideLayoutText        = Self (rawValue: 1 << 11)
  static let frontSideLegendText       = Self (rawValue: 1 << 12)
  static let backSideLegendText        = Self (rawValue: 1 << 13)
//--- Tracks
  static let frontSideTrack            = Self (rawValue: 1 << 14)
  static let inner1Track               = Self (rawValue: 1 << 15)
  static let inner2Track               = Self (rawValue: 1 << 16)
  static let inner3Track               = Self (rawValue: 1 << 17)
  static let inner4Track               = Self (rawValue: 1 << 18)
  static let backSideTrack             = Self (rawValue: 1 << 19)
  static let frontSideExposedTrack     = Self (rawValue: 1 << 20)
  static let backSideExposedTrack      = Self (rawValue: 1 << 21)
//--- Vias
  static let viaPad                    = Self (rawValue: 1 << 22)
//--- Holes
  static let hole                      = Self (rawValue: 1 << 23)
//--- Component Pad
  static let frontSideComponentPad     = Self (rawValue: 1 << 24)
  static let backSideComponentPad      = Self (rawValue: 1 << 25)
  static let innerComponentPad         = Self (rawValue: 1 << 26)
//--- Images
  static let frontSideImage            = Self (rawValue: 1 << 27)
  static let backSideImage             = Self (rawValue: 1 << 28)
//--- QR Codes
  static let frontSideQRCode           = Self (rawValue: 1 << 29)
  static let backSideQRCode            = Self (rawValue: 1 << 30)
}

//--------------------------------------------------------------------------------------------------
