//
//  view-UnconnectedPadsInDeviceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// NOTE: UnconnectedPadsInDeviceTableView is cell based
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class UnconnectedPadsInDeviceTableView : EBTableView, NSTableViewDataSource {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.dataSource = self // NSTableViewDataSource protocol
  }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mUnconnectedPadArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row: Int) -> Any? {
    var result : Any? = nil
    if let columnIdentifier = inTableColumn?.identifier.rawValue {
      if columnIdentifier == "pad" {
        result = self.mUnconnectedPadArray [row]
      }
    }
    return result
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    for idx in self.selectedRowIndexes {
      selectedRowContents.insert (self.mUnconnectedPadArray [idx])
    }
  //--- Sort
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "pad" {
          self.mUnconnectedPadArray.sort (by: { s.ascending ? numericCompare ($0, $1) :  numericCompare ($1, $0) })
        }
      }
    }
    self.reloadData ()
  //--- Restore selection
    var newSelectedRowIndexes = IndexSet ()
    var idx = 0
    while idx < self.mUnconnectedPadArray.count {
      if selectedRowContents.contains (self.mUnconnectedPadArray [idx]) {
        newSelectedRowIndexes.insert (idx)
      }
      idx += 1
    }
    self.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mUnconnectedPadArray = StringArray ()

  //····················································································································

  func updateUnconnectedSymbolPinsList (from inModel : EBReadOnlyProperty_StringArray) {
    switch inModel.prop {
    case .empty, .multiple :
      self.mUnconnectedPadArray.removeAll ()
    case .single (let unconnectedPadArray) :
      self.mUnconnectedPadArray = unconnectedPadArray
    }
    self.reloadData ()
  }

  //····················································································································
  //  $imageData binding
  //····················································································································

  private var mController : EBReadOnlyController_StringArray? = nil

  //····················································································································

  func bind_unconnectedPads (_ model : EBReadOnlyProperty_StringArray, file : String, line : Int) {
    self.mController = EBReadOnlyController_StringArray (
      model: model,
      callBack: { [weak self] in self?.updateUnconnectedSymbolPinsList (from: model) }
    )
  }

  //····················································································································

  func unbind_unconnectedPads () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func numericCompare (_ inLeft : String, _ inRight : String) -> Bool {
  let comparisonResult = inLeft.compare (inRight, options: [.numeric])
  return comparisonResult == .orderedAscending
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
