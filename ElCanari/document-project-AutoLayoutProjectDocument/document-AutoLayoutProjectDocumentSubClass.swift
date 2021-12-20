//
//  document-AutoLayoutProjectDocumentSubClass.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PAPER_A4_MAX_SIZE_COCOA_UNIT   : CGFloat = 842.0
let PAPER_A4_MIN_SIZE_COCOA_UNIT   : CGFloat = 595.0
let PAPER_LEFT_MARGIN_COCOA_UNIT   : CGFloat =  72.0
let PAPER_RIGHT_MARGIN_COCOA_UNIT  : CGFloat =  72.0
let PAPER_TOP_MARGIN_COCOA_UNIT    : CGFloat =  72.0
let PAPER_BOTTOM_MARGIN_COCOA_UNIT : CGFloat =  72.0
let PAPER_GUTTER_WIDTH_COCOA_UNIT  : CGFloat =  13.0
let PAPER_GUTTER_HEIGHT_COCOA_UNIT : CGFloat =  13.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(AutoLayoutProjectDocumentSubClass) final class AutoLayoutProjectDocumentSubClass : AutoLayoutProjectDocument {

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()
    self.ebUndoManager.disableUndoRegistration ()
  //--- Add default net class and first sheet
    let netClass = NetClassInProject (self.ebUndoManager)
    self.rootObject.mNetClasses.append (netClass)
    self.rootObject.mDefaultNetClassName = self.rootObject.mNetClasses [0].mNetClassName
    let sheet = SheetInProject (self.ebUndoManager)
    self.rootObject.mSheets.append (sheet)
    self.rootObject.mSelectedSheet = sheet
  //--- Add board limits
    let boardCumulatedWidth = self.rootObject.mBoardClearance + self.rootObject.mBoardLimitsWidth
    // Swift.print (boardCumulatedWidth)
    let boardRight = millimeterToCanariUnit (100.0) - boardCumulatedWidth
    let boardTop = millimeterToCanariUnit (100.0) - boardCumulatedWidth
    let bottom = BorderCurve (self.ebUndoManager)
    bottom.mX = boardCumulatedWidth
    bottom.mY = boardCumulatedWidth
    let right = BorderCurve (self.ebUndoManager)
    right.mX = boardRight
    right.mY = boardCumulatedWidth
    let top = BorderCurve (self.ebUndoManager)
    top.mX = boardRight
    top.mY = boardTop
    let left = BorderCurve (self.ebUndoManager)
    left.mX = boardCumulatedWidth
    left.mY = boardTop
    bottom.mNext = right
    right.mNext = top
    top.mNext = left
    left.mNext = bottom
    self.rootObject.mBorderCurves = EBReferenceArray ([bottom, right, top, left])
    left.setControlPointsDefaultValuesForLine ()
    right.setControlPointsDefaultValuesForLine ()
    bottom.setControlPointsDefaultValuesForLine ()
    top.setControlPointsDefaultValuesForLine ()
  //---
    self.ebUndoManager.enableUndoRegistration ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

