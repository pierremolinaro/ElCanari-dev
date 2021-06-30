//
//  StringArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerBoardLimits
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerBoardLimits : HashableBaseObject {

  //····················································································································

  let boardWidth : Int
  let boardHeight : Int
  let lineWidth : Int

  //····················································································································

  init (boardWidth inBoardWidth : Int, boardHeight inBoardHeight : Int, lineWidth inLineWidth : Int) {
    self.boardWidth = inBoardWidth
    self.boardHeight = inBoardHeight
    self.lineWidth = inLineWidth
    super.init ()
  }

  //····················································································································

  override init () {
    self.boardWidth = 0
    self.boardHeight = 0
    self.lineWidth = 0
    super.init ()
  }

  //····················································································································

//  override var description : String {
//    get {
//      return "MergerBoardLimits " + String (boardWidth) + " " + String (boardHeight) + " " + String (lineWidth)
//    }
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
