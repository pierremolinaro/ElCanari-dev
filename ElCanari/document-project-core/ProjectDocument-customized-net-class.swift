//
//  extension-ProjectDocument-net-class.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································
  //  SET NET CLASS
  //····················································································································

  @IBAction func setNetClassForSelectedNetAction (_ inSender : NSObject?) {
    if let netInfoTableView = self.mNetInfoTableView {
      let idx = netInfoTableView.selectedRow
      if idx >= 0 {
        let netInfo = netInfoTableView.object (at: idx)
        let netName = netInfo.netName
        self.dialogForSelectingNetClassForNet (named: netName)
      }
    }
  }

  //····················································································································

  private func dialogForSelectingNetClassForNet (named inNetName : String) {
    if let window = self.windowForSheet,
       let panel = self.mSelectNetClassPanel,
       let popup = self.mSelectNetClassPopUpButton {
    //--- Find net
      var possibleNet : NetInProject? = nil
      for netClass in self.rootObject.mNetClasses.values {
        for net in netClass.mNets.values {
          if net.mNetName == inNetName {
            possibleNet = net
            break
          }
        }
      }
    //--- Build net class popup
      if let net = possibleNet {
        popup.removeAllItems ()
        var netClasses = self.rootObject.mNetClasses
        netClasses.sort (by : { $0.mNetClassName.localizedStandardCompare ($1.mNetClassName) == .orderedAscending } )
        for netClass in netClasses.values {
          popup.addItem (withTitle: netClass.mNetClassName)
          popup.lastItem?.representedObject = netClass
          if netClass === net.mNetClass {
            popup.select (popup.lastItem)
          }
        }
      //--- Dialog
        window.beginSheet (panel) { inResponse in
          if inResponse == .stop, let netClass = popup.selectedItem?.representedObject as? NetClassInProject {
            net.mNetClass = netClass
          }
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
