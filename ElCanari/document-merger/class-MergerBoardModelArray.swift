//
//  MergerBoardModelArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerBoardModelArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerBoardModelArray : EBSimpleClass {

  //····················································································································

  let modelNameArray : [String]

  //····················································································································

  init (_ inArray : [String]) {
    modelNameArray = inArray
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerBoardModelArray " + String (modelNameArray.count)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerBoardLimits
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerBoardLimits : EBSimpleClass {

  //····················································································································

  let boardWidth : Int
  let boardHeight : Int
  let lineWidth : Int

  //····················································································································

  init (boardWidth inBoardWidth : Int, boardHeight inBoardHeight : Int, lineWidth inLineWidth : Int) {
    boardWidth = inBoardWidth
    boardHeight = inBoardHeight
    lineWidth = inLineWidth
    super.init ()
  }

  //····················································································································

  override init () {
    boardWidth = 0
    boardHeight = 0
    lineWidth = 0
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerBoardLimits " + String (boardWidth) + " " + String (boardHeight) + " " + String (lineWidth)
    }
  }

  //····················································································································

  func buildShape (dx inDx : Int, dy inDy : Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    let result = CAShapeLayer ()
    if inDisplay && (self.lineWidth > 0) {
      let boardWith = canariUnitToCocoa (self.boardWidth)
      let boardHeight = canariUnitToCocoa (self.boardHeight)
      let lineWidth = canariUnitToCocoa (self.lineWidth)
      let path = CGMutablePath ()
      path.move    (to:CGPoint (x:lineWidth / 2.0,             y:lineWidth / 2.0))
      path.addLine (to:CGPoint (x:lineWidth / 2.0,             y:boardHeight - lineWidth / 2.0))
      path.addLine (to:CGPoint (x:boardWith - lineWidth / 2.0, y:boardHeight - lineWidth / 2.0))
      path.addLine (to:CGPoint (x:boardWith - lineWidth / 2.0, y:lineWidth / 2.0))
      path.addLine (to:CGPoint (x:lineWidth / 2.0,             y:lineWidth / 2.0))
      let shape = CAShapeLayer ()
      shape.path = path
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.strokeColor = inColor.cgColor
      shape.fillColor = nil // NSColor.yellow.cgColor
      shape.lineWidth = lineWidth
      shape.lineCap = kCALineCapSquare
      shape.lineJoin = kCALineJoinMiter
      result.sublayers = [shape]
    }
    result.position = CGPoint (x:canariUnitToCocoa (inDx), y:canariUnitToCocoa (inDy))
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
