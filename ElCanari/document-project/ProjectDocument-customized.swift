//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let kDragAndDropSymbolType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.schematics.symbol")

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
  //  Property needed for handling "symbol count" to insert in segmented cointrol title
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
    self.mSchematicsView?.mGridStepInCanariUnit = milsToCanariUnit (100)
  //--- Set document to scroll view for enabling drag and drop for schematics symbols
    self.mSchematicsScrollView?.register (document: self, draggedTypes: [kDragAndDropSymbolType])
    self.mUnplacedSymbolsTableView?.register (document: self, draggedType: kDragAndDropSymbolType)
  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
    self.mSymbolCountToInsertController?.unregister ()
    self.mSymbolCountToInsertController = nil
    self.mSheetController.unregister ()
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
    //--- Get schematics view scale and flip
      let scale : CGFloat = schematicsView.actualScale
      let horizontalFlip : CGFloat = schematicsView.horizontalFlip ? -1.0 : 1.0
      let verticalFlip   : CGFloat = schematicsView.verticalFlip   ? -1.0 : 1.0
    //--- Find symbol to insert in schematics
      let symbolTag = self.mUnplacedSymbolsTableView?.tag (atIndex: idx) ?? 0
      var possibleSymbol : ComponentSymbolInProject? = nil
      for component in self.rootObject.mComponents {
        for s in component.mSymbols {
           if s.ebObjectIndex == symbolTag {
             possibleSymbol = s
           }
        }
      }
      if let symbol = possibleSymbol {
        Swift.print ("\(symbol)")
      }
    //--- Image size
 //     let boardModel = self.rootObject.boardModels_property.propval [idx]
   //   Swift.print ("Model size: \(canariUnitToCocoa (boardModel.modelWidth)), \(canariUnitToCocoa (boardModel.modelHeight))")
//      var width  : CGFloat = scale * canariUnitToCocoa (boardModel.modelWidth)
//      var height : CGFloat = scale * canariUnitToCocoa (boardModel.modelHeight)
   //   Swift.print ("Image size: \(width), \(height)")
    //--- Orientation (0 -> 0°, 1 -> 90°, 2 -> 180°, 3 -> 270°)
//      let rotation = self.mInsertedInstanceDefaultOrientation?.selectedTag () ?? 0
//      if (rotation == 1) || (rotation == 3) {
//        let temp = width
//        width = height
//        height = temp
//      }
    //--- By default, image is centered
//      dragImageOffset.pointee = NSPoint (x: horizontalFlip * width / 2.0, y: verticalFlip * height / 2.0)
//    //--- Build image
//      let r = CGRect (x: 0.0, y: 0.0, width: width, height: height)
//      let bp = NSBezierPath (rect: r.insetBy (dx: 0.5, dy: 0.5))
//      bp.lineWidth = 1.0
//      let shape = EBStrokeBezierPathShape ([bp], NSColor.gray)
//      let image = buildPDFimage (frame: r, shape: shape, backgroundColor:NSColor.gray.withAlphaComponent (0.25))
//      return image
     }
     return result
  }

  //····················································································································

  override func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    let ok = false
    return ok
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
