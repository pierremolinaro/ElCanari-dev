//
//  CanariLength+extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/09/2026.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension CanariLength {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func isAligned (on inGrid : Int) -> Bool {
    return self.isAligned (.cu (inGrid))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func aligning (on inGrid : Int) -> CanariLength {
    return self.aligning (to: .cu (inGrid))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func aligning (on inGrid : CanariLength) -> CanariLength {
    return self.aligning (to: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func align (on inGrid : Int) {
    self = self.aligning (to: .cu (inGrid))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
