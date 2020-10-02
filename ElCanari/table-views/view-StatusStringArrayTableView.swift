//
//  view-StatusStringArrayTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   Status
//----------------------------------------------------------------------------------------------------------------------

enum Status : UInt, Hashable {
  case ok
  case warning
  case error
}

//----------------------------------------------------------------------------------------------------------------------
//   StatusString
//----------------------------------------------------------------------------------------------------------------------

struct StatusString : Hashable {
  let status : Status
  let string : String
}

//----------------------------------------------------------------------------------------------------------------------
//   StatusStringArray
//----------------------------------------------------------------------------------------------------------------------

typealias StatusStringArray = [StatusString]

//----------------------------------------------------------------------------------------------------------------------
// NOTE: StatusStringArrayTableView is view based
//----------------------------------------------------------------------------------------------------------------------

class StatusStringArrayTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

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
      if columnIdentifier.rawValue == "value" {
        result?.textField?.stringValue = self.mDataSource [inRowIndex].string
        switch self.mDataSource [inRowIndex].status {
        case .ok :
          result?.imageView?.image = NSImage (named: okStatusImageName)
        case .warning :
          result?.imageView?.image = NSImage (named: warningStatusImageName)
        case .error :
          result?.imageView?.image = NSImage (named: errorStatusImageName)
        }
      }
    }
    return result
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = StatusStringArray ()

  //····················································································································

  func reloadDataSource (_ inDataSource : [StatusString]) {
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx].string)
      }
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "value" {
          self.mDataSource.sort (by: { $0.string < $1.string } )
          if !s.ascending {
            self.mDataSource.reverse ()
          }
        }else if key == "status" {
          self.mDataSource.sort (by: { $0.status.rawValue < $1.status.rawValue } )
          if !s.ascending {
            self.mDataSource.reverse ()
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
      if selectedRowContents.contains (self.mDataSource [idx].string) {
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

  func update (from inModel : EBReadOnlyProperty_StatusStringArray) {
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

  private var mController : EBSimpleController? = nil

  //····················································································································

  func bind_array (_ model : EBReadOnlyProperty_StatusStringArray, file : String, line : Int) {
    self.mController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  func unbind_array () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
