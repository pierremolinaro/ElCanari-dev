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
  @IBOutlet private var mPartView : EBView?

  //····················································································································

  @objc private func cancelAction (_ inSender : Any?) {
    NSApp.abortModal ()
    self.mDialog?.orderOut (nil)
    self.mOutlineViewDataSource = []
    self.mOutlineView?.reloadData ()
    self.mPartView?.updateObjectDisplay ([])
  }

  //····················································································································

  @objc private func openAction (_ inSender : Any?) {
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
    self.mPartView?.updateObjectDisplay ([])
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
      self.mOpenButton?.isEnabled = selectedItem.mFullPath != ""
      self.mPartView?.updateObjectDisplay (selectedItem.shape)
    }else{
      self.mFullPathTextField?.stringValue = ""
      self.mStatusTextField?.stringValue = ""
      self.mOpenButton?.isEnabled = false
      self.mPartView?.updateObjectDisplay ([])
    }
  }

  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openSymbolInLibrary (_ inSender : Any?) {
  //--- Configure
    self.mFullPathTextField?.stringValue = ""
    self.mStatusTextField?.stringValue = ""
    self.mCancelButton?.target = self
    self.mCancelButton?.action = #selector (OpenInLibrary.cancelAction (_:))
    self.mOpenButton?.target = self
    self.mOpenButton?.action = #selector (OpenInLibrary.openAction (_:))
    self.mOpenButton?.isEnabled = false
    if let partView = self.mPartView {
      partView.mBackColor = g_Preferences!.symbolBackgroundColor
 //     partView.set (minimumRectangle: partView.bounds)
    }
    self.mOutlineView?.dataSource = self
    self.mOutlineView?.delegate = self
    self.buildOutlineViewDataSource ()
    self.mOutlineView?.reloadData ()
  //--- Dialog
    if let dialog = self.mDialog {
      let response = NSApp.runModal (for: dialog)
      if response == .stop {

      }
    }
  }

  //····················································································································

  private func buildOutlineViewDataSource () {
    do{
      let fm = FileManager ()
    //--- Build part dictionary
      var partCountDictionary = [String : Int] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = path + "/symbols"
        let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
        for f in files {
          if f.pathExtension == "ElCanariSymbol" {
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
        let baseDirectory = path + "/symbols"
        let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
        for f in files {
          if f.pathExtension == "ElCanariSymbol" {
            let fullpath = baseDirectory + "/" + f
            let baseName = f.lastPathComponent.deletingPathExtension
            let isDuplicated = (partCountDictionary [baseName] ?? 0) > 1
            let pathAsArray = f.deletingPathExtension.components (separatedBy: "/")
            enterPart (&partArray, pathAsArray, fullpath, isDuplicated)
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
                            _ inIsDuplicated : Bool) {
  if inPathAsArray.count == 1 {
    ioPartArray.append (LibraryDialogItem (inPathAsArray [0], inFullpath, inIsDuplicated))
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
      ioPartArray.append (LibraryDialogItem (inPathAsArray [0], "", false))
    }
    var pathAsArray = inPathAsArray
    pathAsArray.remove (at: 0)
    enterPart (&ioPartArray [idx].mChildren, pathAsArray, inFullpath, inIsDuplicated)
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
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mObjectDisplay = [EBShape] ()

  //····················································································································

  init (_ inPartName : String, _ inFullPath : String, _ inIsDuplicated : Bool) {
    mPartName = inPartName
    mFullPath = inFullPath
    mIsDuplicated = inIsDuplicated
    super.init ()
  }

  //····················································································································

  func statusString () -> String {
    if self.mFullPath == "" {
      return ""
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
    }else if self.mIsDuplicated {
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

  var shape : [EBShape] { return self.mObjectDisplay }

  //····················································································································

  var partStatus : MetadataStatus {
    var status = MetadataStatus.unknown
    if let s = self.mPartStatus {
      status = s
    }else if self.mFullPath != "" {
      let fm = FileManager ()
      if let data = fm.contents (atPath: self.mFullPath) {
        do{
          let (metadataStatus, _, rootObject) = try loadEasyBindingFile (nil, from: data)
          if let s = MetadataStatus (rawValue: Int (metadataStatus)) {
            status = s
          }
          if let symbolRoot = rootObject as? SymbolRoot {
            var symbolShape = [EBShape] ()
            for object in symbolRoot.symbolObjects_property.propval {
              if let shape = object.objectDisplay {
                symbolShape.append (shape)
              }
            }
            self.mObjectDisplay = symbolShape
          }
        }catch let error {
          let alert = NSAlert (error: error)
          _ = alert.runModal ()
        }
      }
    }
    self.mPartStatus = status
    return status
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
