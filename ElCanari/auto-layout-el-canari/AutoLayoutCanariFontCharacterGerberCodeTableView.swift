//
//  AutoLayoutCanariFontCharacterGerberCodeTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/11/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let LEFT_COLUMN_IDENTIFIER  = NSUserInterfaceItemIdentifier (rawValue: "left")
fileprivate let RIGHT_COLUMN_IDENTIFIER = NSUserInterfaceItemIdentifier (rawValue: "right")

//——————————————————————————————————————————————————————————————————————————————————————————————————
//    AutoLayoutCanariFontCharacterGerberCodeTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariFontCharacterGerberCodeTableView : AutoLayoutVerticalStackView, NSTableViewDataSource, NSTableViewDelegate {

  //································································································

  private let mScrollView = NSScrollView (frame: .zero)
  private let mTableView = PrivateTableView ()

  //································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  init (size inSize : EBControlSize) {
    super.init ()
    noteObjectAllocation (self)

  //--- Configure table view
    self.mTableView.translatesAutoresizingMaskIntoConstraints = false
    self.mTableView.controlSize = inSize.cocoaControlSize
    self.mTableView.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.mTableView.controlSize))
    self.mTableView.focusRingType = .none
    self.mTableView.isEnabled = true
    self.mTableView.delegate = self
    self.mTableView.dataSource = self
//    self.mTableView.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
    self.mTableView.gridStyleMask = [.solidVerticalGridLineMask]
 //   self.mTableView.usesAlternatingRowBackgroundColors = true
    self.mTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
    self.mTableView.usesAutomaticRowHeights = true // #available(macOS 10.13

    let leftColumn = NSTableColumn (identifier: LEFT_COLUMN_IDENTIFIER)
    leftColumn.minWidth = 65.0
    leftColumn.maxWidth = 65.0
    leftColumn.isEditable = false
    leftColumn.title = "Code"
//    leftColumn.resizingMask = [] // Not resizable
    self.mTableView.addTableColumn (leftColumn)

    let rightColumn = NSTableColumn (identifier: RIGHT_COLUMN_IDENTIFIER)
    rightColumn.minWidth = 70.0
    rightColumn.maxWidth = 1000.0
    rightColumn.isEditable = false
    rightColumn.resizingMask = .autoresizingMask
    rightColumn.title = "Comment"
    self.mTableView.addTableColumn (rightColumn)

  //--- Configure scroll view
    self.mScrollView.translatesAutoresizingMaskIntoConstraints = false
    self.mScrollView.hasVerticalScroller = true
    self.mScrollView.borderType = .bezelBorder
    self.mScrollView.documentView = self.mTableView
  //---
    _ = self.appendView (self.mScrollView)
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································
  //  value binding
  //································································································

  private var mValueController : EBObservablePropertyController? = nil

  //································································································

  final func bind_characterGerberCode (_ inObject : EBObservableProperty <CharacterGerberCode>) -> Self {
    self.mValueController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //································································································

  private var mModel = CharacterGerberCode (code: [])

  //································································································

  func update (from inModel : EBObservableProperty <CharacterGerberCode>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mModel = CharacterGerberCode (code: [])
    case .single (let v) :
      self.mModel = v
    }
    self.mTableView.reloadData ()
  }

  //································································································
  //    T A B L E V I E W    D A T A S O U R C E : numberOfRowsInTableView
  //································································································

  func numberOfRows (in _ : NSTableView) -> Int {
    return self.mModel.code.count
  }

  //································································································
  //    T A B L E V I E W    D E L E G A T E : tableView:viewForTableColumn:row:
  //································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn: NSTableColumn?,
                  row inRowIndex: Int) -> NSView? {
    let textField = NSTextField (frame: .zero)
    textField.translatesAutoresizingMaskIntoConstraints = false

    textField.tag = inRowIndex
    textField.isBezeled = false
    textField.isBordered = false
    textField.drawsBackground = false
    textField.isEnabled = true
    textField.isEditable = false
//-- DO NOT CHANGE controlSize and font, it makes text field not editable (???)

    let object = self.mModel.code [inRowIndex]
    let columnIdentifier = inTableColumn!.identifier
    if columnIdentifier == LEFT_COLUMN_IDENTIFIER {
      textField.stringValue = object.codeString ()
    }else if columnIdentifier == RIGHT_COLUMN_IDENTIFIER {
      textField.stringValue = object.comment ()
    }else{
      return nil
    }
    return textField
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate final class PrivateTableView : NSTableView {

  //································································································

  @MainActor init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

  override var acceptsFirstResponder: Bool { return false }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
