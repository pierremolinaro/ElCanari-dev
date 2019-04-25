//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedProjectDocument) class CustomizedProjectDocument : ProjectDocument {

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()
  //--- Add default net class
    self.ebUndoManager.disableUndoRegistration ()
    let netClass = NetClassInProject (self.ebUndoManager)
    self.rootObject.mNetClasses.append (netClass)
    self.ebUndoManager.enableUndoRegistration ()
  }

  //····················································································································
  //  Properties needed for renamoing a component
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
  //---
    self.mNewComponentFromDevicePullDownButton?.register (document: self)
  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

//  override func removeUserInterface () {
//    super.removeUserInterface ()
//  }

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
