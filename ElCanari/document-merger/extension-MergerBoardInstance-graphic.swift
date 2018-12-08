//
//  extension-MergerBoardInstance-graphic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION MergerBoardInstance
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerBoardInstance {

  //····················································································································

  override func acceptedXTranslation (by inDx : Int) -> Int {
    var acceptedTranslation = inDx
    let newX = self.x + acceptedTranslation
    if newX < 0 {
      acceptedTranslation = -self.x
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptedYTranslation (by inDy : Int) -> Int {
    var acceptedTranslation = inDy
    let newY = self.y + acceptedTranslation
    if newY < 0 {
      acceptedTranslation = -self.y
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX = self.x + inDx
    let newY = self.y + inDy
    return (newX >= 0) && (newY >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    self.x += inDx
    self.y += inDy
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
