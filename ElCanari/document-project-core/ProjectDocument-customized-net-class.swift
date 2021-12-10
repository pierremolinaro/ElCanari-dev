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
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Select Net Class", bold: true, size: .regular))
    //---
      let popUpButton = AutoLayoutPopUpButton (size: .regular).expandableWidth ()
      layoutView.appendFlexibleSpace ()
      layoutView.appendView (popUpButton)
      layoutView.appendFlexibleSpace ()
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
        var netClasses = self.rootObject.mNetClasses
        netClasses.sort (by : { $0.mNetClassName.localizedStandardCompare ($1.mNetClassName) == .orderedAscending } )
        for netClass in netClasses.values {
          popUpButton.addItem (withTitle: netClass.mNetClassName)
          popUpButton.lastItem?.representedObject = netClass
          if netClass === net.mNetClass {
            popUpButton.select (popUpButton.lastItem)
          }
        }
      //---
        do{
          let hStack = AutoLayoutHorizontalStackView ()
          hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false))
          hStack.appendFlexibleSpace ()
          let okButton = AutoLayoutSheetDefaultOkButton (title: "Select", size: .regular, sheet: panel, isInitialFirstResponder: true)
          hStack.appendView (okButton)
          layoutView.appendView (hStack)
        }
      //---
        panel.contentView = AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView)
      //--- Dialog
        window.beginSheet (panel) { inResponse in
          if inResponse == .stop, let netClass = popUpButton.selectedItem?.representedObject as? NetClassInProject {
            net.mNetClass = netClass
          }
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
