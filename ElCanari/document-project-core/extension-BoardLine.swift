//
//  extension-BoardLine.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_LINE_P1  = 0
let BOARD_LINE_P2  = 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardLine
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardLine {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx : Int, yBy inDy : Int, userSet ioSet : OCObjectSet) {
    self.mX1 += inDx
    self.mY1 += inDy
    self.mX2 += inDx
    self.mY2 += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    if inKnobIndex == BOARD_LINE_P1 {
      return OCCanariPoint (x: inDx, y: inDy)
    }else if inKnobIndex == BOARD_LINE_P2 {
      return OCCanariPoint (x: inDx, y: inDy)
    }else{
      return OCCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == BOARD_LINE_P1 {
      self.mX1 += inDx
      self.mY1 += inDy
    }else if inKnobIndex == BOARD_LINE_P2 {
      self.mX2 += inDx
      self.mY2 += inDy
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var isAligned = self.mX1.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY1.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mX2.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mY2.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.mX1.align (onGrid: inGrid)
    self.mY1.align (onGrid: inGrid)
    self.mX2.align (onGrid: inGrid)
    self.mY2.align (onGrid: inGrid)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
