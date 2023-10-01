//
//  AutoLayoutGenericTableView-value-column-Bool.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutGenericTableView {

  //····················································································································

  func addColumn_Bool (mutablePropertyKeyPath inKeyPath : KeyPath <ELEMENT, EBObservableMutableProperty <Bool>>,
                       sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                       title inTitle : String,
                       minWidth inMinWidth : Int,
                       maxWidth inMaxWidth : Int,
                       headerAlignment inHeaderAlignment : TextAlignment,
                       contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalMutableBoolTableColumn (
      withIdentifierNamed: String (self.columnCount),
      mutablePropertyKeyPath: inKeyPath,
      sourceArray: self.mSourceArray,
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment
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
// InternalBoolValueTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalMutableBoolTableColumn <ELEMENT : EBManagedObject> : AutoLayoutGenericTableColumn <ELEMENT> {

  //····················································································································

  private let mKeyPath : KeyPath <ELEMENT, EBObservableMutableProperty <Bool>>

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        mutablePropertyKeyPath inKeyPath : KeyPath <ELEMENT, EBObservableMutableProperty <Bool>>,
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
    let checkbox = AutoLayoutBase_NSButton (title: "", size: .small)
    checkbox.setContentHuggingPriority (.defaultLow, for: .horizontal)
    checkbox.setContentHuggingPriority (.defaultLow, for: .vertical)
    checkbox.setButtonType (.switch)

    let editable = true // self.mValueSetterDelegate != nil
    if let objectArray : EBReferenceArray<ELEMENT> = self.mSourceArray?.propval, inRowIndex < objectArray.count {
      let property = objectArray [inRowIndex] [keyPath: self.mKeyPath]
      switch property.selection {
      case .single (let v) :
        checkbox.state = v ? .on : .off
        checkbox.isEnabled = editable
      case .empty, .multiple :
        checkbox.isEnabled = false
      }
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

  //····················································································································

  @objc func setterAction (_ inSender : Any?) {
    if let checkbox = inSender as? NSButton {
      let newValue = checkbox.state == .on
      let rowIndex = checkbox.tag
      self.tableView?.selectRowIndexes (IndexSet (integer: rowIndex), byExtendingSelection: false)
      if let objectArray : EBReferenceArray<ELEMENT> = self.mSourceArray?.propval, rowIndex < objectArray.count {
        let property = objectArray [rowIndex] [keyPath: self.mKeyPath]
        property.setProp (newValue)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
