//
//  AutoLayoutGenericTableView-column-String.swift.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutGenericTableView {

  //····················································································································

  func addColumn_String (propertyKeyPath inKeyPath : KeyPath <ELEMENT, EBTransientProperty <String>>,
                         sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                         title inTitle : String,
                         minWidth inMinWidth : Int,
                         maxWidth inMaxWidth : Int,
                         headerAlignment inHeaderAlignment : TextAlignment,
                         contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalStringTableColumn (
      withIdentifierNamed: String (self.columnCount),
      propertyKeyPath: inKeyPath,
      sourceArray: self.mSourceArray,
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment
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
// InternalStringTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalStringTableColumn <ELEMENT : EBManagedObject> : AutoLayoutGenericTableColumn <ELEMENT> {

  //····················································································································

  private let mKeyPath : KeyPath <ELEMENT, EBTransientProperty <String>>

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        propertyKeyPath inKeyPath : KeyPath <ELEMENT, EBTransientProperty <String>>,
        sourceArray inSourceArray : ReadOnlyAbstractArrayProperty <ELEMENT>?,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment) {
    self.mKeyPath = inKeyPath
    super.init (withIdentifierNamed: inName, sourceArray: inSourceArray, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
    self.isEditable = false
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
    if let objectArray : EBReferenceArray<ELEMENT> = self.mSourceArray?.propval, inRowIndex < objectArray.count {
      let property = objectArray [inRowIndex] [keyPath: self.mKeyPath]
      switch property.selection {
      case .single (let v) :
        textField.stringValue = v
        textField.isEditable = true
      case .empty, .multiple :
        textField.isEditable = false
      }
    }else{
      textField.isEditable = false
    }
    return textField
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
