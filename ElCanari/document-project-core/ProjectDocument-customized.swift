//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let kDragAndDropSymbol = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.symbol")
fileprivate let kDragAndDropComment = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.comment")
fileprivate let kDragAndDropWire = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.wire")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let kDragAndDropRestrictRectangle = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.restrict.rectangle")
fileprivate let kDragAndDropBoardText = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.text")
fileprivate let kDragAndDropBoardPackage = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.package")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedProjectDocument) class CustomizedProjectDocument : ProjectDocument {

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()
    self.ebUndoManager.disableUndoRegistration ()
  //--- Add default net class and first sheet
    let netClass = NetClassInProject (self.ebUndoManager)
    self.rootObject.mNetClasses.append (netClass)
    let sheet = SheetInProject (self.ebUndoManager)
    self.rootObject.mSheets.append (sheet)
    self.rootObject.mSelectedSheet = sheet
  //--- Add board limits
    let boardWidth = millimeterToCanariUnit (100.0)
    let boardHeight = millimeterToCanariUnit (100.0)
    let bottom = BorderCurve (self.ebUndoManager)
    bottom.mX = 0
    bottom.mY = 0
    let right = BorderCurve (self.ebUndoManager)
    right.mX = boardWidth
    right.mY = 0
    let top = BorderCurve (self.ebUndoManager)
    top.mX = boardWidth
    top.mY = boardHeight
    let left = BorderCurve (self.ebUndoManager)
    left.mX = 0
    left.mY = boardHeight
    bottom.mNext = right
    right.mNext = top
    top.mNext = left
    left.mNext = bottom
    self.rootObject.mBorderCurves = [bottom, right, top, left]
    left.setControlPointsDefaultValuesForLine ()
    right.setControlPointsDefaultValuesForLine ()
    bottom.setControlPointsDefaultValuesForLine ()
    top.setControlPointsDefaultValuesForLine ()
  //---
    self.ebUndoManager.enableUndoRegistration ()
  }

  //····················································································································
  //  WIRE CREATED BY AN OPTION CLICK
  //····················································································································

  internal var mWireCreatedByOptionClick : WireInSchematic? = nil

  //····················································································································
  //  POP UP BUTTON CONTROLLERS FOR SELECTING NET CLASS
  //····················································································································

  private var mSelectedWireNetClassPopUpController = EBPopUpButtonControllerForNetClassFromSelectedWires ()
  private var mSelectedLabelNetClassPopUpController = EBPopUpButtonControllerForNetClassFromSelectedLabels ()

  //····················································································································
  //  Property needed for handling "symbol count" to insert in segmented control title
  //····················································································································

  fileprivate var mSymbolCountToInsertController : EBSimpleController? = nil
  private var mSheetController = ProjectSheetController ()
  internal var mPrintOperation : NSPrintOperation? = nil

  //····················································································································
  //  Property needed for handling "package count" to insert in segmented control title
  //····················································································································

  fileprivate var mPackageCountToInsertController : EBSimpleController? = nil

  //····················································································································
  //  Properties needed for renaming a component
  //····················································································································

  internal var mComponentCurrentPrefix = ""
  internal var mComponentCurrentIndex = 0
  internal var mComponentNewPrefix = ""
  internal var mComponentNewIndex = 0
  internal weak var mSelectedComponentForRenaming : ComponentInProject? = nil

  //····················································································································
  //  Property for dragging symbol in schematics
  //····················································································································

  internal var mPossibleDraggedSymbol : ComponentSymbolInProject? = nil

  //····················································································································
  //  Property for dragging package in board
  //····················································································································

  internal var mPossibleDraggedComponent : ComponentInProject? = nil

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Register board limits inspector views
    self.boardCurveObjectsController.register (inspectorReceivingView: self.mSelectedObjectsBoardLimitsInspectorView)
    self.boardCurveObjectsController.register (inspectorView: self.mSelectedBoardLimitInspectorView, for: BorderCurve.self)
  //--- Option click for creating wire
     self.mSchematicsView?.setOptionMouseCallbacks (
       start: { [weak self] (inUnalignedMouseLocation) in self?.startWireCreationOnOptionMouseDown (at: inUnalignedMouseLocation) },
       continue: { [weak self] (inUnalignedMouseLocation) in self?.continueWireCreationOnOptionMouseDragged (at: inUnalignedMouseLocation) },
       abort: { [weak self] in self?.abortWireCreationOnOptionMouseUp () },
       stop: { [weak self] (inUnalignedMouseLocation) in self?.stopWireCreationOnOptionMouseUp (at: inUnalignedMouseLocation) }
     )
  //--- Pop up button controllers
    self.mSelectedWireNetClassPopUpController.bind_model (
      self.rootObject.mNetClasses_property,
      self.wireInSchematicSelectionController
    )
    self.mSelectedWireNetClassPopUpController.attachPopUpButton (self.mSchematicWireNetClassButton)
    self.mSelectedLabelNetClassPopUpController.bind_model (
      self.rootObject.mNetClasses_property,
      self.schematicLabelSelectionController
    )
    self.mSelectedLabelNetClassPopUpController.attachPopUpButton (self.mSchematicLabelNetClassButton)
  //--- Set pages segmented control
    let pages = [
      self.mComponentsPageView,
      self.mLibraryPageView,
      self.mSchematicsPageView,
      self.mNetClassesPageView ,
      self.mNetListPageView,
      self.mBoardBorderPageView,
      self.mBoardObjectsPageView,
      self.mProductPageView
    ]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set document to scroll view for enabling drag and drop for schematics symbols
    self.mBoardScrollView?.register (document: self, draggedTypes: [kDragAndDropRestrictRectangle, kDragAndDropBoardText, kDragAndDropBoardPackage])
  //--- Set Board inspector segmented control
    let boardInspectors = [
      self.mSelectedObjectsBoardInspectorView,
      self.mUnplacedPackagesBoardInspectorView,
      self.mGridZoomBoardInspectorView,
      self.mDisplayBoardInspectorView,
      self.mRouterBoardInspectorView,
      self.mERCBoardInspectorView
    ]
    self.mBoardInspectorSegmentedControl?.register (masterView: self.mBaseBoardInspectorView, boardInspectors)
  //---
    self.mUnplacedPackageTableView?.register (document: self, draggedType: kDragAndDropBoardPackage)
    self.mPackageCountToInsertController = EBSimpleController (
      observedObjects: [self.unplacedSymbolsCount_property],
      callBack: {
        let title : String
        switch self.unplacedPackageCount_property_selection {
        case .empty, .multiple :
          title = "—"
        case .single (let v) :
          title = "+ \(v)"
        }
        self.mBoardInspectorSegmentedControl?.setLabel (title, forSegment: 1)
      }
    )
  //--- Register Board inspector views
    self.boardObjectsController.register (inspectorReceivingView: self.mSelectedObjectsBoardInspectorView)
    self.boardObjectsController.register (inspectorView: self.mRestrictRectangleInspectorView, for: BoardRestrictRectangle.self)
    self.boardObjectsController.register (inspectorView: self.mBoardTextInspectorView, for: BoardText.self)
  //--- Set Board limits inspector segmented control
    let boardLimitsInspectors = [
      self.mSelectedObjectsBoardLimitsInspectorView,
      self.mGridZoomBoardLimitsInspectorView,
      self.mOperationBoardLimitsInspectorView
    ]
    self.mBoardLimitsInspectorSegmentedControl?.register (masterView: self.mBaseBoardLimitsInspectorView, boardLimitsInspectors)
    self.mBoardLimitsView?.mPopulateContextualMenuClosure = self.populateContextualClickOnBoardLimits
  //--- Set schematics inspector segmented control
    let schematicsInspectors = [
      self.mSelectedObjectsSchematicsInspectorView,
      self.mHotKeysSchematicInspectorView,
      self.mUnplacedSymbolsSchematicsInspectorView,
      self.mGridZoomSchematicsInspectorView,
      self.mSchematicsSheetsInspectorView
    ]
    self.mSchematicsInspectorSegmentedControl?.register (masterView: self.mBaseSchematicsInspectorView, schematicsInspectors)
  //--- Register schematics inspector views
    self.schematicObjectsController.register (inspectorReceivingView: self.mSelectedObjectsSchematicsInspectorView)
    self.schematicObjectsController.register (inspectorView: self.mComponentSymbolInspectorView, for: ComponentSymbolInProject.self)
    self.schematicObjectsController.register (inspectorView: self.mCommentInSchematicsInspectorView, for: CommentInSchematic.self)
    self.schematicObjectsController.register (inspectorView: self.mNCInSchematicsInspectorView, for: NCInSchematic.self)
    self.schematicObjectsController.register (inspectorView: self.mSchematicsLabelInspectorView, for: LabelInSchematic.self)
    self.schematicObjectsController.register (inspectorView: self.mSchematicsWireInspectorView, for: WireInSchematic.self)
  //---
    self.mNewComponentFromDevicePullDownButton?.register (document: self)
  //---
    self.mSymbolCountToInsertController = EBSimpleController (
      observedObjects: [self.unplacedSymbolsCount_property],
      callBack: {
        let title : String
        switch self.unplacedSymbolsCount_property_selection {
        case .empty, .multiple :
          title = "—"
        case .single (let v) :
          title = "+ \(v)"
        }
        self.mSchematicsInspectorSegmentedControl?.setLabel (title, forSegment: 2)
      }
    )
  //---
    self.mSheetController.register (
      document: self,
      popup: self.mSheetPopUpButton,
      sheetUp: self.mSheetUpButton,
      sheetDown: self.mSheetDownButton
    )
  //---
    self.mSchematicsView?.mGridStepInCanariUnit = SCHEMATIC_GRID_IN_CANARI_UNIT
    self.mSchematicsView?.set (mouseGridInCanariUnit: SCHEMATIC_GRID_IN_CANARI_UNIT)
    self.mSchematicsView?.set (arrowKeyMagnitude : SCHEMATIC_GRID_IN_CANARI_UNIT)
    self.mSchematicsView?.set (shiftArrowKeyMagnitude : SCHEMATIC_GRID_IN_CANARI_UNIT * 4)
    self.mSchematicsView?.mPopulateContextualMenuClosure = self.populateContextualClickOnSchematics
  //--- Set document to scroll view for enabling drag and drop for schematics symbols
    self.mSchematicsScrollView?.register (document: self, draggedTypes: [kDragAndDropSymbol, kDragAndDropComment, kDragAndDropWire])
    self.mUnplacedSymbolsTableView?.register (document: self, draggedType: kDragAndDropSymbol)
  //--- Drag source buttons and destination scroll view
    self.mAddCommentButton?.register (
      draggedType: kDragAndDropComment,
      draggedObjectFactory: { return CommentInSchematic (nil) },
      scaleProvider: self.mSchematicsView
    )
    self.mAddWireButton?.register (
      draggedType: kDragAndDropWire,
      draggedObjectFactory: { return WireInSchematic (nil) },
      scaleProvider: self.mSchematicsView
    )
  //---
    self.mAddRestrictRectangleButton?.register (
      draggedType: kDragAndDropRestrictRectangle,
      draggedObjectFactory: { return BoardRestrictRectangle (nil) },
      scaleProvider: self.mBoardView
    )
    self.mAddTextInBoardButton?.register (
      draggedType: kDragAndDropBoardText,
      shapeFactory: { [weak self] in return self?.boardTextImageFactory () },
      scaleProvider: self.mBoardView
    )
  //---
    self.schematicObjectsController.mAfterObjectRemovingCallback = self.updateSchematicsPointsAndNets
    self.mSchematicsView?.setMouseMovedCallback { [weak self] (mouseLocation) in self?.mouseMovedInSchematic (mouseLocation) }
    self.mSchematicsView?.setMouseExitCallback { [weak self] in self?.mouseExitInSchematic () }
    self.mouseExitInSchematic ()
    self.mSchematicsView?.setKeyDownCallback { [weak self] (mouseLocation, key) in self?.keyDownInSchematic (mouseLocation, key) }
  //---
    self.mBoardTextFontPopUpButton?.register (
      fontsModel: self.rootObject.mFonts_property,
      selectionController: self.boardTextSelectionController.selectedArray_property
    )
  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

  override func removeUserInterface () {
    self.mSymbolCountToInsertController?.unregister ()
    self.mSymbolCountToInsertController = nil
    self.mSheetController.unregister ()
    self.mPackageCountToInsertController?.unregister ()
    self.mPackageCountToInsertController = nil
    self.mSchematicsView?.mPopulateContextualMenuClosure = nil // Required for breaking strong reference cycle
    self.mBoardLimitsView?.mPopulateContextualMenuClosure = nil // Required for breaking strong reference cycle
    self.schematicObjectsController.mAfterObjectRemovingCallback = nil // Required for breaking strong reference cycle
  //--- Pop up button controllers
    self.mSelectedWireNetClassPopUpController.unbind_model ()
    self.mSelectedWireNetClassPopUpController.attachPopUpButton (nil)
    self.mSelectedLabelNetClassPopUpController.unbind_model ()
    self.mSelectedLabelNetClassPopUpController.attachPopUpButton (nil)
    self.mBoardTextFontPopUpButton?.unregister ()
    self.mBoardTextFontPopUpButton = nil
  //---
    super.removeUserInterface ()
  }

  //····················································································································
  //    Update points and net
  //····················································································································

  internal func updateSchematicsPointsAndNets () {
    var errorList = [String] ()
    self.rootObject.mSelectedSheet?.removeUnusedSchematicsPoints (&errorList)
    self.removeUnusedWires (&errorList)
    self.removeUnusedNets ()
    if errorList.count > 0,
       let dialog = self.mInconsistentSchematicErrorPanel,
       let window = self.windowForSheet {
      let message = errorList.joined (separator: "\n")
      self.mInconsistentSchematicErrorTextView?.string = message
      window.beginSheet (dialog) { (inModalResponse) in }
    }
  }

  //····················································································································
  //    Drag and drop destination
  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    return .copy
  }

  //····················································································································

  override func prepareForDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    return true
  }

  //····················································································································
  // Providing the drag image, called by a source drag table view (CanariDragSourceTableView)
  //····················································································································

  override func dragImageForRows (source inSourceTableView : CanariDragSourceTableView,
                                  with dragRows: IndexSet,
                                  tableColumns: [NSTableColumn],
                                  event dragEvent: NSEvent,
                                  offset dragImageOffset: NSPointPointer) -> NSImage {
    var result = NSImage (named: NSImage.Name ("exclamation"))!
    if inSourceTableView == self.mUnplacedSymbolsTableView,
      let schematicsView = self.mSchematicsView,
      dragRows.count == 1,
      let idx = dragRows.first {
    //--- Find symbol to insert in schematics
      let symbolTag = inSourceTableView.tag (atIndex: idx)
      self.mPossibleDraggedSymbol = nil
      for component in self.rootObject.mComponents {
        for s in component.mSymbols {
           if s.ebObjectIndex == symbolTag {
             self.mPossibleDraggedSymbol = s
           }
        }
      }
      if let symbol = self.mPossibleDraggedSymbol,
         let strokeBP = symbol.symbolInfo?.strokeBezierPath,
         let filledBP = symbol.symbolInfo?.filledBezierPath {
        let scale : CGFloat = schematicsView.actualScale
        let horizontalFlip : CGFloat = schematicsView.horizontalFlip ? -scale : scale
        let verticalFlip   : CGFloat = schematicsView.verticalFlip   ? -scale : scale
        var af = AffineTransform ()
        af.scale (x: horizontalFlip, y: verticalFlip)
        let symbolShape = EBShape ()
        symbolShape.append (EBFilledBezierPathShape ([EBBezierPath (filledBP)], g_Preferences!.symbolColorForSchematic))
        symbolShape.append (EBStrokeBezierPathShape ([EBBezierPath (strokeBP)], g_Preferences!.symbolColorForSchematic))
        let scaledSymbolShape = symbolShape.transformed (by: af)
        result = buildPDFimage (frame: scaledSymbolShape.boundingBox, shape: scaledSymbolShape)
      }
    }else if inSourceTableView == self.mUnplacedPackageTableView,
           let boardView = self.mBoardView,
           dragRows.count == 1,
           let idx = dragRows.first {
      let componentTag = inSourceTableView.tag (atIndex: idx)
      self.mPossibleDraggedComponent = nil
      for component in self.rootObject.mComponents {
        if component.ebObjectIndex == componentTag {
          self.mPossibleDraggedComponent = component
        }
      }
      if let component = self.mPossibleDraggedComponent, let strokeBezierPath = component.strokeBezierPath {
        let scale : CGFloat = boardView.actualScale
        let horizontalFlip : CGFloat = boardView.horizontalFlip ? -scale : scale
        let verticalFlip   : CGFloat = boardView.verticalFlip   ? -scale : scale
        var af = AffineTransform ()
        af.scale (x: horizontalFlip, y: verticalFlip)
        let packageShape = EBShape ()
        packageShape.append (EBStrokeBezierPathShape ([EBBezierPath (strokeBezierPath)], g_Preferences!.symbolColorForSchematic))
        let scaledPackageShape = packageShape.transformed (by: af)
        result = buildPDFimage (frame: scaledPackageShape.boundingBox, shape: scaledPackageShape)
      }
    }
    return result
  }

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
      }
    }
    return ok
  }

  //····················································································································

  private func boardTextImageFactory () -> EBShape? {
    var result : EBShape? = nil
    if let font = self.rootObject.mFonts.first {
      self.ebUndoManager.disableUndoRegistration ()
      do{
        let boardText = BoardText (nil)
        boardText.mFont = font
        result = boardText.objectDisplay
        boardText.mFont = nil
      }
      self.ebUndoManager.enableUndoRegistration ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "Cannot Currently Add a Text: first, you need to add a Font."
      alert.informativeText = "This project does not embed any font. A font is needed for displaying texts in board."
      alert.addButton (withTitle: "Add Font")
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: self.windowForSheet!) { (inReturnCode) in
        if (inReturnCode == .alertFirstButtonReturn) {
          self.addFont (postAction: nil)
        }
      }
    }
    return result
  }

  //····················································································································

  private func performAddBoardPackageDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    if let component = self.mPossibleDraggedComponent {
      let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGridStepInCanariUnit)
      component.mX = p.x
      component.mY = p.y
      if let strokeBezierPath = component.strokeBezierPath, !strokeBezierPath.isEmpty {
        let bounds = strokeBezierPath.bounds
        let center = NSPoint (x: bounds.midX, y: bounds.midY).canariPoint
        component.mX -= center.x
        component.mY -= center.y
      }
      self.rootObject.mBoardObjects.append (component)
      self.boardObjectsController.setSelection ([component])
      self.mPossibleDraggedComponent = nil
    }
  }

  //····················································································································

  private func performAddBoardTextDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGridStepInCanariUnit)
    let boardText = BoardText (self.ebUndoManager)
    boardText.mX = p.x
    boardText.mY = p.y
    boardText.mFont = self.rootObject.mFonts.first!
    self.rootObject.mBoardObjects.append (boardText)
    self.boardObjectsController.setSelection ([boardText])
  }

  //····················································································································

  private func performAddRestrictRectangleDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGridStepInCanariUnit)
    let restrictRectangle = BoardRestrictRectangle (self.ebUndoManager)
    restrictRectangle.mX = p.x
    restrictRectangle.mY = p.y
    self.rootObject.mBoardObjects.append (restrictRectangle)
    self.boardObjectsController.setSelection ([restrictRectangle])
  }

  //····················································································································

  private func performAddCommentDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let comment = CommentInSchematic (self.ebUndoManager)
    comment.mX = p.x
    comment.mY = p.y
    self.rootObject.mSelectedSheet?.mObjects.append (comment)
    self.schematicObjectsController.setSelection ([comment])
  }

  //····················································································································

  private func performAddSymbolDragOperation (_ inSymbol : ComponentSymbolInProject, _ inDraggingLocationInDestinationView : NSPoint) {
  //--- Fix symbol location
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: milsToCanariUnit (50))
    inSymbol.mCenterX = p.x
    inSymbol.mCenterY = p.y
  //--- Create points in schematics
    let symbolInfo : ComponentSymbolInfo = inSymbol.symbolInfo!
    let symbolPins : [PinDescriptor] = symbolInfo.pins
    for pin in symbolPins {
      if pin.symbolIdentifier.symbolInstanceName == inSymbol.mSymbolInstanceName {
        let point = PointInSchematic (self.ebUndoManager)
        point.mSymbol = inSymbol
        point.mSymbolPinName = pin.pinName
        self.rootObject.mSelectedSheet?.mPoints.append (point)
      }
    }
  //--- Enter symbol
    self.rootObject.mSelectedSheet?.mObjects.append (inSymbol)
    self.schematicObjectsController.setSelection ([inSymbol])
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
