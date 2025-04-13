//
//  AutoLayoutTableView-column-AttributedString.swift
//  essai-editeur-texte-swift
//
//  Created by Pierre Molinaro on 08/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutTableView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addColumn_AttributedString (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSAttributedString?,
                                   valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : NSAttributedString) -> Void >,
                                   sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                                   title inTitle : String,
                                   minWidth inMinWidth : Int,
                                   maxWidth inMaxWidth : Int,
                                   headerAlignment inHeaderAlignment : TextAlignment,
                                   contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalAttributedStringTableColumn (
      sortDelegate: inSortDelegate,
      title: inTitle,
      minWidth: inMinWidth,
      maxWidth: inMaxWidth,
      headerAlignment: inHeaderAlignment,
      contentAlignment: inContentAlignment,
      valueSetterDelegate: inSetterDelegate,
      valueGetterDelegate: inGetterDelegate
    )
  //--- Add Column
    self.appendTableColumn (column)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
// InternalAttributedStringTableColumn
//--------------------------------------------------------------------------------------------------

fileprivate class InternalAttributedStringTableColumn : AutoLayoutTableColumn {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mValueGetterDelegate : (_ inRow : Int) -> NSAttributedString?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : NSAttributedString) -> Void >

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        title inTitle : String,
        minWidth inMinWidth : Int,
        maxWidth inMaxWidth : Int,
        headerAlignment inHeaderAlignment : TextAlignment,
        contentAlignment inContentAlignment : TextAlignment,
        valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : NSAttributedString) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSAttributedString?) {
    self.mValueGetterDelegate = inGetterDelegate
    self.mValueSetterDelegate = inSetterDelegate
    super.init (
      sortDelegate: inSortDelegate,
      title: inTitle,
      minWidth: inMinWidth,
      maxWidth: inMaxWidth,
      headerAlignment: inHeaderAlignment,
      contentAlignment: inContentAlignment
    )
    self.isEditable = inSetterDelegate != nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let textField = NSTextField (frame: NSRect ())
    textField.translatesAutoresizingMaskIntoConstraints = false

    textField.tag = inRowIndex
    textField.isBezeled = false
    textField.isBordered = false
    textField.drawsBackground = false
    textField.isEnabled = true
//-- DO NOT CHANGE controlSize and font, it makes text field not editable (???)
//    if let tableView = self.tableView {
//      textField.controlSize = tableView.controlSize
//      textField.font = tableView.font
//    }

    textField.alignment = self.mContentAlignment
    textField.attributedStringValue = self.mValueGetterDelegate (inRowIndex) ?? NSAttributedString ()

    let editable = self.mValueSetterDelegate != nil
    textField.isEditable = editable
    if editable {
      textField.target = self
      textField.action = #selector (Self.setterAction (_:))
    }
    return textField
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc private func setterAction (_ inSender : Any?) {
    if let textField = inSender as? NSTextField {
      let rowIndex = textField.tag
      let newValue = textField.attributedStringValue
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
