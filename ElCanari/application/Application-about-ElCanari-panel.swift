//
//  Application-about-ElCanari-panel.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/06/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SHA_GITHUB = "commit: $SHA_GITHUB$"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBApplication {

  //····················································································································

  @IBAction func showElCanariAboutPanel (_ inSender : Any?) {
    let dict : [NSApplication.AboutPanelOptionKey : Any] = [
      .version : SHA_GITHUB
    ]
    self.orderFrontStandardAboutPanel (options: dict)
//    self.orderFrontStandardAboutPanel ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————