//
//  view-CanariNetInfoTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// NOTE: CanariNetInfoTableView is view based
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariNetInfoTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

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
    var result : NSTableCellView? = nil
    if let columnIdentifier = inTableColumn?.identifier {
      result = tableView.makeView (withIdentifier: columnIdentifier, owner: self) as? NSTableCellView
      if !reuseTableViewCells () {
        result?.identifier = nil // So result cannot be reused, will be freed
      }
      if columnIdentifier.rawValue == "netname" {
        result?.textField?.stringValue = self.mDataSource [inRowIndex].netName
      }else if columnIdentifier.rawValue == "netclass" {
        result?.textField?.stringValue = self.mDataSource [inRowIndex].netClassName
      }else if columnIdentifier.rawValue == "pincount" {
        result?.textField?.stringValue = "\(self.mDataSource [inRowIndex].pins.count)"
      }
    }
    return result
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = NetInfoArray ()

  //····················································································································

  func reloadDataSource (_ inDataSource : NetInfoArray) {
  //--- Note selected rows
    var selectedRowContents = Set <NetInfo> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx])
      }
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "netname" {
          if s.ascending {
            self.mDataSource.sort { $0.netName < $1.netName }
          }else{
            self.mDataSource.sort { $0.netName > $1.netName }
          }
        }else if key == "netclass" {
          if s.ascending {
            self.mDataSource.sort { $0.netClassName < $1.netClassName }
          }else{
            self.mDataSource.sort { $0.netClassName > $1.netClassName }
          }
        }else if key == "pincount" {
          if s.ascending {
            self.mDataSource.sort { $0.pins.count < $1.pins.count }
          }else{
            self.mDataSource.sort { $0.pins.count > $1.pins.count }
          }
        }else{
          NSLog ("Key '\(key)' unknown in \(#file):\(#line)")
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

  func update (from inModel : EBReadOnlyProperty_NetInfoArray) {
    switch inModel.prop {
    case .empty, .multiple :
      self.reloadDataSource ([])
    case .single (let unconnectedPadArray) :
      self.reloadDataSource (unconnectedPadArray)
    }
  }

  //····················································································································

  func object (at inIndex : Int) -> NetInfo {
    return self.mDataSource [inIndex]
  }

  //····················································································································
  //  $netInfo binding
  //····················································································································

  private var mController : EBSimpleController? = nil

  //····················································································································

  func bind_netInfo (_ model : EBReadOnlyProperty_NetInfoArray, file : String, line : Int) {
    self.mController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  func unbind_netInfo () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————