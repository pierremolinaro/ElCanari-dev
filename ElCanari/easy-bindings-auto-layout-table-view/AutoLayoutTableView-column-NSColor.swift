//
//  AutoLayoutTableView-column-NSColor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutTableView {

  //····················································································································

  func addColumn_NSColor (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSColor?,
                          valueSetterDelegate _ : Optional < (_ inRow : Int, _ inNewValue : NSColor) -> Void >,
                          sortDelegate _ : Optional < (_ inAscending : Bool) -> Void>,
                          title inTitle : String,
                          minWidth inMinWidth : Int,
                          maxWidth inMaxWidth : Int,
                          headerAlignment inHeaderAlignment : TextAlignment,
                          contentAlignment _ : TextAlignment) {
    let column = InternalColorValueTableColumn (valueGetterDelegate: inGetterDelegate)
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

//——————————————————————————————————————————————————————————————————————————————————————————————————
// InternalColorValueTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalColorValueTableColumn : AutoLayoutTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> NSColor?

  //····················································································································
  // INIT
  //····················································································································

  init (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSColor?) {
    self.mValueGetterDelegate = inGetterDelegate
    super.init (sortDelegate: nil, contentAlignment: .center)
    self.isEditable = false
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @MainActor override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let view = AutoLayoutViewWithBackground ()
    let color = self.mValueGetterDelegate (inRowIndex)
    view.mBackGroundColor = color
    return view
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
