//
//  open-artwork-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func openArtworkPanelInLibrary (windowForSheet inWindow : NSWindow?,
                                validationButtonTitle inValidationButtonTitle : String,
                                callBack inCallBack : @escaping (_ inURL : URL, _ inName : String) -> Void) {
  gOpenArtworkPanelInLibrary = OpenArtworkPanelInLibrary (
    windowForSheet: inWindow,
    validationButtonTitle: inValidationButtonTitle,
    callBack: inCallBack
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate var gOpenArtworkPanelInLibrary : OpenArtworkPanelInLibrary? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class OpenArtworkPanelInLibrary : AutoLayoutTableViewDelegate, EBUserClassNameProtocol {

  //····················································································································

  init (windowForSheet inWindow : NSWindow?,
        validationButtonTitle inValidationButtonTitle : String,
        callBack inCallBack : @escaping (_ inURL : URL, _ inName : String) -> Void) {
    self.mArtworkStatus = AutoLayoutStaticLabel (title: "", bold: false, size: .regular).set (alignment: .left).expandableWidth ()
    self.mArtworkPath = AutoLayoutStaticLabel (title: "", bold: false, size: .regular).set (alignment: .left).expandableWidth ()
    let panel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 680, height: 600),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
    self.mOkButton = AutoLayoutSheetDefaultOkButton (title: inValidationButtonTitle, size: .regular, sheet: panel)
 //--- No selected artwork message
    self.mNoSelectedArtworkMessage = AutoLayoutVerticalStackView ()
    self.mNoSelectedArtworkMessage.appendFlexibleSpace ()
    self.mNoSelectedArtworkMessage.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "No Selected Artwork", bold: true, size: .regular))
    self.mNoSelectedArtworkMessage.appendFlexibleSpace ()
  //--- Artwork detailled view
    self.mArtworkDetailView = AutoLayoutVerticalStackView ()
    self.mArtworkDetailView.appendFlexibleSpace ()
    self.mArtworkTitle = AutoLayoutStaticLabel (title: "", bold: true, size: .regular).set (alignment: .center).expandableWidth ()
    self.mArtworkDetailView.appendView (self.mArtworkTitle)
    self.mArtworkLayout = AutoLayoutStaticLabel (title: "", bold: true, size: .regular).set (alignment: .left).expandableWidth ()
    let layoutView = AutoLayoutHorizontalStackView ()
    layoutView.appendView (AutoLayoutStaticLabel (title: "Layout", bold: false, size: .regular))
    layoutView.appendView (self.mArtworkLayout)
    self.mArtworkDetailView.appendView (layoutView)
    self.mArtworkDetailView.appendFlexibleSpace ()
  //--- Table View
  //--- Build part counted set
    var partCountDictionary = [String : Int] ()
    do{
      let fm = FileManager ()
      for path in existingLibraryPathArray () {
        let baseDirectory = artworkLibraryPathForPath (path)
        var isDirectory : ObjCBool = false
        if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
          let files = try? fm.subpathsOfDirectory (atPath: baseDirectory)
          for f in files ?? [] {
            if f.pathExtension.lowercased() == "elcanariartwork" {
              let baseName = f.lastPathComponent.deletingPathExtension
              partCountDictionary [baseName] = partCountDictionary [baseName, default: 0] + 1
            }
          }
        }
      }
    }
  //--- Build data source array
    for path in existingLibraryPathArray () {
      let fm = FileManager ()
      let baseDirectory = artworkLibraryPathForPath (path)
      var isDirectory : ObjCBool = false
      if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
        let files = try? fm.subpathsOfDirectory (atPath: baseDirectory)
        for f in files ?? [] {
          if f.pathExtension.lowercased() == "elcanariartwork" {
            let fullpath = baseDirectory + "/" + f
            let baseName = f.lastPathComponent.deletingPathExtension
            let isDuplicated : Bool = partCountDictionary [baseName, default: 0] > 1
            let entry = ArtworkDialogEntry (baseName, fullpath, isDuplicated)
            self.mTableViewSource.append (entry)
          }
        }
      }
    }
  //--- Build Panel
    panel.title = "Open Artwork in Library"
    panel.hasShadow = true
  //--- Main view
    let mainView = AutoLayoutVerticalStackView ().set (margins: 20)
    let twoColumns = AutoLayoutHorizontalStackView ()
    mainView.appendView (twoColumns)
  //--- Left column
    let leftColumn = AutoLayoutVerticalStackView ()
    self.mSearchField = AutoLayoutSearchField (width: 300, size: .regular).bind_value (preferences_artworkDialogFilterString_property, sendContinously: true)
    leftColumn.appendView (self.mSearchField)
    twoColumns.appendView (leftColumn)
    self.mTableView = AutoLayoutTableView (size: .small, addControlButtons: false)
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mFilteredTableViewSource.count ?? 0 },
      delegate: self
    )
    noteObjectAllocation (self)
  //--- Search field delegate
    self.mSearchField.setDelegate { (_ inFilterString : String) in
      if inFilterString.isEmpty {
        self.mFilteredTableViewSource = self.mTableViewSource
      }else{
        self.mFilteredTableViewSource.removeAll ()
        let filter = inFilterString.uppercased ()
        // Swift.print ("Filter \(filter)")
        var currentSelectionFound = false
        for entry in self.mTableViewSource {
          let testedName = entry.mPartName.uppercased ()
          if testedName.contains (filter) {
            self.mFilteredTableViewSource.append (entry)
            if entry === self.mSelectedEntry {
              currentSelectionFound = true
            }
          }
          // Swift.print ("  Entry \(entry.mPartName) -> \(testedName) : \(testedName.contains (filter))")
        }
        if !currentSelectionFound {
          self.mSelectedEntry = nil
        }
      }
      self.mTableView.sortAndReloadData ()
    }
  //--- Configure table view
    self.mTableView.addColumn_NSImage (
      valueGetterDelegate: { [weak self] in return self?.mFilteredTableViewSource [$0].statusImage () ?? NSImage () },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Status",
      minWidth: 48,
      maxWidth: 48,
      headerAlignment: .center,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mFilteredTableViewSource [$0].mPartName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mFilteredTableViewSource.sort { ascending ? ($0.mPartName < $1.mPartName) : ($0.mPartName > $1.mPartName) }
      },
      title: "Artwork Name",
      minWidth: 80,
      maxWidth: 1000,
      headerAlignment: .center,
      contentAlignment: .left
    )
    leftColumn.appendView (self.mTableView)
  //--- Right column
    twoColumns.appendView (self.mNoSelectedArtworkMessage)
    twoColumns.appendView (self.mArtworkDetailView)
  //--- Grid view (status, path)
    let gridView = AutoLayoutGridView2 ()
    _ = gridView.addFirstBaseLineAligned (
      left: AutoLayoutStaticLabel (title: "Status", bold: false, size: .regular).set (alignment: .left),
      right: self.mArtworkStatus
    )
    _ = gridView.addFirstBaseLineAligned (
      left: AutoLayoutStaticLabel (title: "Path", bold: false, size: .regular).set (alignment: .left),
      right: self.mArtworkPath
    )
    mainView.appendView (gridView)
  //--- Last line (Cancel, Ok)
    let lastLine = AutoLayoutHorizontalStackView ()
    let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
    lastLine.appendView (cancelButton)
    lastLine.appendFlexibleSpace ()
    lastLine.appendView (self.mOkButton)
    mainView.appendView (lastLine)
  //--- Set autolayout view to panel
    panel.contentView = AutoLayoutWindowContentView (view: mainView)
  //--- Sheet or dialog ?
    if let window = inWindow {
      window.beginSheet (panel) { (inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop {
          let entry = self.mFilteredTableViewSource [self.mTableView.selectedRow]
          inCallBack (URL (fileURLWithPath: entry.mFullPath), entry.mPartName)
        }
        DispatchQueue.main.async { gOpenArtworkPanelInLibrary = nil }
      }
    }else{ // Dialog
      let response = NSApp.runModal (for: panel)
      if response == .stop {
        let entry = self.mFilteredTableViewSource [self.mTableView.selectedRow]
        inCallBack (URL (fileURLWithPath: entry.mFullPath), entry.mPartName)
      }
      DispatchQueue.main.async { gOpenArtworkPanelInLibrary = nil }
    }
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  private var mTableViewSource = [ArtworkDialogEntry] ()
  private var mFilteredTableViewSource = [ArtworkDialogEntry] ()
  private var mSearchField : AutoLayoutSearchField
  private var mArtworkStatus : AutoLayoutStaticLabel
  private var mArtworkPath : AutoLayoutStaticLabel
  private var mOkButton : AutoLayoutSheetDefaultOkButton
  private var mNoSelectedArtworkMessage : AutoLayoutVerticalStackView
  private var mArtworkDetailView : AutoLayoutVerticalStackView
  private var mArtworkTitle : AutoLayoutStaticLabel
  private var mArtworkLayout : AutoLayoutStaticLabel
  private var mTableView : AutoLayoutTableView
  private var mSelectedEntry : ArtworkDialogEntry? = nil

  //····················································································································
  // AutoLayoutTableViewDelegate delegate implementation
  //····················································································································

  func tableViewSelectionDidChange (selectedRows inSelectedRows: IndexSet) {
    if let entryIndex = inSelectedRows.first, inSelectedRows.count == 1 {
      let selectedEntry = self.mFilteredTableViewSource [entryIndex]
      self.mArtworkStatus.stringValue = selectedEntry.statusString ()
      self.mArtworkPath.stringValue = selectedEntry.mFullPath
      self.mArtworkPath.toolTip = selectedEntry.mFullPath
      self.mArtworkTitle.stringValue = selectedEntry.artworkTitle ()
      self.mArtworkLayout.stringValue = selectedEntry.artworkLayoutString ()
      self.mOkButton.enable (fromEnableBinding: true, nil)
      self.mNoSelectedArtworkMessage.isHidden = true
      self.mArtworkDetailView.isHidden = false
      self.mSelectedEntry = selectedEntry
    }else{
      self.mArtworkStatus.stringValue = ""
      self.mArtworkPath.stringValue = ""
      self.mArtworkPath.toolTip = ""
      self.mOkButton.enable (fromEnableBinding: false, nil)
      self.mNoSelectedArtworkMessage.isHidden = false
      self.mArtworkDetailView.isHidden = true
      self.mSelectedEntry = nil
    }
  }

  //····················································································································

  func indexesOfSelectedObjects () -> IndexSet {
    var indexSet = IndexSet ()
    var idx = 0
    for object in self.mFilteredTableViewSource {
      if object === self.mSelectedEntry {
        indexSet.insert (idx)
      }
      idx += 1
    }
    return indexSet
  }

  //····················································································································

  func addEntry () {
  }

  //····················································································································

  func removeSelectedEntries () {
  }

  //····················································································································

  func beginSorting () {
  }

  //····················································································································

  func endSorting () {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func actionOpenArtworkInLibrary (_ inSender : Any?) {
    openArtworkPanelInLibrary (
      windowForSheet: nil,
      validationButtonTitle: "Open",
      callBack: { (_ inURL : URL, _ inName : String) -> Void in
        let dc = NSDocumentController.shared
        dc.openDocument (withContentsOf: inURL, display: true) { (_ : NSDocument?, _ : Bool, _ : Error?) in }
      }
    )
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class ArtworkDialogEntry : EBUserClassNameProtocol {

  //····················································································································

  let mPartName : String
  let mIsDuplicated : Bool
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mArtworkRoot : ArtworkRoot? = nil

  //····················································································································

  init (_ inPartName : String,
        _ inFullPath : String,
        _ inIsDuplicated : Bool) {
    self.mPartName = inPartName
    self.mFullPath = inFullPath
    self.mIsDuplicated = inIsDuplicated
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    self.mArtworkRoot?.removeRecursivelyAllRelationsShips ()
    noteObjectDeallocation (self)
  }

  //····················································································································

  func statusString () -> String {
    if self.mFullPath.isEmpty {
      return ""
    }else if self.mIsDuplicated {
      return "Duplicated"
    }else{
      do{
        switch try self.partStatus () {
        case .unknown :
          return "Unknown"
        case .ok :
          return "Ok"
        case .error :
          return "This part has error(s)"
        case .warning :
          return "This part has warning(s)"
        }
      }catch _ {
        return "This part cannot be read"
      }
    }
  }

  //····················································································································

  func statusImage () -> NSImage? {
    if self.mFullPath.isEmpty {
      return nil
    }else if self.mIsDuplicated {
      return NSImage.statusError
    }else{
      do{
      switch try self.partStatus () {
        case .unknown :
          return NSImage.statusNone
        case .ok :
          return NSImage.statusSuccess
        case .error :
          return NSImage.statusError
        case .warning :
          return NSImage.statusWarning
        }
      }catch _ {
        return NSImage (named: NSImage.Name ("exclamation"))
      }
    }
  }

  //····················································································································

  func partStatus () throws -> MetadataStatus {
    if let s = self.mPartStatus {
      return s
    }else if self.mFullPath != "" {
      self.mPartStatus = .error
      let metadata = try getFileMetadata (atPath: self.mFullPath)
      self.mPartStatus = metadata.metadataStatus
      return metadata.metadataStatus
    }else{
      return .error
    }
  }

  //····················································································································

  func partStatusOk () -> Bool {
    if let s = try? self.partStatus () {
      return s == .ok
    }else{
      return false
    }
  }

 //····················································································································

 private func loadArtwork () {
   if self.mArtworkRoot == nil,
         let documentData = try? loadEasyBindingFile (fromURL: URL (fileURLWithPath: self.mFullPath)),
         let root = documentData.documentRootObject as? ArtworkRoot {
     self.mArtworkRoot = root
   }
 }

 //····················································································································

 func artworkTitle () -> String {
   self.loadArtwork ()
   if let artworkRoot = self.mArtworkRoot {
     return artworkRoot.title
   }else{
     return "?"
   }
 }
 //····················································································································

 func artworkLayoutString () -> String {
   self.loadArtwork ()
   if let artworkRoot = self.mArtworkRoot {
     switch artworkRoot.layerConfiguration {
     case .twoLayers  : return "2 layers"
     case .fourLayers : return "4 layers"
     case .sixLayers  : return "6 layers"
     }
   }else{
     return "?"
   }
 }

 //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
