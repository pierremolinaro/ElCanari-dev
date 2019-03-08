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
    return self.mUnconnectedPinArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row: Int) -> Any? {
    var result : Any? = nil
    if let columnIdentifier = inTableColumn?.identifier.rawValue {
      if columnIdentifier == "symbol" {
        result = self.mUnconnectedPinArray [row].symbolInstanceName
      }else if columnIdentifier == "pin" {
        result = self.mUnconnectedPinArray [row].pinName
      }
    }
    return result
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
  //--- Note selected rows has values
    var selectedRowHashValues = Set <Int> ()
    for idx in self.selectedRowIndexes {
      selectedRowHashValues.insert (self.mUnconnectedPinArray [idx].hashValue)
    }
  //--- Sort
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "symbol" {
          if s.ascending {
            self.mUnconnectedPinArray.sort (by: { $0.symbolInstanceName < $1.symbolInstanceName })
          }else{
            self.mUnconnectedPinArray.sort (by: { $0.symbolInstanceName > $1.symbolInstanceName })
          }
        }else if key == "pin" {
          if s.ascending {
            self.mUnconnectedPinArray.sort (by: { $0.pinName < $1.pinName })
          }else{
            self.mUnconnectedPinArray.sort (by: { $0.pinName > $1.pinName })
          }
        }
      }
    }
    self.reloadData ()
  //--- Restore selection
    var newSelectedRowIndexes = IndexSet ()
    var idx = 0
    while idx < self.mUnconnectedPinArray.count {
      if selectedRowHashValues.contains (self.mUnconnectedPinArray [idx].hashValue) {
        newSelectedRowIndexes.insert (idx)
      }
      idx += 1
    }
    self.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mUnconnectedPinArray = UnconnectedSymbolPinsInDevice ()

  //····················································································································

  func updateUnconnectedSymbolPinsList (from inModel : EBReadOnlyProperty_UnconnectedSymbolPinsInDevice) {
    switch inModel.prop {
    case .empty, .multiple :
      self.mUnconnectedPinArray.removeAll ()
    case .single (let unconnectedSymbolPinArray) :
      self.mUnconnectedPinArray = unconnectedSymbolPinArray
    }
    self.reloadData ()
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
