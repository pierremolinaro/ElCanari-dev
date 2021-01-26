//
//  view-CanariNetInfoTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/04/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// NOTE: CanariNetInfoTableView is view based
//----------------------------------------------------------------------------------------------------------------------

class CanariNetInfoTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  @IBOutlet var mSubnetTableView : StatusStringArrayTableView? = nil

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
      }else if columnIdentifier.rawValue == "tracks" {
        let n = self.mDataSource [inRowIndex].trackCount
        if n == 0 {
          result?.textField?.stringValue = "—"
        }else if n == 1 {
          result?.textField?.stringValue = "1 segment"
        }else{
          result?.textField?.stringValue = "\(n) segments"
        }
        result?.imageView?.image = NSImage (named: (n == 0) ? warningStatusImageName : okStatusImageName)
      }else if columnIdentifier.rawValue == "pins" {
        result?.textField?.stringValue = "\(self.mDataSource [inRowIndex].pinCount)"
        result?.imageView?.image = NSImage (named: (self.mDataSource [inRowIndex].pinCount < 2) ? warningStatusImageName : okStatusImageName)
      }else if columnIdentifier.rawValue == "subnets" {
        result?.textField?.stringValue = "\(self.mDataSource [inRowIndex].subnets.count)"
        result?.imageView?.image = NSImage (named: self.mDataSource [inRowIndex].subnetsHaveWarning ? warningStatusImageName : okStatusImageName)
      }
    }
    return result
  }

  //····················································································································

  func tableViewSelectionDidChange (_ notification: Notification) {
    var a = [StatusString] ()
    if self.selectedRow >= 0 {
      a = self.mDataSource [self.selectedRow].subnets
    }
    self.mSubnetTableView?.reloadDataSource (a)
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = NetInfoArray ()

  //····················································································································

  func reloadDataSource (_ inDataSource : NetInfoArray) {
  //--- Note selected rows
    var selectedRowContents = Set <Int> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx].netIdentifier)
      }
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "netname" {
          if s.ascending {
            self.mDataSource.sort { $0.netName.localizedStandardCompare ($1.netName) == .orderedAscending }
          }else{
            self.mDataSource.sort { $0.netName.localizedStandardCompare ($1.netName) == .orderedDescending }
          }
        }else if key == "netclass" {
          if s.ascending {
            self.mDataSource.sort { $0.netClassName.localizedStandardCompare ($1.netClassName) == .orderedAscending }
          }else{
            self.mDataSource.sort { $0.netClassName.localizedStandardCompare ($1.netClassName) == .orderedDescending }
          }
        }else if key == "pins" {
          if s.ascending {
            self.mDataSource.sort { $0.pinCount < $1.pinCount }
          }else{
            self.mDataSource.sort { $0.pinCount > $1.pinCount }
          }
        }else if key == "subnets" {
          if s.ascending {
            self.mDataSource.sort { $0.labelCount < $1.labelCount }
          }else{
            self.mDataSource.sort { $0.labelCount > $1.labelCount }
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
      if selectedRowContents.contains (self.mDataSource [idx].netIdentifier) {
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
    switch inModel.selection {
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

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  func bind_netInfo (_ model : EBReadOnlyProperty_NetInfoArray, file : String, line : Int) {
    self.mController = EBReadOnlyPropertyController (
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

//----------------------------------------------------------------------------------------------------------------------
