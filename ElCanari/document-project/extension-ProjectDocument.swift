//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func addFont (postAction: Optional <() -> Void>) {
     var currentFontNames = Set <String> ()
     for font in self.rootObject.mFonts_property.propval {
        currentFontNames.insert (font.mFontName)
     }
     gOpenFontInLibrary?.loadDocumentFromLibrary (
       windowForSheet: self.windowForSheet!,
       alreadyLoadedDocuments: currentFontNames,
       callBack: self.addFontFromLoadFontDialog,
       postAction: postAction
     )
  }

  //····················································································································

  internal func addFontFromLoadFontDialog (_ inData : Data, _ inName : String) {
    if let (_, metadataDictionary, rootObjectDictionary) = try? loadEasyRootObjectDictionary (from: inData),
       let version = metadataDictionary [PMFontVersion] as? Int,
       let rod = rootObjectDictionary,
       let descriptiveString = rod [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
      let addedFont = ProjectFont (self.ebUndoManager)
      addedFont.mFontName = inName
      addedFont.mFontVersion = version
      addedFont.mDescriptiveString = descriptiveString
      var fonts = self.rootObject.mFonts_property.propval
      fonts.append (addedFont)
      self.rootObject.mFonts_property.setProp (fonts)
    }
  }

  //····················································································································

  internal func addComponentDialog () {
    var currentDeviceNames = Set <String> ()
    for device in self.rootObject.mDevices_property.propval {
      currentDeviceNames.insert (device.mDeviceName)
    }
     gOpenDeviceInLibrary?.loadDocumentFromLibrary (
       windowForSheet: self.windowForSheet!,
       alreadyLoadedDocuments: currentDeviceNames,
       callBack: self.addComponent,
       postAction: nil
     )
  }

  //····················································································································

  internal func addComponent (_ inData : Data, _ inName : String) {
    // Swift.print ("inName \(inName), inData \(inData.count)")
  //---
    if let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: inData),
      let deviceRoot = rootObject as? DeviceRoot,
      let version = metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int {
    //--- Create device
      let newDevice = ProjectDevice (self.ebUndoManager)
      newDevice.mDeviceName = inName
      newDevice.mDeviceVersion = version
      newDevice.mDeviceFileData = inData
    //--- Add to device list
      var devices = self.rootObject.mDevices_property.propval
      devices.append (newDevice)
      self.rootObject.mDevices_property.setProp (devices)
    //--- Free imported root object
      deviceRoot.removeRecursivelyAllRelationsShips ()
    }else{

    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
