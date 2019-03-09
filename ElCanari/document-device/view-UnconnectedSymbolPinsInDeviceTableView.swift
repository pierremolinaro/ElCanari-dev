//
//  view-UnconnectedSymbolPinsInDeviceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// NOTE: UnconnectedSymbolPinsInDeviceTableView is cell based
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class UnconnectedSymbolPinsInDeviceTableView : EBTableView, NSTableViewDataSource {

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.dataSource = self // NSTableViewDataSource protocol
  }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mDataSource.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row: Int) -> Any? {
    var result : Any? = nil
    if let columnIdentifier = inTableColumn?.identifier.rawValue {
      if columnIdentifier == "symbol" {
        result = self.mDataSource [row].symbolInstanceName
      }else if columnIdentifier == "pin" {
        result = self.mDataSource [row].pinName
      }
    }
    return result
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    self.reloadDataSource (self.mDataSource)
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = UnconnectedSymbolPinsInDevice ()

  //····················································································································

  func reloadDataSource (_ inDataSource : [UnconnectedSymbolPin]) {
  //--- Note selected rows
    var selectedRowContents = Set <UnconnectedSymbolPin> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      selectedRowContents.insert (self.mDataSource [idx])
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "symbol" {
          if s.ascending {
            self.mDataSource.sort (by: { $0.symbolInstanceName < $1.symbolInstanceName })
          }else{
            self.mDataSource.sort (by: { $0.symbolInstanceName > $1.symbolInstanceName })
          }
        }else if key == "pin" {
          if s.ascending {
            self.mDataSource.sort (by: { $0.pinName < $1.pinName })
          }else{
            self.mDataSource.sort (by: { $0.pinName > $1.pinName })
          }
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

  func updateUnconnectedSymbolPinsList (from inModel : EBReadOnlyProperty_UnconnectedSymbolPinsInDevice) {
    switch inModel.prop {
    case .empty, .multiple :
      self.reloadDataSource ([])
    case .single (let unconnectedSymbolPinArray) :
      self.reloadDataSource (unconnectedSymbolPinArray)
    }
  }

  //····················································································································
  //  selectedSymbolPin
  //····················································································································

  var selectedSymbolPin : UnconnectedSymbolPin? {
    if self.selectedRow >= 0 {
      return self.mDataSource [self.selectedRow]
    }else{
      return nil
    }
  }

  //····················································································································
  //  $imageData binding
  //····················································································································

  private var mController : EBReadOnlyController_UnconnectedSymbolPinsInDevice? = nil

  //····················································································································

  func bind_unconnectedPins (_ model : EBReadOnlyProperty_UnconnectedSymbolPinsInDevice, file : String, line : Int) {
    self.mController = EBReadOnlyController_UnconnectedSymbolPinsInDevice (
      model: model,
      callBack: { [weak self] in self?.updateUnconnectedSymbolPinsList (from: model) }
    )
  }

  //····················································································································

  func unbind_unconnectedPins () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
