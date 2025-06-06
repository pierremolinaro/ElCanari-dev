//
//  AutoLayoutTableView-column-Bool.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutTableView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addColumn_Bool (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Bool?,
                       valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Bool) -> Void >,
                       sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                       title inTitle : String,
                       minWidth inMinWidth : Int,
                       maxWidth inMaxWidth : Int,
                       headerAlignment inHeaderAlignment : TextAlignment,
                       contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalBoolValueTableColumn (
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
// InternalBoolValueTableColumn
//--------------------------------------------------------------------------------------------------

fileprivate final class InternalBoolValueTableColumn : AutoLayoutTableColumn {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mValueGetterDelegate : (_ inRow : Int) -> Bool?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Bool) -> Void >

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        title inTitle : String,
        minWidth inMinWidth : Int,
        maxWidth inMaxWidth : Int,
        headerAlignment inHeaderAlignment : TextAlignment,
        contentAlignment inContentAlignment : TextAlignment,
        valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Bool) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Bool?) {
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

  @MainActor override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let checkbox = ALB_NSButton (title: "", size: .small)
    checkbox.setContentHuggingPriority (.defaultLow, for: .horizontal)
    checkbox.setContentHuggingPriority (.defaultLow, for: .vertical)
    checkbox.setButtonType (.switch)

    let editable = self.mValueSetterDelegate != nil
    if let value = self.mValueGetterDelegate (inRowIndex) {
      checkbox.state = value ? .on : .off
      checkbox.isEnabled = editable
    }else{
      checkbox.isEnabled = false
    }
    if editable {
      checkbox.tag = inRowIndex
      checkbox.target = self
      checkbox.action = #selector (Self.setterAction(_:))
    }
    return checkbox
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func setterAction (_ inSender : Any?) {
    if let checkbox = inSender as? NSButton {
      let newValue = checkbox.state == .on
      let rowIndex = checkbox.tag
      self.tableView?.selectRowIndexes (IndexSet (integer: rowIndex), byExtendingSelection: false)
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
