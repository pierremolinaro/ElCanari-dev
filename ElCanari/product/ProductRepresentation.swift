//
//  ProductRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct ProductRepresentation : Codable {

  //································································································
  //  Properties
  //································································································

  private (set) var boardWidth : Double
  private (set) var boardHeight : Double

  //································································································
  //  Init
  //································································································

  init (boardWidth inBoardWidth : Double, boardHeight inBoardHeight : Double) {
    self.boardWidth = inBoardWidth
    self.boardHeight = inBoardHeight
  }

  //································································································
  //  Decoding from JSON
  //································································································

  init? (fromJSONData inData : Data) {
    let decoder = JSONDecoder()
    if let product = try? decoder.decode (Self.self, from: inData) {
      self = product
    }else{
      return nil
    }
  }

  //································································································
  //  Encoding to JSON
  //································································································

  func jsonData () -> Data? {
    let encoder = JSONEncoder ()
    encoder.outputFormatting = [.sortedKeys]
    let data = try? encoder.encode (self)
    return data
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
