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

  init (cocoaSize inSize : NSSize) {
    self.width = ProductLength (inSize.width, .cocoa)
    self.height = ProductLength (inSize.height, .cocoa)
  }

  //································································································

  var cocoaSize : NSSize {
    NSSize (width: self.width.value (in: .cocoa), height: self.height.value (in: .cocoa))
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
