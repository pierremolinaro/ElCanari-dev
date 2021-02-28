//
//  view-DeviceSymbolTypesTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/10/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// NOTE: DeviceSymbolTypesTableView is view based
//----------------------------------------------------------------------------------------------------------------------

final class DeviceSymbolTypesTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

  @IBOutlet var mDeviceSymbolTypePinsTableView : StringArrayTableView? = nil
  
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
    self.reloadDataSource (self.mDeviceSymbolDictionary)
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

  private var mDeviceSymbolDictionary = DeviceSymbolDictionary ()
  private var mDataSource = StringArray ()
  private var mPinNameArray = EBTransientProperty_StringArray ()

  //····················································································································

  func reloadDataSource (_ inDataSource : DeviceSymbolDictionary) {
    self.mPinNameArray.postEvent ()
    self.mDeviceSymbolDictionary = inDataSource
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx])
      }
    }
  //--- Get array of symbol type names
    var symbolTypeNames = Set <String> ()
    for (symbolIdentifier, _) in inDataSource {
      symbolTypeNames.insert (symbolIdentifier.symbolTypeName)
    }
  //--- Sort
    self.mDataSource = Array (symbolTypeNames)
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

  func update (from inModel : EBReadOnlyProperty_DeviceSymbolDictionary) {
    switch inModel.selection {
    case .empty, .multiple :
      self.reloadDataSource (DeviceSymbolDictionary ())
    case .single (let unconnectedPadArray) :
      self.reloadDataSource (unconnectedPadArray)
    }
  }

  //····················································································································
  //  $array binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_symbolDictionary (_ model : EBReadOnlyProperty_DeviceSymbolDictionary) {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    self.mDeviceSymbolTypePinsTableView?.bind_array (self.mPinNameArray)
    self.mPinNameArray.mReadModelFunction = { EBSelection.single (self.pinNames ()) }
  }

  //····················································································································

  final func unbind_symbolDictionary () {
    self.mDeviceSymbolTypePinsTableView?.unbind_array ()
     self.mPinNameArray.mReadModelFunction = nil
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
  //    T A B L E V I E W    D E L E G A T E : tableViewSelectionDidChange:
  //····················································································································

  func tableViewSelectionDidChange (_ notification : Notification) {
    self.mPinNameArray.postEvent ()
  }

  //····················································································································
  // COMPUTE PIN NAMES
  //····················································································································

  private func pinNames () -> [String] {
    var pinNameSet = Set <String> ()
    if let selectedSymbolTypeName = self.selectedItemTitle {
      for (symbolIdentifier, info) in self.mDeviceSymbolDictionary {
        if symbolIdentifier.symbolTypeName == selectedSymbolTypeName {
          for assignment in info.assignments {
            if let pin = assignment.pin, pin.symbol == symbolIdentifier {
              pinNameSet.insert (pin.pinName)
            }
          }
        }
      }
    }
    return Array (pinNameSet)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
