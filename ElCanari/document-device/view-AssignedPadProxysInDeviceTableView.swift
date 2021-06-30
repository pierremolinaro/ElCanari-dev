//
//  view-AssignedPadProxysInDeviceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// NOTE: AssignedPadProxysInDeviceTableView is view based
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AssignedPadProxysInDeviceTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

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

  func tableView (_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    self.reloadDataSource (self.mDataSource)
  }

  //····················································································································
  //   NSTableViewDelegate protocol
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    var result : NSTextField? = nil
    if let columnIdentifier = inTableColumn?.identifier {
      result = tableView.makeView (withIdentifier: columnIdentifier, owner: self) as? NSTextField
      if !reuseTableViewCells () {
        result?.identifier = nil // So result cannot be reused, will be freed
      }
      if columnIdentifier.rawValue == "pad" {
        result?.stringValue = self.mDataSource [inRowIndex].padName
      }else if columnIdentifier.rawValue == "symbol" {
        result?.stringValue = self.mDataSource [inRowIndex].symbolInstanceName
      }else if columnIdentifier.rawValue == "pin" {
        result?.stringValue = self.mDataSource [inRowIndex].pinName
      }
   }
    return result
  }

  //····················································································································
  //  utilities
  //····················································································································

  private func selectedItems () -> Set <AssignedPadProxy> {
    var selectedRowContents = Set <AssignedPadProxy> ()
    for idx in self.selectedRowIndexes {
      selectedRowContents.insert (self.mDataSource [idx])
    }
    return selectedRowContents
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = [AssignedPadProxy] ()

  //····················································································································

  private func reloadDataSource (_ inDataSource : [AssignedPadProxy]) {
  //--- Note selected items
    var selectedRowContents = Set <AssignedPadProxy> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx])
      }
    }
    self.mDataSource = inDataSource
  //--- Sort
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "pad" {
          self.mDataSource.sort { String.numericCompare ($0.padName, s.ascending, $1.padName)}
        }else if key == "symbol" {
          self.mDataSource.sort { String.numericCompare ($0.symbolInstanceName, s.ascending, $1.symbolInstanceName) }
        }else if key == "pin" {
          self.mDataSource.sort { String.numericCompare ($0.pinName, s.ascending, $1.pinName) }
        }
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

  func updateUnconnectedPadList (from inModel : EBReadOnlyProperty_AssignedPadProxiesInDevice) {
    switch inModel.selection {
    case .empty, .multiple :
      self.reloadDataSource ([])
    case .single (let unconnectedPadArray) :
      self.reloadDataSource (unconnectedPadArray)
    }
  }

  //····················································································································
  //  selectedPadProxy
  //····················································································································

  var selectedPadProxy : AssignedPadProxy? {
    if self.selectedRow >= 0 {
      return self.mDataSource [self.selectedRow]
    }else{
      return nil
    }
  }

  //····················································································································
  //  $imageData binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_assignedPadProxies (_ model : EBReadOnlyProperty_AssignedPadProxiesInDevice) {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateUnconnectedPadList (from: model) }
    )
  }

  //····················································································································

  final func unbind_assignedPadProxies () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
