//
//  AutoLayoutTableView-column-String.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutTableView {

  //····················································································································

  func addColumn_String (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> String?,
                         valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >,
                         sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                         title inTitle : String,
                         minWidth inMinWidth : Int,
                         maxWidth inMaxWidth : Int,
                         headerAlignment inHeaderAlignment : TextAlignment,
                         contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalStringValueTableColumn (
      withIdentifierNamed: String (self.columnCount),
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment,
      valueSetterDelegate: inSetterDelegate,
      valueGetterDelegate: inGetterDelegate
    )
    column.title = inTitle
    column.headerCell.font = self.font
    column.headerCell.controlSize = self.controlSize
    column.headerCell.alignment = inHeaderAlignment.cocoaAlignment
    column.minWidth = CGFloat (inMinWidth)
    column.maxWidth = CGFloat (inMaxWidth)
    column.width = (column.minWidth + column.maxWidth) / 2.0
  //--- Add Column
    self.appendTableColumn (column)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// InternalStringValueTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalStringValueTableColumn : AutoLayoutTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> String?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> String?) {
    self.mValueGetterDelegate = inGetterDelegate
    self.mValueSetterDelegate = inSetterDelegate
    super.init (withIdentifierNamed: inName, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
    self.isEditable = inSetterDelegate != nil
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let textField = NSTextField (frame: .zero)
    textField.translatesAutoresizingMaskIntoConstraints = false

    textField.tag = inRowIndex
    textField.isBezeled = false
    textField.isBordered = false
    textField.drawsBackground = false
    textField.isEnabled = true
    textField.cell?.sendsActionOnEndEditing = true // Send an action when focus is lost
//-- DO NOT CHANGE controlSize and font, it makes text field not editable (???)
//    textField.controlSize = self.mTableView.controlSize
//    textField.font = self.mTableView.font

    textField.alignment = self.mContentAlignment
    textField.stringValue = self.mValueGetterDelegate (inRowIndex) ?? ""

    let editable = self.mValueSetterDelegate != nil
    textField.isEditable = editable
    if editable {
      textField.target = self
      textField.action = #selector (Self.ebAction (_:))
    }
    return textField
  }

  //····················································································································

  @objc func ebAction (_ inSender : Any?) {
    if let textField = inSender as? NSTextField {
      let rowIndex = textField.tag
      let newValue = textField.stringValue
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
