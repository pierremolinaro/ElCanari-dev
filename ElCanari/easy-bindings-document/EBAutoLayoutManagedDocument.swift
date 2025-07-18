//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

fileprivate let WINDOW_HEIGHT_METADATADICTIONARY_KEY = "WindowHeight"
fileprivate let WINDOW_WIDTH_METADATADICTIONARY_KEY  = "WindowWidth"

//--------------------------------------------------------------------------------------------------
//  EBAutoLayoutManagedDocument
//--------------------------------------------------------------------------------------------------

@MainActor class EBAutoLayoutManagedDocument : NSDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mReadMetadataStatus : UInt8 = 0
  private final var mMetadataDictionary = [String : Any] ()
  private final var mSplashScreenWindow : CanariWindow? = nil
  private final var mSplashTextField : AutoLayoutLabel? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Root Object
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var mRootObject : EBManagedObject

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor override init () {
    self.mRootObject = EBManagedObject (nil) // Temporary object
    super.init ()
    noteObjectAllocation (self)
    let undoManager = EBUndoManager ()
    self.undoManager = undoManager
    undoManager.disableUndoRegistration ()
    self.mRootObject = newInstanceOfEntityNamed (undoManager, self.rootEntityClassName ())
    undoManager.enableUndoRegistration ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override class var autosavesInPlace : Bool { false }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    rootEntityClassName
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rootEntityClassName () -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Providing the drag image, called by a source drag table view (CanariDragSourceTableView)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func image (forDragSource inSourceTableView : AutoLayoutCanariDragSourceTableView,
              forDragRowIndex inDragRow : Int) -> (NSImage, NSPoint) {
    return (NSImage (named: NSImage.Name ("exclamation"))!, NSPoint ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Drag destination
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // The six NSDraggingDestination methods are invoked in a distinct order:
  //
  // ① As the image is dragged into the destination’s boundaries, the destination is sent a draggingEntered: message.
  //       The method should return a value that indicates which dragging operation the destination will perform.
  // ② While the image remains within the destination, a series of draggingUpdated: messages are sent.
  //       The method should return a value that indicates which dragging operation the destination will perform.
  // ③ If the image is dragged out of the destination, draggingExited: is sent and the sequence of
  //       NSDraggingDestination messages stops. If it re-enters, the sequence begins again (with a new
  //       draggingEntered: message).
  // ④ When the image is released, it either slides back to its source (and breaks the sequence) or a
  //       prepareForDragOperation: message is sent to the destination, depending on the value returned by the most
  //       recent invocation of draggingEntered: or draggingUpdated:.
  // ⑤  If the prepareForDragOperation: message returned YES, a performDragOperation: message is sent.
  // ⑥  Finally, if performDragOperation: returned YES, concludeDragOperation: is sent.
  //
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func draggingEntered (_ inDraggingInfo : any NSDraggingInfo,
                        _ inScrollView : NSScrollView) -> NSDragOperation {
    // NSLog ("draggingEntered")
    return .copy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func draggingUpdated (_ /* inDraggingInfo */ : any NSDraggingInfo,
                        _ /* inScrollView */ : NSScrollView) -> NSDragOperation {
    // NSLog ("draggingUpdated")
    return .copy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func draggingExited (_ /* inDraggingInfo */ : (any NSDraggingInfo)?,
                       _ /* inScrollView */ : NSScrollView) {
    // NSLog ("draggingExited")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prepareForDragOperation (_ /* inDraggingInfo */ : any NSDraggingInfo,
                                _ /* inScrollView */ : NSScrollView) -> Bool {
    // NSLog ("prepareForDragOperation")
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func performDragOperation (_ /* inDraggingInfo */ : any NSDraggingInfo,
                             _ /* inScrollView */ : NSScrollView) -> Bool {
    // NSLog ("performDragOperation")
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func concludeDragOperation (_ /* inDraggingInfo */ : (any NSDraggingInfo)?,
                              _ /* inScrollView */ : NSScrollView) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Document File Format
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private final class MyPrivateUndoer : NSObject { // For Swift 6
//    let mOldValue : EBManagedDocumentFileFormat
//
//    init (_ inOldValue : EBManagedDocumentFileFormat) {
//      self.mOldValue = inOldValue
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  @objc private final func myPerformUndo (_ inObject : MyPrivateUndoer) {  // For Swift 6
//    self.mManagedDocumentFileFormat = inObject.mOldValue
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var mManagedDocumentFileFormat : EBManagedDocumentFileFormat = .binary {
    didSet {
      if self.mManagedDocumentFileFormat != oldValue {
        self.undoManager?.registerUndo (withTarget: self) { selfTarget in
          selfTarget.mManagedDocumentFileFormat = oldValue // Ok in Swift 6.2
          // MainActor.assumeIsolated { selfTarget.setProp (inOldValue) }
        }
//         self.undoManager?.registerUndo (  // For Swift 6
//          withTarget: self,
//          selector: #selector (Self.myPerformUndo (_:)),
//          object: MyPrivateUndoer (oldValue)
//        )
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SAVE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func metadataStatusForSaving () -> UInt8 {
    return 0 ;
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final func data (ofType typeName : String) throws -> Data {
  //--- Update document version
    var version = self.mVersion.propval
    switch self.mVersionShouldChangeObserver.selection {
    case .empty, .multiple :
      break
    case .single (let shouldChange) :
      if shouldChange {
        version += 1
        self.mVersion.setProp (version)
        self.mVersionShouldChangeObserver.updateStartUpSignature ()
      }
    }
  //--- Save metadata dictionary
    self.saveMetadataDictionary (version: version, metadataDictionary : &self.mMetadataDictionary)
  //--- Add the width and the height of main window to metadata dictionary
    if let unwrappedWindowForSheet = windowForSheet { // Document has been opened in the user interface
      if unwrappedWindowForSheet.styleMask.contains(.resizable) { // Only if window is resizable
        let windowSize = unwrappedWindowForSheet.frame.size ;
        self.mMetadataDictionary [WINDOW_WIDTH_METADATADICTIONARY_KEY] = windowSize.width
        self.mMetadataDictionary [WINDOW_HEIGHT_METADATADICTIONARY_KEY] = windowSize.height
      }
    }
  //---
    let documentData = EBDocumentData (
      documentMetadataStatus: self.metadataStatusForSaving (),
      documentMetadataDictionary: self.mMetadataDictionary,
      documentRootObject: self.mRootObject,
      documentFileFormat: self.mManagedDocumentFileFormat
    )
    return try dataForSaveOperation (from: documentData)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    READ DOCUMENT FROM FILE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final func read (from inData : Data, ofType inTypeName : String) throws {
    DispatchQueue.main.async {
    //--- Show "Opening xxx…" splash window ?
      if inData.count > 300_000 {
        let window = CanariWindow (
          contentRect: NSRect (x: 0, y: 0, width: 200, height: 50),
          styleMask: [.docModalWindow],
          backing: .buffered,
          defer: true
        )
        window.isReleasedWhenClosed = false
        self.mSplashScreenWindow = window
        let textField = AutoLayoutLabel (bold: false, size: .small).set (alignment: .center)
        self.mSplashTextField = textField
        textField.stringValue = "Loading File…"
        let hStackView = AutoLayoutHorizontalStackView ()
          .set (margins: .zero)
          .appendFlexibleSpace ()
          .appendView (AutoLayoutSpinningProgressIndicator (size: .small))
          .appendFlexibleSpace ()
        let vStackView = AutoLayoutVerticalStackView ()
          .set (margins: .large)
          .appendView (AutoLayoutStaticLabel (title: "Opening " + self.displayName + "…", bold: true, size: .small, alignment: .center))
          .appendView (textField)
          .appendView (hStackView)
        window.contentView = vStackView
        window.orderFront (nil)
        window.center ()
        RunLoop.current.run (until: Date ())
      }
      self.undoManager?.disableUndoRegistration ()
    //--- Load file
      let documentReadData = loadEasyBindingFile (fromData: inData, documentName: self.displayName, undoManager: self.undoManager)
      switch documentReadData {
      case .ok (let documentData) :
        self.mManagedDocumentFileFormat = documentData.documentFileFormat
      //--- Store Status
        self.mReadMetadataStatus = documentData.documentMetadataStatus
      //--- Store metadata dictionary
        self.mMetadataDictionary = documentData.documentMetadataDictionary
      //--- Read version from file
        self.mVersion.setProp (self.readVersionFromMetadataDictionary (self.mMetadataDictionary))
      //--- Store root object
        self.mRootObject = documentData.documentRootObject
      //---
        self.undoManager?.enableUndoRegistration ()
      case .readError (let error) :
        let alert = NSAlert (error: error)
        _ = alert.runModal ()
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    return 0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func windowDefaultSize () -> NSSize {
    return NSSize (width: 480, height: 320)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func windowStyleMask () -> NSWindow.StyleMask {
    return [.titled, .closable, .miniaturizable, .resizable]
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   makeWindowControllers
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func makeWindowControllers () {
    DispatchQueue.main.async {
    //--- Signature observer
      self.mRootObject.setSignatureObserver (observer: self.mSignatureObserver)
      self.mSignatureObserver.setRootObject (self.mRootObject)
    //--- Version did change observer
      self.mVersionShouldChangeObserver.setSignatureObserverAndUndoManager (self.mSignatureObserver, self.undoManager)
      self.mSignatureObserver.startsBeingObserved (by: self.mVersionShouldChangeObserver)
    //--- Create the window and set the content view
      let s = self.windowDefaultSize ()
      let windowWidth  = (self.mMetadataDictionary [WINDOW_WIDTH_METADATADICTIONARY_KEY] as? CGFloat) ?? s.width
      let windowHeight = (self.mMetadataDictionary [WINDOW_HEIGHT_METADATADICTIONARY_KEY] as? CGFloat) ?? s.height
      let window = NSWindow (
        contentRect: NSRect(x: 0.0, y: 0.0, width: windowWidth, height: windowHeight),
        styleMask: self.windowStyleMask (),
        backing: .buffered,
        defer: true
      )
      window.isReleasedWhenClosed = false
      window.center ()
    //---
      let windowController = NSWindowController (window: window)
      self.addWindowController (windowController)
    //--- Build user interface
      if let textField = self.mSplashTextField {
        textField.stringValue = "Configuring User Interface…"
        RunLoop.current.run (until: Date ())
      }
      self.ebBuildUserInterface ()
      self.windowForSheet?.makeKeyAndOrderFront (nil)
      flushOutletEvents ()
      if let window = self.mSplashScreenWindow {
        window.orderOut (nil)
        self.mSplashTextField = nil
        self.mSplashScreenWindow = nil
      }
      appendDocumentFileOperationInfo ("User Interface Built.")
      appendTotalDurationDocumentFileOperationInfo ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func ebBuildUserInterface () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Signature observer
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mSignatureObserver = EBSignatureObserverEvent ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var signatureObserver_property : EBSignatureObserverEvent { return self.mSignatureObserver }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Version
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mVersion = EBStandAloneProperty_Int (0)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var versionObserver_property : EBStandAloneProperty_Int { return self.mVersion }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Version observer
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mVersionShouldChangeObserver = EBVersionShouldChangeObserver ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var versionShouldChangeObserver_property : EBVersionShouldChangeObserver {
    return self.mVersionShouldChangeObserver
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Reset version and signature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func resetVersionAndSignature () {
    self.undoManager?.registerUndo (
      withTarget: self,
      selector: #selector (Self.performUndoVersionNumber(_:)),
      object: NSNumber (value: self.mVersion.propval)
    )
    self.mVersion.setProp (0)
    self.mVersionShouldChangeObserver.clearStartUpSignature ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func performUndoVersionNumber (_ oldValue : NSNumber) {
    self.undoManager?.registerUndo (
      withTarget: self,
      selector: #selector (Self.performUndoVersionNumber(_:)),
      object: NSNumber (value: self.mVersion.propval)
    )
    self.mVersion.setProp (oldValue.intValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Menu Events
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    let action = inMenuItem.action
    if action == #selector (Self.printDocument(_:)) {
      validate = self.windowForSheet?.firstResponder is EBGraphicView
    }else if action == #selector (Self.setBinaryFormatAction(_:)) {
      validate = true
      inMenuItem.state = (self.mManagedDocumentFileFormat == .binary) ? .on : .off
    }else if action == #selector (Self.setTextualFormatAction(_:)) {
      validate = true
      inMenuItem.state = (self.mManagedDocumentFileFormat == .textual) ? .on : .off
    }else{
      validate = super.validateMenuItem (inMenuItem)
    }
    return validate
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   FORMAT ACTIONS
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction final func setBinaryFormatAction (_ inSender : Any?) {
    self.mManagedDocumentFileFormat = .binary
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction final func setTextualFormatAction (_ inSender : Any?) {
    self.mManagedDocumentFileFormat = .textual
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   PRINT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc override func printDocument (_ inSender : Any?) {
    if let view = self.windowForSheet?.firstResponder as? EBGraphicView {
      let printOperation = NSPrintOperation (view: view, printInfo: self.printInfo)
      let printPanel = printOperation.printPanel
      printPanel.options = [printPanel.options, .showsPaperSize, .showsOrientation, .showsScaling]
      self.runModalPrintOperation (printOperation, delegate: nil, didRun: nil, contextInfo: nil)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//  EBVersionShouldChangeObserver
//--------------------------------------------------------------------------------------------------

final class EBVersionShouldChangeObserver : EBTransientProperty <Bool>, EBSignatureObserverProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mUndoManager : UndoManager? = nil // SOULD BE WEAK
  private weak var mSignatureObserver : EBSignatureObserverEvent? = nil // SOULD BE WEAK
  private var mSignatureAtStartUp : UInt32 = 0

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
    self.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        return .single (unwSelf.mSignatureAtStartUp != unwSelf.signature ())
      }else{
        return .empty
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setSignatureObserverAndUndoManager (_ signatureObserver : EBSignatureObserverEvent,
                                                 _ inUndoManager : UndoManager?) {
    self.mUndoManager = inUndoManager
    self.mSignatureObserver = signatureObserver
    self.mSignatureAtStartUp = signatureObserver.signature ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func updateStartUpSignature () {
    if let signatureObserver = self.mSignatureObserver {
      self.mSignatureAtStartUp = signatureObserver.signature ()
      self.observedObjectDidChange ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func signature () -> UInt32 {
    if let signatureObserver = self.mSignatureObserver {
      return signatureObserver.signature ()
    }else{
      return 0
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func clearSignatureCache () {
    self.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // clearStartUpSignature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func clearStartUpSignature () {
    self.mUndoManager?.registerUndo (
      withTarget: self,
      selector: #selector (Self.performUndo(_:)),
      object: NSNumber (value: mSignatureAtStartUp)
    )
    self.mSignatureAtStartUp = 0
    self.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func performUndo (_ oldValue : NSNumber) {
    self.mUndoManager?.registerUndo (withTarget: self, selector:#selector (performUndo(_:)), object:NSNumber (value: mSignatureAtStartUp))
    self.mSignatureAtStartUp = oldValue.uint32Value
    self.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//  EBSignatureObserverEvent
//--------------------------------------------------------------------------------------------------

final class EBSignatureObserverEvent : EBTransientProperty <UInt32>, EBSignatureObserverProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mRootObject : (any EBSignatureObserverProtocol)? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
    self.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        return .single (unwSelf.signature ())
      }else{
        return .empty
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setRootObject (_ rootObject : any EBSignatureObserverProtocol) {
    self.mRootObject = rootObject
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func signature () -> UInt32 {
    if let rootObject = self.mRootObject {
      return rootObject.signature ()
    }else{
      return 0
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func clearSignatureCache () {
    self.observedObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
