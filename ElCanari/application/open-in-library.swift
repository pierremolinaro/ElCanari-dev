//
//  OpenInLibrary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenInLibrary : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {

  //····················································································································

  @IBOutlet private var mDialog : NSWindow?
  @IBOutlet private var mOpenButton : NSButton?
  @IBOutlet private var mCancelButton : NSButton?
  @IBOutlet private var mOutlineView : NSOutlineView?
  @IBOutlet private var mFullPathTextField : NSTextField?
  @IBOutlet private var mStatusTextField : NSTextField?
  @IBOutlet private var mPartImage : NSImageView?
  @IBOutlet private var mNoSelectedPartTextField : NSTextField?

  //····················································································································
  //   Load document, displayed as sheet
  //····················································································································

  internal func loadDocumentFromLibrary (windowForSheet inWindow : NSWindow,
                                         alreadyLoadedDocuments inNames : Set <String>,
                                         callBack : @escaping (_ inData : Data, _ inName : String) -> Void) {
  //--- Configure
    self.mFullPathTextField?.stringValue = ""
    self.mStatusTextField?.stringValue = ""
    self.mCancelButton?.target = self
    self.mCancelButton?.action = #selector (OpenInLibrary.abortSheetAction (_:))
    self.mOpenButton?.target = self
    self.mOpenButton?.action = #selector (OpenInLibrary.stopSheetAction (_:))
    self.mOpenButton?.isEnabled = false
    self.mPartImage?.image = nil
    self.mNoSelectedPartTextField?.isHidden = false
    self.mOutlineView?.dataSource = self
    self.mOutlineView?.delegate = self
    self.buildDataSource (alreadyLoadedDocuments: inNames)
    self.mOutlineView?.reloadData ()
  //--- Dialog
    if let dialog = self.mDialog {
      inWindow.beginSheet (dialog, completionHandler: { (_ inModalResponse : NSApplication.ModalResponse) in
        if inModalResponse == .stop,
             let selectedRow = self.mOutlineView?.selectedRow,
             let selectedItem = self.mOutlineView?.item (atRow: selectedRow) as? LibraryDialogItem,
             selectedItem.mFullPath != "" {
          let fm = FileManager ()
          if let data = fm.contents (atPath: selectedItem.mFullPath) {
            callBack (data, selectedItem.mFullPath.lastPathComponent.deletingPathExtension)
          }
        }
        self.mOutlineViewDataSource = []
        self.mOutlineView?.reloadData ()
      })
    }
  }

  //····················································································································

  @objc private func abortSheetAction (_ inSender : Any?) {
    if let myWindow = self.mDialog, let parent = myWindow.sheetParent {
      parent.endSheet (myWindow, returnCode: .abort)
    }
  }

  //····················································································································

  @objc private func stopSheetAction (_ inSender : Any?) {
    if let myWindow = self.mDialog, let parent = myWindow.sheetParent {
      parent.endSheet (myWindow, returnCode: .stop)
    }
  }

  //····················································································································
  //   Open document in library, displayed as dialog window
  //····················································································································

  internal func openDocumentInLibrary (windowTitle inTitle : String) {
  //--- Configure
    self.mDialog?.title = inTitle
    self.mFullPathTextField?.stringValue = ""
    self.mStatusTextField?.stringValue = ""
    self.mCancelButton?.target = self
    self.mCancelButton?.action = #selector (OpenInLibrary.abortModalAction (_:))
    self.mOpenButton?.target = self
    self.mOpenButton?.action = #selector (OpenInLibrary.stopModalAndOpenDocumentAction (_:))
    self.mOpenButton?.isEnabled = false
    self.mPartImage?.image = nil
    self.mNoSelectedPartTextField?.isHidden = false
    self.mOutlineView?.dataSource = self
    self.mOutlineView?.delegate = self
    self.buildDataSource (alreadyLoadedDocuments: [])
    self.mOutlineView?.reloadData ()
  //--- Dialog
    if let dialog = self.mDialog {
      _ = NSApp.runModal (for: dialog)
    }
  }

  //····················································································································

  @objc private func abortModalAction (_ inSender : Any?) {
    NSApp.abortModal ()
    self.mDialog?.orderOut (nil)
    self.mOutlineViewDataSource = []
    self.mOutlineView?.reloadData ()
  }

  //····················································································································

  @objc private func stopModalAndOpenDocumentAction (_ inSender : Any?) {
    NSApp.stopModal ()
    self.mDialog?.orderOut (nil)
    if let selectedRow = self.mOutlineView?.selectedRow,
       let selectedItem = self.mOutlineView?.item (atRow: selectedRow) as? LibraryDialogItem,
       selectedItem.mFullPath != "" {
      let dc = NSDocumentController.shared
      let url = URL (fileURLWithPath: selectedItem.mFullPath)
      dc.openDocument (withContentsOf: url, display: true, completionHandler: {(document : NSDocument?, alreadyOpen : Bool, error : Error?) in })
    }
    self.mOutlineViewDataSource = []
    self.mOutlineView?.reloadData ()
  }

  //····················································································································
  //   NSOutlineViewDataSource methods
  //····················································································································

  private var mOutlineViewDataSource = [LibraryDialogItem] ()

  //····················································································································

  func outlineView (_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if let dialogItem = item as? LibraryDialogItem {
      return dialogItem.mChildren.count
    }else{
      return self.mOutlineViewDataSource.count
    }
  }

  //····················································································································

  func outlineView (_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let dialogItem = item as? LibraryDialogItem {
      return dialogItem.mChildren [index]
    }else{
      return self.mOutlineViewDataSource [index]
    }
  }

  //····················································································································

  func outlineView (_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if let dialogItem = item as? LibraryDialogItem {
      return dialogItem.mChildren.count > 0
    }else{
      return false
    }
  }

  //····················································································································
  //   NSOutlineViewDelegate
  //····················································································································

  func outlineView (_ outlineView: NSOutlineView, viewFor inTableColumn: NSTableColumn?, item: Any) -> NSView? {
    var view: NSTableCellView? = nil
    if let dialogItem = item as? LibraryDialogItem, let tableColumn = inTableColumn {
      if tableColumn.identifier.rawValue == "name" {
        view = outlineView.makeView (withIdentifier: tableColumn.identifier, owner: self) as? NSTableCellView
        if let textField = view?.textField {
          textField.stringValue = dialogItem.mPartName
        }
      }else if tableColumn.identifier.rawValue == "status" {
        view = outlineView.makeView (withIdentifier: tableColumn.identifier, owner: self) as? NSTableCellView
        if let imageView = view?.imageView {
          imageView.image = dialogItem.statusImage ()
        }
      }
    }
    return view
  }

  //····················································································································

  func outlineViewSelectionDidChange (_ notification: Notification) {
    if let selectedRow = self.mOutlineView?.selectedRow,
       let selectedItem = self.mOutlineView?.item (atRow: selectedRow) as? LibraryDialogItem {
      self.mFullPathTextField?.stringValue = selectedItem.mFullPath
      self.mStatusTextField?.stringValue = selectedItem.statusString ()
      self.mOpenButton?.isEnabled = (selectedItem.mFullPath != "") && !selectedItem.mIsAlreadyLoaded
      self.mNoSelectedPartTextField?.isHidden = selectedItem.mFullPath != ""
      self.mPartImage?.image = selectedItem.image
    }else{
      self.mFullPathTextField?.stringValue = ""
      self.mStatusTextField?.stringValue = ""
      self.mOpenButton?.isEnabled = false
      self.mPartImage?.image = nil
    }
  }

  //····················································································································

  internal func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) { // Abstract method
  }

  //····················································································································

  internal func partLibraryPathForPath (_ inPath : String) -> String {
    return inPath
  }

  //····················································································································

  internal func buildOutlineViewDataSource (extension inFileExtension : String,
                                            alreadyLoadedDocuments inNames : Set <String>,
                                            _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    do{
      let fm = FileManager ()
    //--- Build part dictionary
      var partCountDictionary = [String : Int] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
        for f in files {
          if f.pathExtension == inFileExtension {
            let baseName = f.lastPathComponent.deletingPathExtension
            if let n = partCountDictionary [baseName] {
              partCountDictionary [baseName] = n + 1
            }else{
              partCountDictionary [baseName] = 1
            }
          }
        }
      }
    //--- Build data source array
      var partArray = [LibraryDialogItem] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
        for f in files {
          if f.pathExtension == inFileExtension {
            let fullpath = baseDirectory + "/" + f
            let baseName = f.lastPathComponent.deletingPathExtension
            let isDuplicated = (partCountDictionary [baseName] ?? 0) > 1
            let pathAsArray = f.deletingPathExtension.components (separatedBy: "/")
            enterPart (&partArray, pathAsArray, fullpath, isDuplicated, inNames.contains (baseName), inBuildPreviewShapeFunction)
          }
        }
      }
      partArray.recursiveSortUsingPartName ()
      self.mOutlineViewDataSource = partArray
    }catch (let error) {
      let alert = NSAlert (error: error)
      _ = alert.runModal ()
    }
  //---
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func enterPart (_ ioPartArray : inout [LibraryDialogItem],
                            _ inPathAsArray : [String],
                            _ inFullpath : String,
                            _ inIsDuplicated : Bool,
                            _ inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
  if inPathAsArray.count == 1 {
    ioPartArray.append (LibraryDialogItem (inPathAsArray [0], inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
  }else{
    var idx = 0
    var found = false
    while (idx < ioPartArray.count) && !found {
      found = ioPartArray [idx].mPartName == inPathAsArray [0]
      if !found {
        idx += 1
      }
    }
    if !found {
      ioPartArray.append (LibraryDialogItem (inPathAsArray [0], "", false, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
    }
    var pathAsArray = inPathAsArray
    pathAsArray.remove (at: 0)
    enterPart (&ioPartArray [idx].mChildren, pathAsArray, inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == LibraryDialogItem {

  //····················································································································

  mutating func recursiveSortUsingPartName () {
    self.sort (by: {$0.mPartName < $1.mPartName})
    for entry in self {
      entry.mChildren.recursiveSortUsingPartName ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class LibraryDialogItem : EBObject {

  var mChildren = [LibraryDialogItem] ()
  let mPartName : String
  let mIsDuplicated : Bool
  let mIsAlreadyLoaded : Bool
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mObjectImage : NSImage? = nil
  private var mBuildPreviewShapeFunction : (_ inRootObject : EBManagedObject?) -> NSImage?

  //····················································································································

  init (_ inPartName : String,
        _ inFullPath : String,
        _ inIsDuplicated : Bool,
        _ inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    mPartName = inPartName
    mFullPath = inFullPath
    mIsDuplicated = inIsDuplicated
    mIsAlreadyLoaded = inIsAlreadyLoaded
    mBuildPreviewShapeFunction = inBuildPreviewShapeFunction
    super.init ()
  }

  //····················································································································

  func statusString () -> String {
    if self.mFullPath == "" {
      return ""
    }else if self.mIsAlreadyLoaded {
      return "Already loaded"
    }else if self.mIsDuplicated {
      return "Duplicated"
    }else{
      switch self.partStatus {
      case .unknown :
        return "Unknown"
      case .ok :
        return "Ok"
      case .error :
        return "This part has error(s)"
      case .warning :
        return "This part has warning(s)"
      }
    }
  }

  //····················································································································

  func statusImage () -> NSImage? {
    if self.mFullPath == "" {
      return nil
    }else if self.mIsDuplicated || self.mIsAlreadyLoaded {
      return NSImage (named: NSImage.Name ("NSStatusUnavailable"))
    }else{
      switch self.partStatus {
      case .unknown :
        return NSImage (named: NSImage.Name ("NSStatusNone"))
      case .ok :
        return NSImage (named: NSImage.Name ("NSStatusAvailable"))
      case .error :
        return NSImage (named: NSImage.Name ("NSStatusUnavailable"))
      case .warning :
        return NSImage (named: NSImage.Name ("NSStatusPartiallyAvailable"))
      }
    }
  }

  //····················································································································

  var partStatus : MetadataStatus {
    var status = MetadataStatus.unknown
    if let s = self.mPartStatus {
      status = s
    }else if self.mFullPath != "" {
      (status, _) = try! metadataForFileAtPath (self.mFullPath)
    }
    self.mPartStatus = status
    return status
  }

 //····················································································································

  var image : NSImage {
    if let image = self.mObjectImage {
      return image
    }else{
      let image = self.buildImage ()
      self.mObjectImage = image
      return image
    }
  }

  //····················································································································

  private func buildImage () -> NSImage {
    var image : NSImage? = nil
    let fm = FileManager ()
    if let data = fm.contents (atPath: self.mFullPath) {
      do{
        let (_, _, rootObject) = try loadEasyBindingFile (nil, from: data)
        image = self.mBuildPreviewShapeFunction (rootObject)
      }catch let error {
        let alert = NSAlert (error: error)
        _ = alert.runModal ()
      }
    }
    return image ?? NSImage ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
