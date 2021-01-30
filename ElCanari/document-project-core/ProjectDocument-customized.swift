//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

fileprivate let kDragAndDropSymbol = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.symbol")
fileprivate let kDragAndDropComment = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.comment")
fileprivate let kDragAndDropWire = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.wire")

//----------------------------------------------------------------------------------------------------------------------

fileprivate let kDragAndDropRestrictRectangle = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.restrict.rectangle")
fileprivate let kDragAndDropBoardText = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.text")
fileprivate let kDragAndDropBoardPackage = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.package")
fileprivate let kDragAndDropBoardLine = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.line")
fileprivate let kDragAndDropBoardTrack = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.track")

//----------------------------------------------------------------------------------------------------------------------

let TRACK_INITIAL_SIZE_CANARI_UNIT = 500 * 2_286 // # 500 mils

//----------------------------------------------------------------------------------------------------------------------

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
    self.rootObject.mBorderCurves = [bottom, right, top, left]
    left.setControlPointsDefaultValuesForLine ()
    right.setControlPointsDefaultValuesForLine ()
    bottom.setControlPointsDefaultValuesForLine ()
    top.setControlPointsDefaultValuesForLine ()
  //---
    self.ebUndoManager.enableUndoRegistration ()
  }

  //····················································································································
  //  FREE ROUTER TEMPORARY DIRECTORY
  //····················································································································

  internal var mFreerouterTemporaryBaseFilePath : String? = nil

  //····················································································································
  //  WIRE CREATED BY AN OPTION CLICK
  //····················································································································

  internal var mWireCreatedByOptionClick : WireInSchematic? = nil

  //····················································································································
  //  TRACK CREATED BY AN OPTION CLICK
  //····················································································································

  internal var mTrackCreatedByOptionClick : BoardTrack? = nil

  //····················································································································
  //  POP UP BUTTON CONTROLLERS FOR SELECTING NET CLASS
  //····················································································································

  private var mSelectedWireNetClassPopUpController = EBPopUpButtonControllerForNetClassFromSelectedWires ()
  private var mSelectedLabelNetClassPopUpController = EBPopUpButtonControllerForNetClassFromSelectedLabels ()

  //····················································································································
  //  Property needed for handling "symbol count" to insert in segmented control title
  //····················································································································

  fileprivate var mSymbolCountToInsertController : EBReadOnlyPropertyController? = nil
  private var mSheetController = ProjectSheetController ()
  internal var mPrintOperation : NSPrintOperation? = nil

  //····················································································································
  //  Property needed for handling "package count" to insert in segmented control title
  //····················································································································

  fileprivate var mPackageCountToInsertController : EBReadOnlyPropertyController? = nil

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

  private final func performModelAdjustements () {
    self.ebUndoManager.disableUndoRegistration ()
  //--- Remove components
    let componentSet = Set (self.rootObject.mComponents)
    for font in self.rootObject.mFonts {
      for component in font.mComponentNames {
        if !componentSet.contains (component) {
          component.mNameFont = nil
          component.mValueFont = nil
        }
      }
      for component in font.mComponentValues {
        if !componentSet.contains (component) {
          component.mNameFont = nil
          component.mValueFont = nil
        }
      }
    }
  //--- Remove tracks with missing connectors
    var trackWithMissingConnectorCount = 0
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        var suppress = false
        if track.mConnectorP1 == nil {
          Swift.print ("track \(track) without mConnectorP1")
          suppress = true
        }
        if track.mConnectorP2 == nil {
          Swift.print ("track \(track) without mConnectorP2")
          suppress = true
        }
        if suppress {
          trackWithMissingConnectorCount += 1
          track.mConnectorP1 = nil
          track.mConnectorP2 = nil
          track.mNet = nil
          track.mRoot = nil
        }
      }
    }
    if trackWithMissingConnectorCount > 0 {
      let alert = NSAlert ()
      alert.messageText = (trackWithMissingConnectorCount == 1)
        ? "1 invalid track has been removed."
        : "\(trackWithMissingConnectorCount) invalid tracks have been removed."
      alert.informativeText = "Canari does not export properly board tracks to ElCanari, and some of them are invalid, and crash ERC. Theses tracks have been removed."
      DispatchQueue.main.async { alert.beginSheetModal (for: self.windowForSheet!, completionHandler: nil) }
    }
  //--- Define default net wire
    if self.rootObject.mDefaultNetClassName == "" {
      self.rootObject.mDefaultNetClassName = self.rootObject.mNetClasses [0].mNetClassName
    }
    self.removeUnusedNets ()
    self.ebUndoManager.enableUndoRegistration ()
  }

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
    self.performModelAdjustements ()
  //---
    self.mDeviceLibraryTableView?.set (actionOnDoubleClick: { [weak self] in self?.renameDeviceDialog () })
    self.mDevicePackageTableView?.set (actionOnDoubleClick: { [weak self] in self?.renameDevicePackageDialog () })
    self.mDeviceSymbolTypeTableView?.set (actionOnDoubleClick: { [weak self] in self?.renameDeviceSymbolTypeDialog () })
    self.mDeviceSymbolTableView?.set (actionOnDoubleClick: { [weak self] in self?.renameDeviceSymbolInstanceDialog () })
    self.mDeviceSymbolTypePinsTableView?.set (actionOnDoubleClick: { [weak self] in self?.renameDeviceSymbolTypePinDialog () })
  //---
    self.mSelectComponentsMenuItem?.set (project: self)
    self.mSelectNetsMenuItem?.set (project: self)
    self.mComponentTableView?.set (actionOnDeleteKey: { [weak self] in self?.removeSelectedComponentsAction (nil) })
  //--- Register board limits inspector views
    self.boardCurveObjectsController.register (inspectorReceivingView: self.mSelectedObjectsBoardLimitsInspectorView)
    self.boardCurveObjectsController.register (inspectorView: self.mSelectedBoardLimitInspectorView, for: BorderCurve.self)
  //--- Option click for creating wire
     self.mSchematicsView?.setOptionMouseCallbacks (
       start: { [weak self] (inUnalignedMouseLocation) in self?.startWireCreationOnOptionMouseDown (at: inUnalignedMouseLocation) },
       continue: { [weak self] (inUnalignedMouseLocation, inModifierFlags) in self?.continueWireCreationOnOptionMouseDragged (at: inUnalignedMouseLocation, inModifierFlags) },
       abort: { [weak self] in self?.abortWireCreationOnOptionMouseUp () },
       helper: { [weak self] (inModifierFlags) in self?.helperStringForWireCreation (inModifierFlags) },
       stop: { [weak self] (inUnalignedMouseLocation) in self?.stopWireCreationOnOptionMouseUp (at: inUnalignedMouseLocation) ?? false }
     )
  //--- Option click for creating track
     self.mBoardView?.mHelperStringForOptionModifier = "SHIFT: mouse down starts a new track"
     self.mBoardView?.setOptionMouseCallbacks (
       start: { [weak self] (inUnalignedMouseLocation) in self?.startTrackCreationOnOptionMouseDown (at: inUnalignedMouseLocation) },
       continue: { [weak self] (inUnalignedMouseLocation, inModifierFlags) in self?.continueTrackCreationOnOptionMouseDragged (at: inUnalignedMouseLocation, inModifierFlags) },
       abort: { [weak self] in self?.abortTrackCreationOnOptionMouseUp () },
       helper: { [weak self] (inModifierFlags) in self?.helperStringForTrackCreation (inModifierFlags) },
       stop: { [weak self] (inUnalignedMouseLocation) in self?.stopTrackCreationOnOptionMouseUp (at: inUnalignedMouseLocation) ?? false }
     )
     self.mBoardView?.mDrawFrameIssue = false
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
    self.mBoardScrollView?.register (
      document: self,
      draggedTypes: [kDragAndDropRestrictRectangle, kDragAndDropBoardText, kDragAndDropBoardPackage, kDragAndDropBoardLine, kDragAndDropBoardTrack]
    )
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
    self.mPackageCountToInsertController = EBReadOnlyPropertyController (
      observedObjects: [self.unplacedPackageCount_property],
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
    self.boardObjectsController.register (inspectorView: self.mComponentInBoardInspectorView, for: ComponentInProject.self)
    self.boardObjectsController.register (inspectorView: self.mBoardLineInspectorView, for: BoardLine.self)
    self.boardObjectsController.register (inspectorView: self.mBoardTrackInspectorView, for: BoardTrack.self)
    self.boardObjectsController.register (inspectorView: self.mBoardConnectorInspectorView, for: BoardConnector.self)
    self.mBoardView?.mPopulateContextualMenuClosure = self.populateContextualClickOnBoard
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
    self.mSymbolCountToInsertController = EBReadOnlyPropertyController (
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
    self.mSchematicsView?.mHelperStringForOptionModifier = "SHIFT: mouse down starts a new wire"
  //--- Set document to scroll view for enabling drag and drop for schematics symbols
    self.mSchematicsScrollView?.register (document: self, draggedTypes: [kDragAndDropSymbol, kDragAndDropComment, kDragAndDropWire])
    self.mUnplacedSymbolsTableView?.register (document: self, draggedType: kDragAndDropSymbol)
  //--- Drag source buttons and destination scroll view
    self.mAddCommentButton?.register (
      draggedType: kDragAndDropComment,
      draggedObjectFactory: { return (CommentInSchematic (nil), NSDictionary ()) },
      scaleProvider: self.mSchematicsView
    )
    self.mAddWireButton?.register (
      draggedType: kDragAndDropWire,
      draggedObjectFactory: { return (WireInSchematic (nil), NSDictionary ()) },
      scaleProvider: self.mSchematicsView
    )
  //---
    self.mAddRestrictRectangleButton?.register (
      draggedType: kDragAndDropRestrictRectangle,
      draggedObjectFactory: { return (BoardRestrictRectangle (nil), NSDictionary ()) },
      scaleProvider: self.mBoardView
    )
    self.mAddTextInBoardButton?.register (
      draggedType: kDragAndDropBoardText,
      shapeFactory: { [weak self] in return self?.boardTextImageFactory () },
      scaleProvider: self.mBoardView
    )
    self.mAddLineInBoardButton?.register (
      draggedType: kDragAndDropBoardLine,
      draggedObjectFactory: { return (BoardLine (nil), NSDictionary ()) },
      scaleProvider: self.mBoardView
    )
    self.mAddTrackInBoardButton?.register (
      draggedType: kDragAndDropBoardTrack,
      shapeFactory: { [weak self] in return self?.boardTrackImageFactory () },
      scaleProvider: self.mBoardView
    )
  //---
    self.schematicObjectsController.mAfterObjectRemovingCallback = self.updateSchematicPointsAndNets
    self.mSchematicsView?.setMouseMovedOrFlagsChangedCallback { [weak self] (unalignedMouseLocation) in
      self?.mouseMovedOrFlagsChangedInSchematic (unalignedMouseLocation)
    }
    self.mSchematicsView?.setMouseExitCallback { [weak self] in self?.mouseExitInSchematic () }
    self.mouseExitInSchematic ()
    self.mSchematicsView?.setKeyDownCallback { [weak self] (mouseLocation, key) in self?.keyDownInSchematic (mouseLocation, key) }
  //---
    self.mBoardTextFontPopUpButton?.register (
      fontsModel: self.rootObject.mFonts_property,
      selectionController: self.boardTextSelectionController.selectedArray_property
    )
    self.mBoardComponentNameFontPopUpButton?.register (
      fontsModel: self.rootObject.mFonts_property,
      selectionController: self.componentInBoardSelectionController.selectedArray_property
    )
    self.mBoardComponentValueFontPopUpButton?.register (
      fontsModel: self.rootObject.mFonts_property,
      selectionController: self.componentInBoardSelectionController.selectedArray_property
    )
    self.mComponentPackagePopUpButton?.register (
      selectionController: self.componentInBoardSelectionController.selectedArray_property
    )
    self.boardObjectsController.mAfterObjectRemovingCallback = self.updateBoardConnectors

    self.mERCIssueTableView?.register (issueDisplayView: self.mBoardView)
    self.mERCIssueTableView?.register (hideIssueButton: self.mHideERCIssueButton)
    self.mBoardView?.setMouseMovedOrFlagsChangedCallback { [weak self] (unalignedMouseLocation) in
      self?.mouseMovedOrFlagsChangedInBoard (unalignedMouseLocation)
    }
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
    self.mBoardView?.mPopulateContextualMenuClosure = nil // Required for breaking strong reference cycle
    self.schematicObjectsController.mAfterObjectRemovingCallback = nil // Required for breaking strong reference cycle
    self.boardObjectsController.mAfterObjectRemovingCallback = nil // Required for breaking strong reference cycle
  //--- Pop up button controllers
    self.mSelectedWireNetClassPopUpController.unbind_model ()
    self.mSelectedWireNetClassPopUpController.attachPopUpButton (nil)
    self.mSelectedLabelNetClassPopUpController.unbind_model ()
    self.mSelectedLabelNetClassPopUpController.attachPopUpButton (nil)
    self.mBoardTextFontPopUpButton?.unregister ()
    self.mBoardComponentNameFontPopUpButton?.unregister ()
    self.mBoardComponentValueFontPopUpButton?.unregister ()
    self.mComponentPackagePopUpButton?.unregister ()
  //---
    super.removeUserInterface ()
  }

  //····················································································································
  //    Update points and net
  //····················································································································

  internal func updateSchematicPointsAndNets () {
    var errorList = [String] ()
    self.rootObject.mSelectedSheet?.removeUnusedSchematicsPoints (&errorList)
    self.removeUnusedWires (&errorList)
    self.removeUnusedNets ()
    self.updateSelectedNetForRastnetDisplay ()
    if errorList.count > 0,
       let dialog = self.mInconsistentSchematicErrorPanel,
       let window = self.windowForSheet {
      let message = errorList.joined (separator: "\n")
      self.mInconsistentSchematicErrorTextView?.string = message
      window.beginSheet (dialog) { (inModalResponse) in }
    }
  }

  //····················································································································
  // Remove unused wires
  //····················································································································

  internal func removeUnusedWires (_ ioErrorList : inout [String]) {
    for object in self.rootObject.mSelectedSheet!.mObjects {
      if let wire = object as? WireInSchematic {
        if let p1 = wire.mP1, p1.mSheet == nil {
          wire.mP1 = nil
          wire.mP2 = nil
        }else if let p2 = wire.mP2, p2.mSheet == nil {
          wire.mP1 = nil
          wire.mP2 = nil
        }
        if (wire.mP1 == nil) && (wire.mP2 == nil) { // Useless wire, delete
          wire.mSheet = nil
        }else if (wire.mP1 == nil) != (wire.mP2 == nil) { // Invalid wire
          ioErrorList.append ("Invalid wire: mP1 \(string (wire.mP1)), mP2 \(string (wire.mP2))")
        }
      }
    }
  }


  //····················································································································
  //    Update board connectors after object removing in board
  //····················································································································

  internal func updateBoardConnectors () {
    let boardObjects = self.rootObject.mBoardObjects
    for object in boardObjects {
      if let connector = object as? BoardConnector {
        let connectedTrackCount = connector.mTracksP1.count + connector.mTracksP2.count
        if (connector.mComponent == nil) && (connectedTrackCount == 0) {
          connector.mRoot = nil // Remove from board objects
        }
      }
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
        var symbolShape = EBShape ()
        symbolShape.add (filled: [EBBezierPath (filledBP)], prefs_symbolColorForSchematic)
        symbolShape.add (stroke: [EBBezierPath (strokeBP)], prefs_symbolColorForSchematic)
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
      if let component = self.mPossibleDraggedComponent, let packageShape = component.objectDisplay {
        let scale : CGFloat = boardView.actualScale
        let horizontalFlip : CGFloat = boardView.horizontalFlip ? -scale : scale
        let verticalFlip   : CGFloat = boardView.verticalFlip   ? -scale : scale
        var af = AffineTransform ()
        af.scale (x: horizontalFlip, y: verticalFlip)
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

  private func boardTrackImageFactory () -> EBShape? {
    let p1 = BoardConnector (nil)
    p1.mX = 0
    p1.mY = 0
    let p2 = BoardConnector (nil)
    p2.mX = TRACK_INITIAL_SIZE_CANARI_UNIT
    p2.mY = TRACK_INITIAL_SIZE_CANARI_UNIT
    let track = BoardTrack (nil)
    track.mConnectorP1 = p1
    track.mConnectorP2 = p2
    return track.objectDisplay
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
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGridStepInCanariUnit)
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

  private func performAddBoardTextDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGridStepInCanariUnit)
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

  private func performAddRestrictRectangleDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: self.mBoardView!.mGridStepInCanariUnit)
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

  private func performAddCommentDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let comment = CommentInSchematic (self.ebUndoManager)
    comment.mX = p.x
    comment.mY = p.y
    self.rootObject.mSelectedSheet?.mObjects.append (comment)
    self.schematicObjectsController.setSelection ([comment])
    self.windowForSheet?.makeFirstResponder (self.mSchematicsView)
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
    self.windowForSheet?.makeFirstResponder (self.mSchematicsView)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
