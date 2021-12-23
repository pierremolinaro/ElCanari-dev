//
//  document-AutoLayoutProjectDocumentSubClass.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

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
  //  TRACK CREATED BY AN OPTION CLICK
  //····················································································································

  var mTrackCreatedByOptionClick : BoardTrack? = nil

  //····················································································································
  //  Property for dragging symbol in schematics
  //····················································································································

  var mPossibleDraggedSymbol : ComponentSymbolInProject? = nil

  //····················································································································
  //  Property for dragging package in board
  //····················································································································

  var mPossibleDraggedComponent : ComponentInProject? = nil

 //····················································································································

  override func performDragOperation (_ sender : NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    let pasteboard = sender.draggingPasteboard
    var ok = false
    if let documentView = destinationScrollView.documentView, let selectedSheet = self.rootObject.mSelectedSheet {
      let draggingLocationInWindow = sender.draggingLocation
      let draggingLocationInDestinationView = documentView.convert (draggingLocationInWindow, from: nil)
      if let _ = pasteboard.data (forType: kDragAndDropSymbol), let symbol = self.mPossibleDraggedSymbol {
        self.performAddSymbolDragOperation (symbol, draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropComment]) {
        self.performAddCommentDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropWire]) {
        let possibleNewWire = selectedSheet.performAddWireDragOperation (draggingLocationInDestinationView, newNetCreator: self.rootObject.createNetWithAutomaticName)
        if let newWire = possibleNewWire {
          self.schematicObjectsController.setSelection ([newWire])
          self.updateSchematicPointsAndNets ()
          ok = true
        }
      }else if let _ = pasteboard.availableType (from: [kDragAndDropRestrictRectangle]) {
        self.performAddRestrictRectangleDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardText]) {
        self.performAddBoardTextDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardPackage]) {
        self.performAddBoardPackageDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardLine]) {
        self.performAddBoardLineDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardTrack]) {
        self.performAddBoardTrackDragOperation (draggingLocationInDestinationView)
        ok = true
      }
    }
    self.mPossibleDraggedComponent = nil
    return ok
  }

  //····················································································································

  private func performAddSymbolDragOperation (_ inSymbol : ComponentSymbolInProject, _ inDraggingLocationInDestinationView : NSPoint) {
  //--- Fix symbol location
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: milsToCanariUnit (fromInt: 50))
    inSymbol.mCenterX = p.x
    inSymbol.mCenterY = p.y
  //--- Create points in schematics
    let symbolInfo : ComponentSymbolInfo = inSymbol.symbolInfo!
    let symbolPins : [ComponentPinDescriptor] = symbolInfo.pins
    // Swift.print ("\(symbolPins.count) pins")
    for pin in symbolPins {
      // Swift.print ("\(pin.pinIdentifier.symbol.symbolInstanceName) — \(inSymbol.mSymbolInstanceName)")
      if pin.pinIdentifier.symbol.symbolInstanceName == inSymbol.mSymbolInstanceName {
        let point = PointInSchematic (self.ebUndoManager)
        point.mSymbol = inSymbol
        point.mSymbolPinName = pin.pinIdentifier.pinName
        self.rootObject.mSelectedSheet?.mPoints.append (point)
      }
    }
  //--- Enter symbol
    self.rootObject.mSelectedSheet?.mObjects.append (inSymbol)
    self.schematicObjectsController.setSelection ([inSymbol])
    self.windowForSheet?.makeFirstResponder (self.mSchematicsView?.mGraphicView)
  }

  //····················································································································

  private func performAddCommentDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let comment = CommentInSchematic (self.ebUndoManager)
    comment.mX = p.x
    comment.mY = p.y
    self.rootObject.mSelectedSheet?.mObjects.append (comment)
    self.schematicObjectsController.setSelection ([comment])
    self.windowForSheet?.makeFirstResponder (self.mSchematicsView?.mGraphicView)
  }

  //····················································································································

  private func performAddRestrictRectangleDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let restrictRectangle = BoardRestrictRectangle (self.ebUndoManager)
    switch self.rootObject.mBoardSideForNewRestrictRectangle {
    case .frontSide :
      restrictRectangle.mIsInFrontLayer = true
      restrictRectangle.mIsInBackLayer = false
    case .backSide :
      restrictRectangle.mIsInFrontLayer = false
      restrictRectangle.mIsInBackLayer = true
    case .bothSides :
      restrictRectangle.mIsInFrontLayer = true
      restrictRectangle.mIsInBackLayer = true
    }
    restrictRectangle.mX = p.x
    restrictRectangle.mY = p.y
    self.rootObject.mBoardObjects.append (restrictRectangle)
    self.boardObjectsController.setSelection ([restrictRectangle])
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
  }

  //····················································································································

  private func performAddBoardTextDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let boardText = BoardText (self.ebUndoManager)
    boardText.mLayer = self.rootObject.mBoardLayerForNewText
    boardText.mX = p.x
    boardText.mY = p.y
    boardText.mFont = self.rootObject.mFonts.first!
    self.rootObject.mBoardObjects.append (boardText)
    self.boardObjectsController.setSelection ([boardText])
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
  }

  //····················································································································

  private func performAddBoardPackageDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    if let component = self.mPossibleDraggedComponent {
      let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
      component.mX = p.x
      component.mY = p.y
      self.rootObject.mBoardObjects.append (component)
      self.boardObjectsController.setSelection ([component])
      if let padDictionary = component.componentPadDictionary {
        for (padName, descriptor) in padDictionary {
          for idx in 0 ..< descriptor.pads.count {
            let newConnector = BoardConnector (self.ebUndoManager)
            newConnector.mComponent = component
            newConnector.mComponentPadName = padName
            newConnector.mPadIndex = idx
            self.rootObject.mBoardObjects.append (newConnector)
          }
        }
      }
      self.windowForSheet?.makeFirstResponder (self.mBoardView)
    }
  }

  //····················································································································

  private func performAddBoardLineDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let newLine = BoardLine (self.ebUndoManager)
    newLine.mLayer = self.rootObject.mBoardLayerForNewLine
    newLine.mX1 += p.x
    newLine.mY1 += p.y
    newLine.mX2 += p.x
    newLine.mY2 += p.y
    self.rootObject.mBoardObjects.append (newLine)
    self.boardObjectsController.setSelection ([newLine])
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

