//
//  AutoLayoutTableView-column-Bool.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutTableView {

  //····················································································································

  func addColumn_Bool (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Bool?,
                       valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Bool) -> Void >,
                       sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                       title inTitle : String,
                       minWidth inMinWidth : Int,
                       maxWidth inMaxWidth : Int,
                       headerAlignment inHeaderAlignment : TextAlignment,
                       contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalBoolTableColumn (
      withIdentifierNamed: String (self.columnCount),
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment,
      valueSetterDelegate: inSetterDelegate,
      valueGetterDelegate: inGetterDelegate
    )
    column.title = inTitle
    column.headerCell.controlSize = self.controlSize
    column.headerCell.font = self.font
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
// InternalBoolTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class InternalBoolTableColumn : AutoLayoutTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> Bool?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Bool) -> Void >

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Bool) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Bool?) {
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
    let checkbox = AutoLayoutBase_NSButton (title: "", size: .small)
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
      checkbox.action = #selector (Self.ebAction(_:))
    }
    return checkbox
  }

  //····················································································································

  @objc func ebAction (_ inSender : Any?) {
    if let checkbox = inSender as? NSButton {
      let newValue = checkbox.state == .on
      let rowIndex = checkbox.tag
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
