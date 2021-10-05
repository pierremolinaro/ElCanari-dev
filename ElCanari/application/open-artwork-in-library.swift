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

fileprivate class OpenArtworkPanelInLibrary : AutoLayoutTableViewDelegate, EBUserClassNameProtocol {

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
    self.mOkButton = AutoLayoutSheetDefaultOkButton (title: inValidationButtonTitle, size: .regular, sheet: panel, isInitialFirstResponder: true)
 //--- No selected artwork message
    self.mNoSelectedArtworkMessage = AutoLayoutVerticalStackView ()
    self.mNoSelectedArtworkMessage.appendFlexibleSpace ()
    self.mNoSelectedArtworkMessage.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "No Selected Artwork", bold: true, size: .regular))
    self.mNoSelectedArtworkMessage.appendFlexibleSpace ()
  //--- Artwork detailled view
    self.mArtworkDetailView = AutoLayoutVerticalStackView ()
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
            if f.pathExtension == "ElCanariArtwork" {
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
          if f.pathExtension == "ElCanariArtwork" {
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
    let filterTextField = AutoLayoutSearchField (width: 300, size: .regular)
    leftColumn.appendView (filterTextField)
    leftColumn.appendFlexibleSpace ()
    twoColumns.appendView (leftColumn)
    self.mTableView = AutoLayoutTableView (size: .small, addControlButtons: false)
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      delegate: self
    )
    noteObjectAllocation (self)
  //--- Configure table view
    self.mTableView.addColumn_NSImage (
      valueGetterDelegate: { [weak self] in return self?.mTableViewSource [$0].statusImage () ?? NSImage () },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Status",
      minWidth: 48,
      maxWidth: 48,
      headerAlignment: .center,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mTableViewSource [$0].mPartName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mTableViewSource.sort { ascending ? ($0.mPartName < $1.mPartName) : ($0.mPartName > $1.mPartName) }
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
    let gridView = AutoLayoutTwoColumnsGridView ()
    _ = gridView.addFirstBaseLineAligned (
      left: AutoLayoutStaticLabel (title: "Status", bold: false, size: .regular),
      right: self.mArtworkStatus
    )
    _ = gridView.addFirstBaseLineAligned (
      left: AutoLayoutStaticLabel (title: "Path", bold: false, size: .regular),
      right: self.mArtworkPath
    )
    mainView.appendView (gridView)
  //--- Last line (Cancel, Ok)
    let lastLine = AutoLayoutHorizontalStackView ()
    let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false)
    lastLine.appendView (cancelButton)
    lastLine.appendFlexibleSpace ()
    lastLine.appendView (self.mOkButton)
    mainView.appendView (lastLine)
  //--- Set autolayout view to panel
    panel.contentView = mainView
  //--- Sheet or dialog ?
    if let window = inWindow {
      window.beginSheet (panel) { (inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop {
          let entry = self.mTableViewSource [self.mTableView.selectedRow]
          inCallBack (URL (fileURLWithPath: entry.mFullPath), entry.mPartName)
        }
        DispatchQueue.main.async { gOpenArtworkPanelInLibrary = nil }
      }
    }else{ // Dialog
      let response = NSApp.runModal (for: panel)
      if response == .stop {
        let entry = self.mTableViewSource [self.mTableView.selectedRow]
        inCallBack (URL (fileURLWithPath: entry.mFullPath), entry.mPartName)
      }
      DispatchQueue.main.async { gOpenArtworkPanelInLibrary = nil }
    }
  }

  //····················································································································

  deinit {
    self.mOkButton.ebCleanUp ()
    noteObjectDeallocation (self)
  }

  //····················································································································

  private var mTableViewSource = [ArtworkDialogEntry] ()
  private var mArtworkStatus : AutoLayoutStaticLabel
  private var mArtworkPath : AutoLayoutStaticLabel
  private var mOkButton : AutoLayoutSheetDefaultOkButton
  private var mNoSelectedArtworkMessage : AutoLayoutVerticalStackView
  private var mArtworkDetailView : AutoLayoutVerticalStackView
  private var mArtworkTitle : AutoLayoutStaticLabel
  private var mArtworkLayout : AutoLayoutStaticLabel
  private var mTableView : AutoLayoutTableView

  //····················································································································
  // AutoLayoutTableViewDelegate delegate implementation
  //····················································································································

  func rowCount() -> Int {
    return self.mTableViewSource.count
  }

  //····················································································································

  func tableViewSelectionDidChange (selectedRows inSelectedRows: IndexSet) {
    if let entryIndex = inSelectedRows.first, inSelectedRows.count == 1 {
      let selectedEntry = self.mTableViewSource [entryIndex]
      self.mArtworkStatus.stringValue = selectedEntry.statusString ()
      self.mArtworkPath.stringValue = selectedEntry.mFullPath
      self.mArtworkTitle.stringValue = selectedEntry.artworkTitle ()
      self.mArtworkLayout.stringValue = selectedEntry.artworkLayoutString ()
      self.mOkButton.enable (fromEnableBinding: true)
      self.mNoSelectedArtworkMessage.isHidden = true
      self.mArtworkDetailView.isHidden = false
    }else{
      self.mArtworkStatus.stringValue = ""
      self.mArtworkPath.stringValue = ""
      self.mOkButton.enable (fromEnableBinding: false)
      self.mNoSelectedArtworkMessage.isHidden = false
      self.mArtworkDetailView.isHidden = true
    }
  }

  //····················································································································

  func indexesOfSelectedObjects () -> IndexSet {
    return IndexSet ()
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

class ArtworkDialogEntry : EBUserClassNameProtocol {

  //····················································································································

  let mPartName : String
  let mIsDuplicated : Bool
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mArtworkRoot : ArtworkRoot? = nil
//  private var mObjectImage : NSImage? = nil

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
    if self.mFullPath == "" {
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
    if self.mFullPath == "" {
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

//  var image : NSImage {
//    if let image = self.mObjectImage {
//      return image
//    }else{
//      let image = self.buildImage ()
//      self.mObjectImage = image
//      return image
//    }
//  }


}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
