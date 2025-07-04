//
//  document-AutoLayoutProjectDocumentSubClass.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@objc(AutoLayoutProjectDocumentSubClass) final class AutoLayoutProjectDocumentSubClass : AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
    self.undoManager?.disableUndoRegistration ()
  //--- Add default net class and first sheet
    let netClass = NetClassInProject (self.undoManager)
    self.rootObject.mNetClasses.append (netClass)
    self.rootObject.mDefaultNetClassName = self.rootObject.mNetClasses [0].mNetClassName
    let sheet = SheetInProject (self.undoManager)
    self.rootObject.mSheets.append (sheet)
    self.rootObject.mSelectedSheet = sheet
  //--- Add board limits
    let boardCumulatedWidth = self.rootObject.mBoardClearance + self.rootObject.mBoardLimitsWidth
    // Swift.print (boardCumulatedWidth)
    let boardRight = millimeterToCanariUnit (100.0) - boardCumulatedWidth
    let boardTop = millimeterToCanariUnit (100.0) - boardCumulatedWidth
    let bottom = BorderCurve (self.undoManager)
    bottom.mX = boardCumulatedWidth
    bottom.mY = boardCumulatedWidth
    let right = BorderCurve (self.undoManager)
    right.mX = boardRight
    right.mY = boardCumulatedWidth
    let top = BorderCurve (self.undoManager)
    top.mX = boardRight
    top.mY = boardTop
    let left = BorderCurve (self.undoManager)
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
    self.undoManager?.enableUndoRegistration ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func ebBuildUserInterface () {
    super.ebBuildUserInterface ()
    self.boardObjectsController.set (document: self)
    self.boardObjectsController.mAfterObjectRemovingCallback = { [weak self] in self?.updateBoardConnectors () }
    self.mSchematicsView?.mGraphicView.mMouseDownInterceptor = { [weak self] in
      return self?.schematicMouseDownInterception ($0) ?? false
    }
  //--- Remove unused devices
    self.rootObject.removeUnusedDevices ()
    self.triggerStandAlonePropertyComputationForProject ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Schematic mouse down interception
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func schematicMouseDownInterception (_ inUnalignedPoint : NSPoint) -> Bool {
    var result = false
    if self.rootObject.mSchematicEnableHiliteColumnAndRow {
      let sheetGeometrySelection : EBSelection <SchematicSheetGeometry> = self.rootObject.sheetGeometry_property.selection
      switch sheetGeometrySelection {
      case .empty, .multiple :
        ()
      case .single (let sheetGeometry) :
        switch (sheetGeometry.pointInRowOrColumnHeader (inUnalignedPoint)) {
        case .outsideRowOrColumnHeader :
          ()
        case .inCorner :
          self.rootObject.mSchematicHilitedRowIndex = -1
          self.rootObject.mSchematicHilitedColumnIndex = -1
        case .inRowHeader (let rowIndex) :
          result = true
          if self.rootObject.mSchematicHilitedRowIndex == rowIndex {
            self.rootObject.mSchematicHilitedRowIndex = -1
          }else{
            self.rootObject.mSchematicHilitedRowIndex = rowIndex
          }
        case .inColumHeader (let columnIndex) :
          result = true
          if self.rootObject.mSchematicHilitedColumnIndex == columnIndex {
            self.rootObject.mSchematicHilitedColumnIndex = -1
          }else{
            self.rootObject.mSchematicHilitedColumnIndex = columnIndex
          }
        }
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Property for print operations (schematic and board)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mPrintOperation : NSPrintOperation? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Property for dragging symbol in schematics
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mPossibleDraggedSymbol : ComponentSymbolInProject? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Property for dragging package in board
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mPossibleDraggedComponent : ComponentInProject? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Providing the drag image, called by a source drag table view (CanariDragSourceTableView)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func image (forDragSource inSourceTableView : AutoLayoutCanariDragSourceTableView,
                       forDragRowIndex inDragRow : Int) -> (NSImage, NSPoint) {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    var resultImage = NSImage (named: NSImage.Name ("exclamation"))!
    var resultOffset = NSPoint ()
    if self.mUnplacedSymbolsTableViewArray.contains (inSourceTableView),
      let schematicsView = self.mSchematicsView?.mGraphicView {
    //--- Find symbol to insert in schematics
      let symbolTag = inSourceTableView.tag (atIndex: inDragRow)
      self.mPossibleDraggedSymbol = nil
      for component in self.rootObject.mComponents.values {
        for s in component.mSymbols.values {
           if s.objectIndex == symbolTag {
             self.mPossibleDraggedSymbol = s
           }
        }
      }
      if let symbolInfo = self.mPossibleDraggedSymbol?.symbolInfo {
        let scale : CGFloat = schematicsView.actualScale
        let horizontalFlip : CGFloat = schematicsView.horizontalFlip ? -scale : scale
        let verticalFlip   : CGFloat = schematicsView.verticalFlip   ? -scale : scale
        var af = AffineTransform ()
        af.scale (x: horizontalFlip, y: verticalFlip)
        var symbolShape = EBShape ()
        symbolShape.add (filled: [BézierPath (symbolInfo.filledBezierPath)], preferences_symbolColorForSchematic_property.propval)
        symbolShape.add (stroke: [BézierPath (symbolInfo.strokeBezierPath)], preferences_symbolColorForSchematic_property.propval)
        let scaledSymbolShape = symbolShape.transformed (by: af)
        resultImage = buildPDFimage (frame: scaledSymbolShape.boundingBox, shape: scaledSymbolShape)
      //--- Move image rect origin to mouse click location
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        for pin in symbolInfo.pins {
          let p = pin.pinLocation.cocoaPoint
          minX = min (minX, p.x)
          maxX = max (maxX, p.x)
          minY = min (minY, p.y)
          maxY = max (maxY, p.y)
        }
        let pinCenterX = (minX + maxX) / 2.0
        let pinCenterY = (minY + maxY) / 2.0
        resultOffset.x = symbolShape.boundingBox.midX - pinCenterX
        resultOffset.y = symbolShape.boundingBox.midY - pinCenterY
        resultOffset = af.transform (resultOffset)
      }
    }else if self.mUnplacedPackageTableViewArray.contains (inSourceTableView),
           let boardView = self.mBoardView?.mGraphicView {
      let componentTag = inSourceTableView.tag (atIndex: inDragRow)
      self.mPossibleDraggedComponent = nil
      for component in self.rootObject.mComponents.values {
        if component.objectIndex == componentTag {
          self.mPossibleDraggedComponent = component
        }
      }
      if let component = self.mPossibleDraggedComponent, let packageShape = component.objectDisplay {
        let scale : CGFloat = boardView.actualScale
        let horizontalFlip : CGFloat = boardView.horizontalFlip ? -scale : scale
        let verticalFlip   : CGFloat = boardView.verticalFlip   ? -scale : scale
        var af = AffineTransform ()
        af.scale (x: horizontalFlip, y: verticalFlip)
        let scaledPackageShape = packageShape.transformed (by: af)
        resultImage = buildPDFimage (frame: scaledPackageShape.boundingBox, shape: scaledPackageShape)
      //--- Move image rect origin to mouse click location
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        for padDescriptor in component.componentPadDictionary!.values {
          for pad in padDescriptor.pads {
            let padCenter = pad.location
            minX = min (minX, padCenter.x)
            maxX = max (maxX, padCenter.x)
            minY = min (minY, padCenter.y)
            maxY = max (maxY, padCenter.y)
          }
        }
        let centerX = (minX + maxX) / 2.0
        let centerY = (minY + maxY) / 2.0
        resultOffset.x = packageShape.boundingBox.midX - centerX
        resultOffset.y = packageShape.boundingBox.midY - centerY
        resultOffset = af.transform (resultOffset)
      }
    }
    return (resultImage, resultOffset)
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  override func performDragOperation (_ sender : any NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
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
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardQRCode]) {
        self.performAddBoardQRCodeDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardNonPlatedHole]) {
        self.performAddBoardNonPlatedHoleDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropBoardImage]) {
        self.performAddBoardImageDragOperation (draggingLocationInDestinationView)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
        let point = PointInSchematic (self.undoManager)
        point.mSymbol = inSymbol
        point.mSymbolPinName = pin.pinIdentifier.pinName
        self.rootObject.mSelectedSheet?.mPoints.append (point)
      }
    }
  //--- Enter symbol
    self.rootObject.mSelectedSheet?.mObjects.append (inSymbol)
    self.schematicObjectsController.setSelection ([inSymbol])
    _ = self.windowForSheet?.makeFirstResponder (self.mSchematicsView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddCommentDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let comment = CommentInSchematic (self.undoManager)
    comment.mX = p.x
    comment.mY = p.y
    self.rootObject.mSelectedSheet?.mObjects.append (comment)
    self.schematicObjectsController.setSelection ([comment])
    _ = self.windowForSheet?.makeFirstResponder (self.mSchematicsView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddRestrictRectangleDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let restrictRectangle = BoardRestrictRectangle (self.undoManager)
    let layers = self.rootObject.mNewRestrictRectangleLayers
    restrictRectangle.mIsInFrontLayer  = (layers &  1) != 0
    restrictRectangle.mIsInBackLayer   = (layers &  2) != 0
    restrictRectangle.mIsInInner1Layer = (layers &  4) != 0
    restrictRectangle.mIsInInner2Layer = (layers &  8) != 0
    restrictRectangle.mIsInInner3Layer = (layers & 16) != 0
    restrictRectangle.mIsInInner4Layer = (layers & 32) != 0
    restrictRectangle.mX = p.x
    restrictRectangle.mY = p.y
    let boardGridStep = self.rootObject.mBoardGridStep
    restrictRectangle.mWidth = (restrictRectangle.mWidth / boardGridStep) * boardGridStep
    restrictRectangle.mHeight = (restrictRectangle.mHeight / boardGridStep) * boardGridStep
    self.rootObject.mBoardObjects.append (restrictRectangle)
    self.boardObjectsController.setSelection ([restrictRectangle])
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddBoardTextDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let boardText = BoardText (self.undoManager)
    boardText.mLayer = self.rootObject.mBoardLayerForNewText
    boardText.mX = p.x
    boardText.mY = p.y
    boardText.mFont = self.rootObject.mFonts.first!
    self.rootObject.mBoardObjects.append (boardText)
    self.boardObjectsController.setSelection ([boardText])
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddBoardImageDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let boardImage = BoardImage (self.undoManager)
    boardImage.mLayer = self.rootObject.mBoardLayerForNewImage
    boardImage.mCenterX = p.x
    boardImage.mCenterY = p.y
    let fm = FileManager ()
    if let imagePath = Bundle.main.pathForImageResource (DEFAULT_BOARD_IMAGE),
        let imageData : Data = fm.contents (atPath: imagePath) {
      boardImage.mImageData = imageData
    }
    self.rootObject.mBoardObjects.append (boardImage)
    self.boardObjectsController.setSelection ([boardImage])
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddBoardQRCodeDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let boardQRCode = BoardQRCode (self.undoManager)
    boardQRCode.mLayer = self.rootObject.mBoardLayerForNewQRCode
    boardQRCode.mCenterX = p.x
    boardQRCode.mCenterY = p.y
    self.rootObject.mBoardObjects.append (boardQRCode)
    self.boardObjectsController.setSelection ([boardQRCode])
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddBoardNonPlatedHoleDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let nph = NonPlatedHole (self.undoManager)
    nph.mX = p.x
    nph.mY = p.y
    self.rootObject.mBoardObjects.append (nph)
    self.boardObjectsController.setSelection ([nph])
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
            let newConnector = BoardConnector (self.undoManager)
            newConnector.mComponent = component
            newConnector.mComponentPadName = padName
            newConnector.mPadIndex = idx
            self.rootObject.mBoardObjects.append (newConnector)
          }
        }
      }
      _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAddBoardLineDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGraphicView.mGridStepInCanariUnit)
    let newLine = BoardLine (self.undoManager)
    newLine.mLayer = self.rootObject.mBoardLayerForNewLine
    newLine.mX1 += p.x
    newLine.mY1 += p.y
    newLine.mX2 += p.x
    newLine.mY2 += p.y
    let boardGridStep = self.rootObject.mBoardGridStep
    let boardGridUnit = self.rootObject.mBoardGridStepUnit
    newLine.mX1 = (newLine.mX1 / boardGridStep) * boardGridStep
    newLine.mY1 = (newLine.mY1 / boardGridStep) * boardGridStep
    newLine.mX2 = (newLine.mX2 / boardGridStep) * boardGridStep
    newLine.mY2 = (newLine.mY2 / boardGridStep) * boardGridStep
    newLine.mX1Unit = boardGridUnit
    newLine.mY1Unit = boardGridUnit
    newLine.mX2Unit = boardGridUnit
    newLine.mY2Unit = boardGridUnit
    self.rootObject.mBoardObjects.append (newLine)
    self.boardObjectsController.setSelection ([newLine])
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

