//
//  AutoLayoutTableView-column-NSImage_int.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutTableView {

  //····················································································································

  func addColumn_NSImage_Int (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> (Int?, NSImage?),
                              sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                              title inTitle : String,
                              minWidth inMinWidth : Int,
                              maxWidth inMaxWidth : Int,
                              headerAlignment inHeaderAlignment : TextAlignment,
                              contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalImageIntTableColumn (
      withIdentifierNamed: String (self.columnCount),
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment,
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
// InternalImageIntTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class InternalImageIntTableColumn : AutoLayoutTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> (Int?, NSImage?)
  private let mNumberFormatter = NumberFormatter ()

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> (Int?, NSImage?) ) {
    self.mValueGetterDelegate = inGetterDelegate
    super.init (withIdentifierNamed: inName, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
    self.isEditable = false
  //--- Configure number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let value : (Int?, NSImage?) = self.mValueGetterDelegate (inRowIndex)

    let hStack = AutoLayoutHorizontalStackView ()

    let imageView = AutoLayoutStaticImageView (image: value.1)
    hStack.appendView (imageView)

    let textField = NSTextField (frame: NSRect ())
    textField.translatesAutoresizingMaskIntoConstraints = false
    hStack.appendView (textField)

    textField.isBezeled = false
    textField.isBordered = false
    textField.drawsBackground = false
    textField.isEnabled = true
    textField.isEditable = false
//-- DO NOT CHANGE controlSize and font, it makes text field not editable (???)
//    textField.controlSize = self.mTableView.controlSize
//    textField.font = self.mTableView.font
    textField.formatter = self.mNumberFormatter
    textField.alignment = self.mContentAlignment
    if let v = value.0 {
      textField.integerValue = v
    }

    hStack.appendFlexibleSpace ()
    return hStack
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

