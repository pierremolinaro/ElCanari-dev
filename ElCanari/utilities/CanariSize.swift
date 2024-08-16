//
//  CanariSize.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2018.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
//  Struct CanariSize
//--------------------------------------------------------------------------------------------------

struct CanariSize : Equatable, Hashable {
  var width : Int
  var height : Int

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var zero : CanariSize { CanariSize (width: 0, height: 0) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (width inWidth : Int, height inHeight : Int) {
    self.width = inWidth
    self.height = inHeight
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var cocoaSize : NSSize {
    return NSSize (width: canariUnitToCocoa (self.width), height: canariUnitToCocoa (self.height))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
