//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func actionNewMergerDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared 
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.merger")
      if let newDocument = possibleNewDocument as? NSDocument {
        dc.addDocument (newDocument)
        newDocument.makeWindowControllers ()
        newDocument.showWindows ()
      }
    }catch let error {
      _ = dc.presentError (error)
    }
  }

  //····················································································································

  @IBAction func actionNewArtworkDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared 
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.artwork")
      if let newDocument = possibleNewDocument as? NSDocument {
        dc.addDocument (newDocument)
        newDocument.makeWindowControllers ()
        newDocument.showWindows ()
      }
    }catch let error {
      dc.presentError (error)
    }
  }

  //····················································································································

  @IBAction func actionNewFontDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.font")
      if let newDocument = possibleNewDocument as? NSDocument {
        dc.addDocument (newDocument)
        newDocument.makeWindowControllers ()
        newDocument.showWindows ()
      }
    }catch let error {
      _ = dc.presentError (error)
    }
  }

  //····················································································································

  @IBAction func actionNewSymbolDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.symbol")
      if let newDocument = possibleNewDocument as? NSDocument {
        dc.addDocument (newDocument)
        newDocument.makeWindowControllers ()
        newDocument.showWindows ()
      }
    }catch let error {
      dc.presentError (error)
    }
  }

  //····················································································································

  @IBAction func actionNewPackageDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.package")
      if let newDocument = possibleNewDocument as? NSDocument {
        dc.addDocument (newDocument)
        newDocument.makeWindowControllers ()
        newDocument.showWindows ()
      }
    }catch let error {
      _ = dc.presentError (error)
    }
  }

  //····················································································································

  @IBAction func actionNewDeviceDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.device")
      if let newDocument = possibleNewDocument as? NSDocument {
        dc.addDocument (newDocument)
        newDocument.makeWindowControllers ()
        newDocument.showWindows ()
      }
    }catch let error {
      dc.presentError (error)
    }
  }

  //····················································································································

  @IBAction func actionNewProjectDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "name.pcmolinaro.elcanari.project")
      if let newDocument = possibleNewDocument as? NSDocument {
        setStartOperationDateToNow ("New Document")
        dc.addDocument (newDocument)
        appendDocumentFileOperationInfo ("addDocument done")
        newDocument.makeWindowControllers ()
        appendDocumentFileOperationInfo ("makeWindowControllers done")
        newDocument.showWindows ()
        appendDocumentFileOperationInfo ("showWindows done")
      }
    }catch let error {
      _ = dc.presentError (error)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
