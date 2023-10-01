//
//  AutoLayoutGenericTableView-value-column-String.swift.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutGenericTableView {

  //····················································································································

  func addColumn_String (mutablePropertyKeyPath inKeyPath : KeyPath <ELEMENT, EBStoredProperty <String>>,
                         sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                         title inTitle : String,
                         minWidth inMinWidth : Int,
                         maxWidth inMaxWidth : Int,
                         headerAlignment inHeaderAlignment : TextAlignment,
                         contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalMutableStringTableColumn (
      withIdentifierNamed: String (self.columnCount),
      mutablePropertyKeyPath: inKeyPath,
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
// InternalStringValueTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalMutableStringTableColumn <ELEMENT : EBManagedObject> : AutoLayoutGenericTableColumn <ELEMENT> {

  //····················································································································

  private let mKeyPath : KeyPath <ELEMENT, EBStoredProperty <String>>

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        mutablePropertyKeyPath inKeyPath : KeyPath <ELEMENT, EBStoredProperty <String>>,
        sourceArray inSourceArray : ReadOnlyAbstractArrayProperty <ELEMENT>?,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment) {
    self.mKeyPath = inKeyPath
    super.init (withIdentifierNamed: inName, sourceArray: inSourceArray, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
    self.isEditable = true // inSetterDelegate != nil
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




//    textField.stringValue = self.mValueGetterDelegate (inRowIndex) ?? ""
//
//    let editable = self.mValueSetterDelegate != nil
//    textField.isEditable = editable
//    if editable {
      textField.target = self
      textField.action = #selector (Self.setterAction (_:))
//    }
    return textField
  }

  //····················································································································

  @objc func setterAction (_ inSender : Any?) {
    if let textField = inSender as? NSTextField {
      let rowIndex = textField.tag
      let newValue = textField.stringValue
//      self.mValueSetterDelegate? (rowIndex, newValue)
      if let objectArray : EBReferenceArray<ELEMENT> = self.mSourceArray?.propval, rowIndex < objectArray.count {
        let property = objectArray [rowIndex] [keyPath: self.mKeyPath]
        property.setProp (newValue)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
