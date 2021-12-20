//
//  view-StringArrayTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   StringArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias StringArray = [String]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// NOTE: StringArrayTableView is view based
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class StringArrayTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.dataSource = self // NSTableViewDataSource protocol
    self.delegate = self // NSTableViewDelegate protocol
  }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mDataSource.count
  }

  //····················································································································

  func tableView (_ tableView : NSTableView, sortDescriptorsDidChange oldDescriptors : [NSSortDescriptor]) {
    self.reloadDataSource (self.mDataSource)
  }

  //····················································································································
  //   NSTableViewDelegate protocol
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    var result : NSTableCellView? = nil
    if let columnIdentifier = inTableColumn?.identifier {
      result = tableView.makeView (withIdentifier: columnIdentifier, owner: self) as? NSTableCellView
      if !reuseTableViewCells () {
        result?.identifier = nil // So result cannot be reused, will be freed
      }
      if columnIdentifier.rawValue == "value" {
        result?.textField?.stringValue = self.mDataSource [inRowIndex]
      }
    }
    return result
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = StringArray ()

  //····················································································································

  func reloadDataSource (_ inDataSource : [String]) {
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx])
      }
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.sortDescriptors.reversed () {
      if let key = s.key, key == "value" {
        self.mDataSource.sort () { String.numericCompare ($0, s.ascending, $1) }
      }else{
        NSLog ("Key '\(String (describing: s.key))' unknown in \(#file):\(#line)")
      }
    }
    self.reloadData ()
  //--- Restore selection
    var newSelectedRowIndexes = IndexSet ()
    var idx = 0
    while idx < self.mDataSource.count {
      if selectedRowContents.contains (self.mDataSource [idx]) {
        newSelectedRowIndexes.insert (idx)
      }
      idx += 1
    }
    if (newSelectedRowIndexes.count == 0) && (self.mDataSource.count > 0) {
      if let firstIndex : Int = currentSelectedRowIndexes.first {
        if firstIndex < self.mDataSource.count {
          newSelectedRowIndexes.insert (firstIndex)
        }else{
          newSelectedRowIndexes.insert (self.mDataSource.count - 1)
        }
      }else{
        newSelectedRowIndexes.insert (0)
      }
    }
    self.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
  }

  //····················································································································

  func update (from inModel : EBReadOnlyProperty_StringArray) {
    switch inModel.selection {
    case .empty, .multiple :
      self.reloadDataSource ([])
    case .single (let unconnectedPadArray) :
      self.reloadDataSource (unconnectedPadArray)
    }
  }

  //····················································································································
  //  $array binding
  //····················································································································

  private var mController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_array (_ model : EBReadOnlyProperty_StringArray) {
    self.mController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  final func unbind_array () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································
  //  SELECTED TITLE
  //····················································································································

  var selectedItemTitle : String? {
    if self.selectedRow >= 0 {
      return self.mDataSource [self.selectedRow]
    }else{
      return nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
