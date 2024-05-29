//
//  ProductRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct ProductRect : Codable {

  //································································································
  //  Properties
  //································································································

  let left : ProductLength
  let bottom : ProductLength
  let width : ProductLength
  let height : ProductLength

  //································································································

  static var zero : ProductRect { ProductRect (origin: .zero, size: .zero) }

  //································································································

  init (origin inOrigin : ProductPoint, size inSize : ProductSize) {
    self.left = inOrigin.x
    self.bottom = inOrigin.y
    self.width = inSize.width
    self.height = inSize.height
  }

  //································································································

  init (canariRect inCanariRect : CanariRect) {
    let origin = ProductPoint (canariPoint: inCanariRect.origin)
    self.left = origin.x
    self.bottom = origin.y
    let size = ProductSize (canariSize: inCanariRect.size)
    self.width = size.width
    self.height = size.height
  }

  //································································································

  var cocoaRect : NSRect {
    NSRect (
      x: self.left.value (in: .cocoa),
      y: self.bottom.value (in: .cocoa),
      width: self.width.value (in: .cocoa),
      height: self.height.value (in: .cocoa)
    )
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
