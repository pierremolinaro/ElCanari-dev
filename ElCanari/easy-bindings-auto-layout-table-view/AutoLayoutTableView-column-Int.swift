//
//  AutoLayoutTableView-column-Int.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutTableView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addColumn_Int (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Int?,
                      valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Int) -> Void >,
                      sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                      title inTitle : String,
                      minWidth inMinWidth : Int,
                      maxWidth inMaxWidth : Int,
                      headerAlignment inHeaderAlignment : TextAlignment,
                      contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalIntValueTableColumn (
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
// InternalIntValueTableColumn
//--------------------------------------------------------------------------------------------------

fileprivate final class InternalIntValueTableColumn : AutoLayoutTableColumn {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mValueGetterDelegate : (_ inRow : Int) -> Int?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Int) -> Void >
  private let mNumberFormatter = NumberFormatter ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        title inTitle : String,
        minWidth inMinWidth : Int,
        maxWidth inMaxWidth : Int,
        headerAlignment inHeaderAlignment : TextAlignment,
        contentAlignment inContentAlignment : TextAlignment,
        valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Int) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Int?) {
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
  //--- Configure number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

    textField.formatter = self.mNumberFormatter
    textField.alignment = self.mContentAlignment
    textField.integerValue = self.mValueGetterDelegate (inRowIndex) ?? -1

    let editable = self.mValueSetterDelegate != nil
    textField.isEditable = editable
    if editable {
      textField.target = self
      textField.action = #selector (Self.setterAction(_:))
    }
    return textField
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func setterAction (_ inSender : Any?) {
    if let textField = inSender as? NSTextField,
       let formatter = textField.formatter as? NumberFormatter,
       let outletValueNumber = formatter.number (from: textField.stringValue) {
      let newValue = Int (outletValueNumber.doubleValue.rounded ())
      let rowIndex = textField.tag
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
