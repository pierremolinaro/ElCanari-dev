//
//  OpenInLibrary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

fileprivate let CATEGORY_SUFFIX = " ✸"

//--------------------------------------------------------------------------------------------------

@MainActor class OpenInLibrary : AutoLayoutTableViewDelegate, Sendable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final let mWindow : NSWindow

  private final let mCancelButton : AutoLayoutSheetCancelButton
  private final let mOpenButton : AutoLayoutButton

  private final let mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
  private final let mStatusTextField = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .left)
  private final let mCategoryTextField = AutoLayoutStaticLabel (title: "—", bold: false, size: .regular, alignment: .left)
  private final let mFullPathTextField = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .left)
  private final var mPartImage = AutoLayoutImageObserverView (width: 400)
  private final let mNoSelectedPartTextField = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .center)
  private final let mNoSelectedPartView = AutoLayoutVerticalStackView ()
  private final let mSearchField = AutoLayoutSearchField (width: 300, size: .regular)
  private final let mCategoryPullDownButton = AutoLayoutPullDownButton (title: "Category", size: .regular)
  private final let mSubCategoryPullDownButton = AutoLayoutPullDownButton (title: "☜", size: .regular)

  private final let mSelectedCategory = EBStandAloneProperty <String> ("")
  private final let mSelectedCategoryTextField = AutoLayoutLabel (bold: false, size: .regular)
    .set (minWidth: 100)
    .set (alignment: .left)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mTableViewDataSource = [OpenInLibraryDialogFlatItem] ()
  private final var mTableViewFilteredDataSource = [OpenInLibraryDialogFlatItem] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
  //--- Dialog
    self.mWindow = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 700, height: 600),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    self.mWindow.isReleasedWhenClosed = false // Close button just hides the window, but do not release it
    self.mWindow.setFrameAutosaveName ("OpenInLibraryWindowFrame")
    self.mWindow.hasShadow = true
    self.mCancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
    self.mOpenButton = AutoLayoutButton (title: "Open", size: .regular)
//    if let buttonCell = self.mOpenButton.cell as? NSButtonCell {
//      DispatchQueue.main.async { self.mWindow.defaultButtonCell = buttonCell }
//    }

  //--- First column
    let firstColumn = AutoLayoutVerticalStackView ().appendView (self.mSearchField)
    if self.categoryKey != nil {
      _ = firstColumn.append (hStackWith: [self.mCategoryPullDownButton, self.mSelectedCategoryTextField, self.mSubCategoryPullDownButton])
    }
    self.mSubCategoryPullDownButton.isHidden = true
    _ = firstColumn.appendView (self.mTableView)
    _ = self.mSelectedCategoryTextField.bind_title (self.mSelectedCategory)
  //--- Second Column
    _ = self.mNoSelectedPartView.appendFlexibleSpace ()
    _ = self.mNoSelectedPartView.appendViewSurroundedByFlexibleSpaces (self.mNoSelectedPartTextField)
    _ = self.mNoSelectedPartView.appendFlexibleSpace ()
  //---
    let topView = AutoLayoutHorizontalStackView ()
          .appendView (firstColumn)
          .appendView (self.mNoSelectedPartView)
          .appendView (self.mPartImage)
  //--- Add view
    let mainView = AutoLayoutVerticalStackView ().set (margins: .large).appendView (topView)
  //--- Grid view: status and path
    let gridView = AutoLayoutVerticalStackView ().append (
      left: AutoLayoutStaticLabel (title: "Status:", bold: false, size: .regular, alignment: .right),
      right: self.mStatusTextField
    )
    if self.categoryKey != nil {
      _ = gridView.append (
        left: AutoLayoutStaticLabel (title: "Category:", bold: false, size: .regular, alignment: .right).notExpandableWidth (),
        right: self.mCategoryTextField
      )
    }
    _ = gridView.append (
      left: AutoLayoutStaticLabel (title: "Path:", bold: false, size: .regular, alignment: .right),
      right: self.mFullPathTextField
    )
    _ = mainView.appendView (gridView)
  //--- Bottom view
    _ = mainView.append (hStackWith: [self.mCancelButton, nil, self.mOpenButton])
  //--- Set content view
    self.mWindow.setContentView (mainView)
    _ = self.mOpenButton.respondsToValidationKeyDown (self.mWindow)
  //--- Configure table view
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mTableViewFilteredDataSource.count ?? 0 },
      delegate: self
    )
    self.mTableView.addColumn_NSImage (
      valueGetterDelegate: { [weak self] in self?.mTableViewFilteredDataSource [$0].statusImage () },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Status",
      minWidth: 50,
      maxWidth: 50,
      headerAlignment: .left,
      contentAlignment: .center
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in self?.mTableViewFilteredDataSource [$0].mPartName },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Name",
      minWidth: 250,
      maxWidth: 2_000,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //---
    _ = self.mSearchField.setClosureAction { [weak self] in self?.filterAction (nil) }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final func configureWith (alreadyLoadedDocuments inNames : Set <String>) {
    self.mNoSelectedPartTextField.stringValue = self.noPartMessage ()
    self.mOpenButton.isEnabled = false
    self.mPartImage.image = nil
    self.mPartImage.isHidden = true
    self.mNoSelectedPartView.isHidden = false
    self.buildDataSource (alreadyLoadedDocuments: inNames)
    self.mTableView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func populateCategoryPopUpButton (withCategoryNameSet inCategoryNameSet : Set <String>) {
  //--- Sort
    let sortedCategoryArray = Array (inCategoryNameSet).sorted {
      $0.lowercased () < $1.lowercased ()
    }
  //---
    var dict = [String : [(String, String)]] () // FirstName : (secondName, representedObject)
    for str in sortedCategoryArray {
      let names = str.split (separator: " ", maxSplits: 1)
      let firstName = String (names [0])
      let secondName = (names.count > 1) ? String (names [1]) : "—"
      dict [firstName] = (dict [firstName] ?? []) + [(secondName, str)]
    }
  //--- Populate pull down button
    var foundCurrentSelectedCategory = false
    while self.mCategoryPullDownButton.numberOfItems > 1 {
      self.mCategoryPullDownButton.removeItem (at: self.mCategoryPullDownButton.numberOfItems - 1)
    }
  //--- First item : all
    self.mCategoryPullDownButton.addItem (withItalicTitle: "— all —")
    if let item = self.mCategoryPullDownButton.lastItem {
      item.representedObject = CategoryMenuItemRepresentedObject (
        category: "",
        subCategories: []
      )
      item.action = #selector (Self.categoryPullDownButtonAction (_:))
      item.target = self
    }
  //--- Enumerate category dictionary entries
    for firstName in dict.keys.sorted (by: { $0.lowercased () < $1.lowercased () }) {
      let subCategoryArray : [(String, String)] = dict [firstName]!.sorted { $0.0.lowercased () < $1.0.lowercased () }
      if subCategoryArray.count == 1 {
        let category = subCategoryArray [0].1
        if category == self.mSelectedCategory.propval {
          foundCurrentSelectedCategory = true
        }
        self.mCategoryPullDownButton.addItem (withTitle: category)
        if let item = self.mCategoryPullDownButton.lastItem {
          item.representedObject = CategoryMenuItemRepresentedObject (
            category: category,
            subCategories: subCategoryArray
          )
          item.action = #selector (Self.categoryPullDownButtonAction (_:))
          item.target = self
        }
      }else{
        let submenu = NSMenu ()
        submenu.autoenablesItems = false
        for (secondName, category) in subCategoryArray {
          if category == self.mSelectedCategory.propval {
            foundCurrentSelectedCategory = true
          }
          let menuItem = NSMenuItem (
            title: secondName,
            action: #selector (Self.categoryPullDownButtonAction (_:)),
            keyEquivalent: ""
          )
          menuItem.target = self
          menuItem.representedObject = CategoryMenuItemRepresentedObject(
            category: category,
            subCategories: subCategoryArray
          )
          submenu.addItem (menuItem)
        }
        let title = firstName + CATEGORY_SUFFIX
        if title == self.mSelectedCategory.propval {
          foundCurrentSelectedCategory = true
        }
        self.mCategoryPullDownButton.addItem (withTitle: firstName)
        if let item = self.mCategoryPullDownButton.lastItem {
          item.submenu = submenu
          item.representedObject = CategoryMenuItemRepresentedObject (
            category: title,
            subCategories: subCategoryArray
          )
          item.action = #selector (Self.categoryPullDownButtonAction (_:))
          item.target = self
        }
      }
    }
    if !foundCurrentSelectedCategory {
      self.mSelectedCategory.setProp ("")
    }
  //--- Update part display
    for item in self.mTableViewDataSource {
      item.updateFromFile ()
    }
  //---
    self.filterAction (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Load document, displayed as sheet
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func loadDocumentFromLibrary (windowForSheet inWindow : NSWindow,
                                      alreadyLoadedDocuments inNames : Set <String>,
                                      callBack inCallBack : @MainActor @escaping (_ inData : Data, _ inName : String) -> Bool,
                                      postAction inPostAction : Optional <@MainActor () -> Void>) {
  //--- Configure
    self.configureWith (alreadyLoadedDocuments: inNames)
    self.mOpenButton.setClosureAction { [weak self] in
      self?.sheetWindowOpenDocumentButtonAction (callBack: inCallBack, postAction: inPostAction)
    }
  //--- Dialog
    inWindow.beginSheet (self.mWindow)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func sheetWindowOpenDocumentButtonAction (
        callBack inCallBack : @MainActor @escaping (_ inData : Data, _ inName : String) -> Bool,
        postAction inPostAction : Optional <@MainActor () -> Void>) {
    let selectedRow = self.mTableView.selectedRow
    if selectedRow >= 0 {
      let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
      if selectedItem.mFullPath != "" {
        let fm = FileManager ()
        if let data = fm.contents (atPath: selectedItem.mFullPath) {
          let ok = inCallBack (data, selectedItem.mFullPath.lastPathComponent.deletingPathExtension)
          if ok {
            inPostAction? ()
          }
        }
      }
    //--- Update part display
      for item in self.mTableViewDataSource {
        item.updateFromFile ()
      }
    //---
      self.filterAction (nil)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Open document in library, displayed as regular window
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func openDocumentInLibrary (windowTitle inTitle : String) {
  //--- Configure
    self.mWindow.title = inTitle
    self.configureWith (alreadyLoadedDocuments: [])
    self.mOpenButton.setClosureAction { [weak self] in
      self?.regularWindowOpenDocumentButtonAction ()
    }
  //---
    self.mWindow.makeKeyAndOrderFront (nil)
  //--- Par défaut, le TextField de recherche est activé, ce qui inhibe l'action par
  // de validation du bouton par défaut
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final func removeAllEntries () {
    self.mTableViewDataSource = []
    self.mTableViewFilteredDataSource = []
    self.mTableView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func regularWindowOpenDocumentButtonAction () {
    let selectedRow = self.mTableView.selectedRow
    if selectedRow >= 0 {
      let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
      if selectedItem.mFullPath != "" {
        let dc = NSDocumentController.shared
        let url = URL (fileURLWithPath: selectedItem.mFullPath)
        dc.openDocument (withContentsOf: url, display: true) {
          (document : NSDocument?, alreadyOpen : Bool, error : Error?) in
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) { // Abstract method
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func noPartMessage () -> String { // Abstract method
    return "?"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var categoryKey : String? { nil }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func partLibraryPathForPath (_ inPath : String) -> String {  // Abstract method
    return inPath
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func buildTableViewDataSource (extension inFileExtension : String,
                                       alreadyLoadedDocuments inNames : Set <String>,
                                       _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    do{
      let fm = FileManager ()
    //--- Build part dictionary
      var partCountDictionary = [String : Int] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        var isDirectory : ObjCBool = false
        if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
          let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
          for f in files {
            if f.pathExtension.lowercased() == inFileExtension {
              let baseName = f.lastPathComponent.deletingPathExtension
              partCountDictionary [baseName] = partCountDictionary [baseName, default: 0] + 1
            }
          }
        }
      }
    //--- Build data source arraies
      var tableViewDataSource = [OpenInLibraryDialogFlatItem] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        var isDirectory : ObjCBool = false
        if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
          let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
          for f in files {
            if f.pathExtension.lowercased () == inFileExtension {
              let fullpath = baseDirectory + "/" + f
              let baseName = f.lastPathComponent.deletingPathExtension
              let isDuplicated : Bool = partCountDictionary [baseName, default: 0] > 1
              let pathAsArray = f.deletingPathExtension.components (separatedBy: "/")
              tableViewDataSource.enterPart (
                pathComponentArray: pathAsArray,
                fullPath: fullpath,
                duplicated: isDuplicated,
                alreadyLoaded: inNames.contains (baseName),
                inBuildPreviewShapeFunction
              )
            }
          }
        }
      }
      self.mTableViewDataSource = tableViewDataSource
      self.filterAction (nil)
    }catch (let error) {
      let alert = NSAlert (error: error)
      _ = alert.runModal ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   AutoLayoutTableViewDelegate protocol methods
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_selectionDidChange (selectedRows inSelectedRows : IndexSet) {
    let selectedRow = self.mTableView.selectedRow
    if selectedRow >= 0 {
      let selectedPart = self.mTableViewFilteredDataSource [selectedRow]
      self.mStatusTextField.stringValue = selectedPart.statusString ()
      self.mCategoryTextField.stringValue = selectedPart.partCategory (self.categoryKey) ?? ""
      self.mFullPathTextField.stringValue = selectedPart.mFullPath
      self.mOpenButton.isEnabled = true
      self.mPartImage.image = selectedPart.image
      self.mPartImage.isHidden = false
      self.mNoSelectedPartView.isHidden = true
    }else{
      self.mStatusTextField.stringValue = "—"
      self.mCategoryTextField.stringValue = "—"
      self.mFullPathTextField.stringValue = "—"
      self.mOpenButton.isEnabled = false
      self.mPartImage.image = nil
      self.mPartImage.isHidden = true
      self.mNoSelectedPartView.isHidden = false
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_indexesOfSelectedObjects () -> IndexSet {
    return .init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_addEntry () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_removeSelectedEntries () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_beginSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_endSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SEARCH FIELD ACTION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func categoryPullDownButtonAction (_ inSender : Any?) {
    if let menuItem = inSender as? NSMenuItem,
             let rep = menuItem.representedObject as? CategoryMenuItemRepresentedObject {
      let category = rep.category
      let subCategoryArray = rep.subCategories
      self.mSelectedCategory.setProp (category)
    //--- Populate sub category pulldown button
      while self.mSubCategoryPullDownButton.numberOfItems > 1 {
        self.mSubCategoryPullDownButton.removeItem (at: self.mSubCategoryPullDownButton.numberOfItems - 1)
      }
      self.mSubCategoryPullDownButton.menu?.autoenablesItems = false
      self.mSubCategoryPullDownButton.isHidden = subCategoryArray.count <= 1
      if subCategoryArray.count > 1 {
        self.mSubCategoryPullDownButton.addItem (withTitle: CATEGORY_SUFFIX)
        if let item = self.mSubCategoryPullDownButton.lastItem {
          let baseCategory = String (category.split (separator: " ", maxSplits: 1) [0]) + CATEGORY_SUFFIX
          item.representedObject = CategoryMenuItemRepresentedObject (
            category: baseCategory,
            subCategories: subCategoryArray
          )
          item.action = #selector (Self.categoryPullDownButtonAction (_:))
          item.target = self
        }
        for (secondName, category) in subCategoryArray {
          self.mSubCategoryPullDownButton.addItem (withTitle: secondName)
          if let button = self.mSubCategoryPullDownButton.lastItem {
            button.representedObject = CategoryMenuItemRepresentedObject (
              category: category,
              subCategories: subCategoryArray
            )
            button.action = #selector (Self.categoryPullDownButtonAction (_:))
            button.target = self
          }
        }
      }
    //---
      self.filterAction (nil)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func filterAction (_ inUnusedSender : Any?) {
    let filter = self.mSearchField.stringValue.uppercased ()
    let category = self.mSelectedCategory.propval
    var dataSource = self.mTableViewDataSource
  //--- Filter from search field
    if !filter.isEmpty {
      let previousDataSource = dataSource
      dataSource = []
      for entry in previousDataSource {
        if entry.mPartName.uppercased ().contains (filter) {
          dataSource.append (entry)
        }
      }
    }
  //--- Filter from category
    if !category.isEmpty {
      let previousDataSource = dataSource
      dataSource = []
      if category.hasSuffix (CATEGORY_SUFFIX) {
        let c = category.dropLast (CATEGORY_SUFFIX.count)
        for entry in previousDataSource {
          if let names = entry.partCategory (self.categoryKey)?.split (separator: " "), names [0] == c {
            dataSource.append (entry)
          }
        }
      }else{
        for entry in previousDataSource {
          if entry.partCategory (self.categoryKey) == category {
            dataSource.append (entry)
          }
        }
      }
    }
  //--- Table view
    self.mTableViewFilteredDataSource = dataSource
    self.mTableViewFilteredDataSource.sort { $0.mPartName < $1.mPartName }
    self.mTableView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class OpenInLibraryDialogFlatItem {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mPartName : String
  let mIsDuplicated : Bool
  let mIsAlreadyLoaded : Bool
  let mFullPath : String
  private var mCategory : String? = nil
  private var mPartStatus : MetadataStatus? = nil
  private var mObjectImage : NSImage? = nil
  private let mBuildPreviewShapeFunction : (_ inRootObject : EBManagedObject?) -> NSImage?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (name inPartName : String,
        fullPath inFullPath : String,
        duplicated inIsDuplicated : Bool,
        alreadyLoaded inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    self.mPartName = inPartName
    self.mFullPath = inFullPath
    self.mIsDuplicated = inIsDuplicated
    self.mIsAlreadyLoaded = inIsAlreadyLoaded
    self.mBuildPreviewShapeFunction = inBuildPreviewShapeFunction
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func statusString () -> String {
    if self.mFullPath.isEmpty {
      return ""
    }else if self.mIsAlreadyLoaded {
      return "Already loaded"
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
    }else if self.mIsDuplicated || self.mIsAlreadyLoaded {
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

  func partCategory (_ inKey : String?) -> String? {
    if let key = inKey {
      if let s = self.mCategory {
        return s
      }else if self.mFullPath != "", let metadata = try? getFileMetadata (atPath: self.mFullPath) {
        let dictionary = metadata.metadataDictionary
        if let s = dictionary [key] as? String {
          self.mCategory = s
          return s
        }else{
          self.mCategory = ""
          return ""
        }
      }else{
        return ""
      }
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var image : NSImage {
    if let image = self.mObjectImage {
      return image
    }else{
      let image = self.buildImage ()
      self.mObjectImage = image
      return image
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildImage () -> NSImage {
    var image : NSImage? = nil
    let fm = FileManager ()
    if let data = fm.contents (atPath: self.mFullPath) {
      let documentReadData = loadEasyBindingFile (fromData: data, documentName: self.mFullPath.lastPathComponent, undoManager: nil)
      switch documentReadData {
      case .ok (let documentData) :
        image = self.mBuildPreviewShapeFunction (documentData.documentRootObject)
      case .readError (let error) :
        let alert = NSAlert (error: error)
        _ = alert.runModal ()
      }
    }
    return image ?? NSImage ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateFromFile () {
    self.mCategory = nil
    self.mPartStatus = nil
    self.mObjectImage = nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension Array where Element == OpenInLibraryDialogFlatItem {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor fileprivate mutating func enterPart (
         pathComponentArray inPathAsArray : [String],
         fullPath inFullpath : String,
         duplicated inIsDuplicated : Bool,
         alreadyLoaded inIsAlreadyLoaded : Bool,
         _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    if inPathAsArray.count == 1 {
      self.append (
        OpenInLibraryDialogFlatItem (
          name: inPathAsArray [0],
          fullPath: inFullpath,
          duplicated: inIsDuplicated,
          alreadyLoaded: inIsAlreadyLoaded,
          inBuildPreviewShapeFunction
        )
      )
    }else{
      var pathAsArray = inPathAsArray
      pathAsArray.remove (at: 0)
      self.enterPart (
        pathComponentArray: pathAsArray,
        fullPath: inFullpath,
        duplicated: inIsDuplicated,
        alreadyLoaded: inIsAlreadyLoaded,
        inBuildPreviewShapeFunction
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate struct CategoryMenuItemRepresentedObject {
  let category : String
  let subCategories : [(String, String)]
}

//--------------------------------------------------------------------------------------------------
