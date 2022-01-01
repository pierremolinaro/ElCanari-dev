//
//  AutoLayoutTableView-column-NSColor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutTableView {

  //····················································································································

  func addColumn_NSColor (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSColor?,
                          valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : NSColor) -> Void >,
                          sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                          title inTitle : String,
                          minWidth inMinWidth : Int,
                          maxWidth inMaxWidth : Int,
                          headerAlignment inHeaderAlignment : TextAlignment,
                          contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalColorTableColumn (
      withIdentifierNamed: String (self.columnCount),
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
// InternalColorTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class InternalColorTableColumn : AutoLayoutTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> NSColor?

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSColor?) {
    self.mValueGetterDelegate = inGetterDelegate
    super.init (withIdentifierNamed: inName, sortDelegate: nil, contentAlignment: .center)
    self.isEditable = false
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let view = AutoLayoutViewWithBackground ()
    let color = self.mValueGetterDelegate (inRowIndex)
    view.mBackGroundColor = color
    return view
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
