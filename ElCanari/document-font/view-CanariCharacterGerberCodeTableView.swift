//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let DEBUG_EVENT = false

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    CanariCharacterGerberCodeTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariCharacterGerberCodeTableView) final class CanariCharacterGerberCodeTableView : NSTableView, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  value binding
  //····················································································································

  private var mValueController : Controller_CanariCharacterGerberCodeTableView_characterGerberCode?

  final func bind_characterGerberCode (_ object:EBReadOnlyProperty_CharacterGerberCodeClass) {
    mValueController = Controller_CanariCharacterGerberCodeTableView_characterGerberCode (object:object, tableView:self)
  }

  final func unbind_characterGerberCode () {
    mValueController?.unregister ()
    mValueController = nil
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariCharacterGerberCodeTableView_characterGerberCode
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariCharacterGerberCodeTableView_characterGerberCode :
EBReadOnlyPropertyController, NSTableViewDataSource, NSTableViewDelegate {

  private let mObject : EBReadOnlyProperty_CharacterGerberCodeClass
  private let mTableView : CanariCharacterGerberCodeTableView

  //····················································································································
  //   When init is called, table view delegate and data source are set
  //····················································································································
  
  init (object:EBReadOnlyProperty_CharacterGerberCodeClass, tableView:CanariCharacterGerberCodeTableView) {
    mTableView = tableView
    mObject = object
    super.init (observedObjects:[object], callBack: { tableView.reloadData () })
    tableView.delegate = self
    tableView.dataSource = self
//    self.mEventCallBack = { tableView.reloadData () }
  }

  //····················································································································
  
  override func unregister () {
    super.unregister ()
    mTableView.delegate = nil
    mTableView.dataSource = nil
  }


  //····················································································································
//  
//  private func updateOutlet () {
//    if DEBUG_EVENT {
//      print ("Controller_CanariCharacterGerberCodeTableView_characterGerberCode::\(#function)")
//    }
//    mTableView.reloadData ()
//  }

  //····················································································································
  //    T A B L E V I E W    D A T A S O U R C E : numberOfRowsInTableView
  //····················································································································

  func numberOfRows (in _ : NSTableView) -> Int {
    if DEBUG_EVENT {
      print ("\(#function)")
    }
    switch mObject.selection {
    case .empty, .multiple :
      return 0
    case .single (let v) :
      return v.code.count
    }
  }

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : tableView:viewForTableColumn:row:
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn: NSTableColumn?,
                  row inRowIndex: Int) -> NSView? {
    if DEBUG_EVENT {
      print ("\(#function)")
    }
    switch mObject.selection {
    case .empty, .multiple :
      return nil
    case .single (let v) :
      let columnIdentifier = inTableColumn!.identifier.rawValue
      let result : NSTableCellView = tableView.makeView (withIdentifier: NSUserInterfaceItemIdentifier(rawValue: columnIdentifier), owner:self) as! NSTableCellView
      if !reuseTableViewCells () {
        result.identifier = nil // So result cannot be reused, will be freed
      }
      if let textField = result.textField {
        let object = v.code [inRowIndex]
        if columnIdentifier == "code" {
          textField.stringValue = object.codeString ()
        }else if columnIdentifier == "comment" {
          textField.stringValue = object.comment ()
        }else{
          NSLog ("No text field for column '\(columnIdentifier)'")
        }
      }else{
        NSLog ("Unknown column '\(columnIdentifier)'")
      }
      return result
    }
  }
 
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
