//
//  ProductSize.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct ProductSize : Codable {

  //································································································
  //  Properties
  //································································································

  let width : ProductLength
  let height : ProductLength

  //································································································

  static var zero : ProductSize { ProductSize (width: .zero, height: .zero) }

  //································································································

  init (width inWidth : ProductLength, height inHeight : ProductLength) {
    self.width = inWidth
    self.height = inHeight
  }

  //································································································

  init (canariSize inCanariSize : CanariSize) {
    self.width = ProductLength (valueInCanariUnit: inCanariSize.width)
    self.height = ProductLength (valueInCanariUnit: inCanariSize.height)
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
