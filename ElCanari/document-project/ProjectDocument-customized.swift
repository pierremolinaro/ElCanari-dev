//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

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

  override func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    let ok = false
    return ok
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
