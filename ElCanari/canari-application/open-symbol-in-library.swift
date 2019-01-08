//
//  open-symbol-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenSymbolInLibrary : OpenInLibrary {

  //····················································································································

  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openSymbolInLibrary (_ inSender : Any?) {
    self.openInLibrary (backColor: g_Preferences!.symbolBackgroundColor)
  }

  //····················································································································

  override func buildDataSource () {
    self.buildOutlineViewDataSource (extension: "ElCanariSymbol", { (_ inRootObject : EBManagedObject?) -> [EBShape] in
      if let symbolRoot = inRootObject as? SymbolRoot {
        var symbolShape = [EBShape] ()
        for object in symbolRoot.symbolObjects_property.propval {
          if let shape = object.objectDisplay {
            symbolShape.append (shape)
          }
        }
        return symbolShape
      }else{
        return []
      }
    })
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return symbolLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
