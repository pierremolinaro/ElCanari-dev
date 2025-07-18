//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutDeviceDocument {
  @objc func exportSelectedSymbols (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
    let selectedSymbolTypes = self.symbolTypeController.selectedArray
    for symbolType in selectedSymbolTypes.values {
      let savePanel = NSSavePanel ()
      savePanel.allowedFileTypes = [ElCanariSymbol_EXTENSION]
      savePanel.allowsOtherFileTypes = false
      savePanel.nameFieldStringValue = symbolType.mTypeName + "." + ElCanariSymbol_EXTENSION
      savePanel.beginSheetModal (for: self.windowForSheet!) { inResponse in
        DispatchQueue.main.async {
          if inResponse == .OK, let url = savePanel.url {
            try? symbolType.mFileData.write (to: url)
          }
        }
      }
    }
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
