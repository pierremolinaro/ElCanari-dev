//
//  open-artwork-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor func openArtworkPanelInLibrary (windowForSheet inWindow : NSWindow?,
                                           validationButtonTitle inValidationButtonTitle : String,
                                           callBack inCallBack : @escaping (_ inURL : URL, _ inName : String) -> Void) {
  gOpenArtworkPanelInLibrary = OpenArtworkPanelInLibrary (
    windowForSheet: inWindow,
    validationButtonTitle: inValidationButtonTitle,
    callBack: inCallBack
  )
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gOpenArtworkPanelInLibrary : OpenArtworkPanelInLibrary? = nil

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class OpenArtworkPanelInLibrary : AutoLayoutTableViewDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (windowForSheet inWindow : NSWindow?,
        validationButtonTitle inValidationButtonTitle : String,
        callBack inCallBack : @escaping (_ inURL : URL, _ inName : String) -> Void) {
    self.mArtworkStatus = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .left)
    self.mArtworkPath = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .left)
    let panel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 680, height: 600),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
    self.mOkButton = AutoLayoutSheetDefaultOkButton (title: inValidationButtonTitle, size: .regular, sheet: panel)
 //--- No selected artwork message
    self.mNoSelectedArtworkMessage = AutoLayoutVerticalStackView ()
    _ = self.mNoSelectedArtworkMessage.appendFlexibleSpace ()
    _ = self.mNoSelectedArtworkMessage.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "No Selected Artwork", bold: true, size: .regular, alignment: .center))
    _ = self.mNoSelectedArtworkMessage.appendFlexibleSpace ()
  //--- Artwork detailled view
    self.mArtworkDetailView = AutoLayoutVerticalStackView ()
    _ = self.mArtworkDetailView.appendFlexibleSpace ()
    self.mArtworkTitle = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .center)
    _ = self.mArtworkDetailView.appendView (self.mArtworkTitle)
    self.mArtworkLayout = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .left)
    let layoutView = AutoLayoutHorizontalStackView ()
    _ = layoutView.appendView (AutoLayoutStaticLabel (title: "Layout", bold: false, size: .regular, alignment: .center))
    _ = layoutView.appendView (self.mArtworkLayout)
    _ = self.mArtworkDetailView.appendView (layoutView)
    _ = self.mArtworkDetailView.appendFlexibleSpace ()
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
            if f.pathExtension.lowercased () == ElCanariArtwork_EXTENSION {
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
          if f.pathExtension.lowercased() == ElCanariArtwork_EXTENSION {
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
    let mainView = AutoLayoutVerticalStackView ().set (margins: .large)
    let twoColumns = AutoLayoutHorizontalStackView ()
    _ = mainView.appendView (twoColumns)
  //--- Left column
    let leftColumn = AutoLayoutVerticalStackView ()
    self.mSearchField = AutoLayoutSearchField (width: 300, size: .regular).bind_value (preferences_artworkDialogFilterString_property, sendContinously: true)
    _ = leftColumn.appendView (self.mSearchField)
    _ = twoColumns.appendView (leftColumn)
    self.mTableView = AutoLayoutTableView (size: .small, addControlButtons: false)
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mFilteredTableViewSource.count ?? 0 },
      delegate: self
    )
    noteObjectAllocation (self)
  //--- Search field delegate
    self.mSearchField.setDelegate { [weak self] (_ inFilterString : String) in
      if let uwSelf = self {
        if inFilterString.isEmpty {
          uwSelf.mFilteredTableViewSource = uwSelf.mTableViewSource
        }else{
          uwSelf.mFilteredTableViewSource.removeAll ()
          let filter = inFilterString.uppercased ()
          // Swift.print ("Filter \(filter)")
          var currentSelectionFound = false
          for entry in uwSelf.mTableViewSource {
            let testedName = entry.mPartName.uppercased ()
            if testedName.contains (filter) {
              uwSelf.mFilteredTableViewSource.append (entry)
              if entry === uwSelf.mSelectedEntry {
                currentSelectionFound = true
              }
            }
          }
          if !currentSelectionFound {
            uwSelf.mSelectedEntry = nil
          }
        }
        uwSelf.mTableView.sortAndReloadData ()
      }
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
    _ = leftColumn.appendView (self.mTableView)
  //--- Right column
    _ = twoColumns.appendView (self.mNoSelectedArtworkMessage)
    _ = twoColumns.appendView (self.mArtworkDetailView)
  //--- Grid view (status, path)
    let gridView = AutoLayoutGridView2 ()
    _ = gridView.add (
      left: AutoLayoutStaticLabel (title: "Status", bold: false, size: .regular, alignment: .left),
      right: self.mArtworkStatus
    )
    _ = gridView.add (
      left: AutoLayoutStaticLabel (title: "Path", bold: false, size: .regular, alignment: .left),
      right: self.mArtworkPath
    )
    _ = mainView.appendView (gridView)
  //--- Last line (Cancel, Ok)
    let lastLine = AutoLayoutHorizontalStackView ()
    let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
    _ = lastLine.appendView (cancelButton)
    _ = lastLine.appendFlexibleSpace ()
    _ = lastLine.appendView (self.mOkButton)
    _ = mainView.appendView (lastLine)
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
      let response = NSApplication.shared.runModal (for: panel)
      if response == .stop {
        let entry = self.mFilteredTableViewSource [self.mTableView.selectedRow]
        inCallBack (URL (fileURLWithPath: entry.mFullPath), entry.mPartName)
      }
      DispatchQueue.main.async { gOpenArtworkPanelInLibrary = nil }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // AutoLayoutTableViewDelegate delegate implementation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_selectionDidChange (selectedRows inSelectedRows: IndexSet) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_indexesOfSelectedObjects () -> IndexSet {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_addEntry () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_removeSelectedEntries () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_beginSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_endSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension ApplicationDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class ArtworkDialogEntry {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mPartName : String
  let mIsDuplicated : Bool
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mArtworkRoot : ArtworkRoot? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inPartName : String,
        _ inFullPath : String,
        _ inIsDuplicated : Bool) {
    self.mPartName = inPartName
    self.mFullPath = inFullPath
    self.mIsDuplicated = inIsDuplicated
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
//    self.mArtworkRoot?.removeRecursivelyAllRelationsShips ()
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func partStatusOk () -> Bool {
//    if let s = try? self.partStatus () {
//      return s == .ok
//    }else{
//      return false
//    }
//  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 private func loadArtwork () {
   if self.mArtworkRoot == nil {
     let documentReadData = loadEasyBindingFile (fromURL: URL (fileURLWithPath: self.mFullPath))
     switch documentReadData {
     case .ok (let documentData) :
       if let root = documentData.documentRootObject as? ArtworkRoot {
         self.mArtworkRoot = root
       } // §
     case .readError (_) :
       () // §
     }
   }
 }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 func artworkTitle () -> String {
   self.loadArtwork ()
   if let artworkRoot = self.mArtworkRoot {
     return artworkRoot.title
   }else{
     return "?"
   }
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

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

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

}

//--------------------------------------------------------------------------------------------------
