//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func actionNewMergerDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared 
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Merger")
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

  @IBAction func actionNewArtworkDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared 
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Artwork")
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
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Font")
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

  @IBAction func actionNewSymbolDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Symbol")
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
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Package")
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

  @IBAction func actionNewDeviceDocument (_ inSender : AnyObject) {
    let dc = NSDocumentController.shared
    do{
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Device")
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
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: "El Canari Project")
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
