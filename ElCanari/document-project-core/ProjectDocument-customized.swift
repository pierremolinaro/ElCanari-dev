//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let kDragAndDropSymbolInSchematic = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.schematic.symbol")
fileprivate let kDragAndDropCommentInSchematic = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.schematic.comment")
fileprivate let kDragAndDropWireInSchematic = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.schematic.wire")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedProjectDocument) class CustomizedProjectDocument : ProjectDocument {

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()
  //--- Add default net class and first sheet
    self.ebUndoManager.disableUndoRegistration ()
    let netClass = NetClassInProject (self.ebUndoManager)
    self.rootObject.mNetClasses.append (netClass)
    let sheet = SheetInProject (self.ebUndoManager)
    self.rootObject.mSheets.append (sheet)
    self.rootObject.mSelectedSheet = sheet
    self.ebUndoManager.enableUndoRegistration ()
  }

  //····················································································································
  //  Property needed for handling "symbol count" to insert in segmented control title
  //····················································································································

  fileprivate var mSymbolCountToInsertController : EBSimpleController? = nil
  private var mSheetController = ProjectSheetController ()
  internal var mPrintOperation : NSPrintOperation? = nil

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

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [
      self.mComponentsPageView,
      self.mLibraryPageView,
      self.mSchematicsPageView,
      self.mNetClassesPageView ,
      self.mNetListPageView,
      self.mBoardPageView,
      self.mProductPageView
    ]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set schematics inspector segmented control
    let schematicsInspectors = [
      self.mSelectedObjectsSchematicsInspectorView,
      self.mUnplacedSymbolsSchematicsInspectorView,
      self.mGridZoomSchematicsInspectorView,
      self.mSchematicsSheetsInspectorView
    ]
    self.mSchematicsInspectorSegmentedControl?.register (masterView: self.mBaseSchematicsInspectorView, schematicsInspectors)
  //--- Register schematics inspector views
    self.mSchematicObjectsController.register (inspectorReceivingView: self.mSelectedObjectsSchematicsInspectorView)
    self.mSchematicObjectsController.register (inspectorView: self.mComponentSymbolInspectorView, forClass: "ComponentSymbolInProject")
    self.mSchematicObjectsController.register (inspectorView: self.mCommentInSchematicsInspectorView, forClass: "CommentInSchematic")
    self.mSchematicObjectsController.register (inspectorView: self.mNCInSchematicsInspectorView, forClass: "NCInSchematic")
    self.mSchematicObjectsController.register (inspectorView: self.mSchematicsLabelInspectorView, forClass: "LabelInSchematic")
    self.mSchematicObjectsController.register (inspectorView: self.mSchematicsWireInspectorView, forClass: "WireInSchematic")
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
        self.mSchematicsInspectorSegmentedControl?.setLabel (title, forSegment: 1)
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
    self.mSchematicsScrollView?.register (document: self, draggedTypes: [kDragAndDropSymbolInSchematic, kDragAndDropCommentInSchematic, kDragAndDropWireInSchematic])
    self.mUnplacedSymbolsTableView?.register (document: self, draggedType: kDragAndDropSymbolInSchematic)
  //--- Drag source buttons and destination scroll view
    self.mAddCommentButton?.register (
      draggedType: kDragAndDropCommentInSchematic,
      entityName: "CommentInSchematics",
      scaleProvider: self.mSchematicsView
    )
    self.mAddWireButton?.register (
      draggedType: kDragAndDropWireInSchematic,
      entityName: "WireInSchematic",
      scaleProvider: self.mSchematicsView
    )
  //---
    self.mSchematicObjectsController.mAfterObjectRemovingCallback = self.updateSchematicsPointsAndNets
  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
    self.mSymbolCountToInsertController?.unregister ()
    self.mSymbolCountToInsertController = nil
    self.mSheetController.unregister ()
    self.mSchematicsView?.mPopulateContextualMenuClosure = nil // Required for breaking strong reference cycle
    self.mSchematicObjectsController.mAfterObjectRemovingCallback = nil // Required for breaking strong reference cycle
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

  override func dragImageForRows (with dragRows: IndexSet,
                                  tableColumns: [NSTableColumn],
                                  event dragEvent: NSEvent,
                                  offset dragImageOffset: NSPointPointer) -> NSImage {
    var result = NSImage (named: NSImage.Name ("exclamation"))!
    if let schematicsView = self.mSchematicsView, dragRows.count == 1, let idx = dragRows.first {
    //--- Find symbol to insert in schematics
      let symbolTag = self.mUnplacedSymbolsTableView?.tag (atIndex: idx) ?? 0
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
        let af = NSAffineTransform ()
        af.scaleX (by: horizontalFlip, yBy: verticalFlip)
        let symbolShape = EBShape ()
        symbolShape.append (EBFilledBezierPathShape ([filledBP], g_Preferences!.symbolColorForSchematic))
        symbolShape.append (EBStrokeBezierPathShape ([strokeBP], g_Preferences!.symbolColorForSchematic))
        let scaledSymbolShape = symbolShape.transformedBy (af)
        result = buildPDFimage (frame: scaledSymbolShape.boundingBox, shape: scaledSymbolShape)
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
      if let _ = pasteboard.data (forType: kDragAndDropSymbolInSchematic), let symbol = self.mPossibleDraggedSymbol {
        self.performAddSymbolDragOperation (symbol, draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropCommentInSchematic]) {
        self.performAddCommentDragOperation (draggingLocationInDestinationView)
        ok = true
      }else if let _ = pasteboard.availableType (from: [kDragAndDropWireInSchematic]) {
        let possibleNewWire = selectedSheet.performAddWireDragOperation (draggingLocationInDestinationView, newNetCreator: self.rootObject.createNetWithAutomaticName)
        if let newWire = possibleNewWire {
          self.mSchematicObjectsController.setSelection ([newWire])
          ok = true
        }
      }
    }
    return ok
  }

  //····················································································································

  private func performAddCommentDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let comment = CommentInSchematic (self.ebUndoManager)
    comment.mX = p.x
    comment.mY = p.y
    self.rootObject.mSelectedSheet?.mObjects.append (comment)
    self.mSchematicObjectsController.setSelection ([comment])
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
    self.mSchematicObjectsController.setSelection ([inSymbol])
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
