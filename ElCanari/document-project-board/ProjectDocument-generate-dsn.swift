//
//  ProjectDocument-generate-dsn.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let COMPONENT_SIDE = "ComponentSide"
let SOLDER_SIDE    = "SolderSide"

//----------------------------------------------------------------------------------------------------------------------

let DSN_SES_DIRECTORY_USER_DEFAULT_KEY = "dsn.ses.directory"

//----------------------------------------------------------------------------------------------------------------------

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction internal func performGenerateDSNFileAction (_ inUnusedSender : Any?) {
    if let b = self.rootObject.schematicHasErrorOrWarning, !b {
      self.performGenerateDSNFile ()
    }else if let window = self.windowForSheet {
      let alert = NSAlert ()
      alert.messageText = "Schematic has warning(s) and/or error(s). Continue?"
      alert.addButton (withTitle: "Cancel")
      alert.addButton (withTitle: "Continue")
      alert.beginSheetModal (
        for: window,
        completionHandler: { if $0 == .alertSecondButtonReturn { self.performGenerateDSNFile () } }
      )
    }
  }

  //····················································································································

  internal func performGenerateDSNFile () {
    var hasTrack = false
    for object in self.rootObject.mBoardObjects {
      if object is BoardTrack {
        hasTrack = true
        break
      }
    }
  let savePanel = NSSavePanel ()
  let savedDirectoryURL = savePanel.directoryURL
  //--- Default directory
    let ud = UserDefaults.standard
    if let url = ud.url (forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY) {
      savePanel.directoryURL = url
    }
  //--- Save Panel
    savePanel.accessoryView = self.mSaveDSNFileAuxiliaryView
    self.mExportTrackAndViasToDSNSwitch?.isEnabled = hasTrack
    if !hasTrack {
      self.mExportTrackAndViasToDSNSwitch?.state = .off
    }
    savePanel.allowedFileTypes = ["dsn"]
    savePanel.allowsOtherFileTypes = false
    savePanel.nameFieldStringValue = self.rootObject.mDSNFileProposedName
    savePanel.beginSheetModal (for: self.windowForSheet!) { inResponse in
      savePanel.orderOut (nil)
      if inResponse == .OK, let url = savePanel.url {
        ud.set (savePanel.directoryURL, forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY)
        do{
          let exportTracks = hasTrack && (self.mExportTrackAndViasToDSNSwitch!.state == .on)
          let s = self.dsnContents (exportTracks)
          try s.write (to: url, atomically: true, encoding: .utf8)
        }catch (let error) {
          self.windowForSheet!.presentError (error)
        }
        savePanel.directoryURL = savedDirectoryURL
        self.rootObject.mDSNFileProposedName = savePanel.nameFieldStringValue
      }
    }
  }

  //····················································································································

  internal func dsnContents (_ inExportTracks : Bool) -> String {
  //--- Selecting DSN Unit
    let converter = CanariUnitToDSNUnitConverter (unit: .millimeter)
    let clearanceInDSNUnit = converter.dsnUnitFromCanariUnit (self.rootObject.mLayoutClearance)
  //--- Border
    let boardLimitExtend = -self.rootObject.mBoardLimitsWidth / 2
    let boardBoundBox = self.rootObject.interiorBoundBox!.insetBy (dx: boardLimitExtend, dy: boardLimitExtend)
    let signalPolygonVertices = self.buildSignalPolygon (converter)
  //--- Restrict rectangles
    var restrictRectangles = [RestrictRectangleForDSNExport] ()
    for object in self.rootObject.mBoardObjects {
      if let restrictRectangle = object as? BoardRestrictRectangle {
        let r = CanariRect (left: restrictRectangle.mX, bottom: restrictRectangle.mY, width: restrictRectangle.mWidth, height: restrictRectangle.mHeight)
        let rr = RestrictRectangleForDSNExport (
          rect: r,
          frontSide: restrictRectangle.mIsInFrontLayer,
          backSide: restrictRectangle.mIsInBackLayer
        )
        restrictRectangles.append (rr)
      }
    }
  //--- Net classes
    var maxTrackWithInDSNUnit : Double = 0.0
    var netClasses = [NetClassForDSNExport] ()
    for netClass in self.rootObject.mNetClasses {
      var netNames = [String] ()
      for net in netClass.mNets {
        if net.mPoints.count > 0 {
          netNames.append (net.mNetName)
        }
      }
      let trackWidth = converter.dsnUnitFromCanariUnit (netClass.mTrackWidth)
      maxTrackWithInDSNUnit = max (maxTrackWithInDSNUnit, trackWidth)
      let nc = NetClassForDSNExport (
        name: netClass.mNetClassName,
        trackWidthInDSNUnit: trackWidth,
        viaPadDiameterInDSNUnit: converter.dsnUnitFromCanariUnit (netClass.mViaPadDiameter),
        netNames: netNames,
        allowTracksOnFrontSide: netClass.mAllowTracksOnFrontSide,
        allowTracksOnBackSide: netClass.mAllowTracksOnBackSide
      )
      netClasses.append (nc)
    }
  //--- Enumerate components
    var packageDictionary = [PackageDictionaryKeyForDSNExport : Int] ()
    var packageArrayForRouting = [PackageTypeForDSNExport] ()
    var componentArrayForRouting = [ComponentForDSNExport] ()
    var padTypeArrayForRouting = [PadTypeForDSNExport] ()
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Placed on board
        let device = component.mDevice!
        let packageIndex = indexForPackage (
          device,
          component.mSelectedPackage!,
          &packageDictionary,
          &packageArrayForRouting,
          &padTypeArrayForRouting,
          converter
        )
      //--- Build net list
        var padNetArray = [PadNetDescriptorForDSNExport] ()
        let componentPadDictionary : ComponentPadDescriptorDictionary = component.componentPadDictionary!
        let componentPads : [ComponentPadDescriptor] = Array (componentPadDictionary.values)
        let padNetDictionary : PadNetDictionary = component.padNetDictionary!
        for pad in componentPads {
          let pnd = PadNetDescriptorForDSNExport (padString: pad.padName, netName: padNetDictionary [pad.padName])
          padNetArray.append (pnd)
        }
      //--- Enter component
        let cfr = ComponentForDSNExport (
          packageIndex: packageIndex,
          componentName: component.componentName!,
          placed: component.mRoot != nil,
          originX: component.mX,
          originY: component.mY,
          rotation: Double (component.mRotation) / 1000.0,
          side: component.mSide,
          netList: padNetArray.sorted { $0.padString < $1.padString }
        )
        componentArrayForRouting.append (cfr)
      }
    }
  //--- Generate
    var s = ""
    s += "(pcb \"\(self.documentFilePath ?? "")\"\n"
    s += "  (parser\n"
    s += "    (string_quote \")\n"
    s += "    (space_in_quoted_tokens on)\n"
    s += "    (host_cad \"ElCanari\")\n"
    s += "    (host_version \"\(ElCanariApplicationVersionString ())\")\n"
    s += "  )\n"
    s += "  (resolution \(converter.unitString) \(converter.resolution))\n"
    s += "  (structure\n"
    addBoardBoundary (&s, boardBoundBox, signalPolygonVertices, converter)
    autorouteSettings (&s, self.rootObject.mAutoRouterPreferredDirections)
    addSnapAngle (&s, self.rootObject.mAutorouterSnapAngle)
    addViaClasses (&s, netClasses)
    s += "    (control (via_at_smd off))\n"
    addDefaultRule (&s, maxWidthInDSNUnit: maxTrackWithInDSNUnit, clearanceInDSNUnit: clearanceInDSNUnit)
    addRestrictRectangles (&s, restrictRectangles, converter)
    s += "  )\n"
    addComponentsPlacement (
      &s,
      componentArrayForRouting,
      packageArrayForRouting,
      self.rootObject.mRouteDirection,
      self.rootObject.mRouteOrigin,
      boardBoundBox,
      converter
    )
    s += "  (library\n"
    addDeviceLibrary (&s, packageArrayForRouting)
    addViaPadStackLibrary (&s, netClasses)
    addComponentPadStackLibrary (&s, padTypeArrayForRouting, converter)
    s += "  )\n"
    s += "  (network\n"
    addNetwork (&s, componentArrayForRouting)
    addViaRules (&s, netClasses)
    addNetClasses (&s, netClasses)
    s += "  )\n"
    if inExportTracks {
      self.exportTracksAndVias (&s, converter)
    }
    s += ")\n"
    return s
  }

  //····················································································································

  private func buildSignalPolygon (_ inConverter : CanariUnitToDSNUnitConverter) -> EBLinePath { // Points in DSN Unit
    switch self.rootObject.mBoardShape {
    case .bezierPathes :
      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
      for curve in self.rootObject.mBorderCurves {
        let descriptor = curve.descriptor!
        curveDictionary [descriptor.p1] = descriptor
      }
      var clearanceBP = EBBezierPath ()
      var descriptor = self.rootObject.mBorderCurves [0].descriptor!
      let p = descriptor.p1
      clearanceBP.move (to: inConverter.dsnPointFromCanariPoint (p))
      var loop = true
      while loop {
        switch descriptor.shape {
        case .line :
          clearanceBP.line (to: inConverter.dsnPointFromCanariPoint (descriptor.p2))
        case .bezier :
          let cp1 = inConverter.dsnPointFromCanariPoint (descriptor.cp1)
          let cp2 = inConverter.dsnPointFromCanariPoint (descriptor.cp2)
          clearanceBP.curve (to: inConverter.dsnPointFromCanariPoint (descriptor.p2), controlPoint1: cp1, controlPoint2: cp2)
        }
        descriptor = curveDictionary [descriptor.p2]!
        loop = p != descriptor.p1
      }
      return clearanceBP.pointsByFlattening (withFlatness: 0.1) [0]
    case .rectangular :
      let d = self.rootObject.mBoardClearance + self.rootObject.mBoardLimitsWidth
      let r = CanariRect (
        left: d,
        bottom: d,
        width: self.rootObject.mRectangularBoardWidth - 2 * d,
        height: self.rootObject.mRectangularBoardHeight - 2 * d
      )
      return EBBezierPath (rect: inConverter.dsnRectFromCanariRect (r)).pointsByFlattening (withFlatness: 0.1) [0]
    }
  }

  //····················································································································

  private func exportTracksAndVias (_ ioString : inout String,
                                    _ inConverter : CanariUnitToDSNUnitConverter) {
    ioString += "  (wiring\n"
  //--- Export tracks
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let side : String
        switch track.mSide {
        case .front : side = COMPONENT_SIDE
        case .back : side = SOLDER_SIDE
        }
        let optionalNetName = track.mNet?.mNetName
        let widthMM = inConverter.dsnUnitFromCanariUnit (track.actualTrackWidth!)
        let p1 = inConverter.dsnPointFromCanariPoint (track.mConnectorP1!.location!)
        let p2 = inConverter.dsnPointFromCanariPoint (track.mConnectorP2!.location!)
        ioString += "    (wire\n"
        if let netName = optionalNetName {
          ioString += "      (net \"\(netName)\")\n"
        }
        ioString += "      (path \(side) \(widthMM) \(p1.x) \(p1.y) \(p2.x) \(p2.y))\n"
        if track.mIsPreservedByAutoRouter {
          ioString += "      (type protect)\n"
        }
        ioString += "      (clearance_class default)\n"
        ioString += "    )\n"
      }
    }
  //--- Export via
    for object in self.rootObject.mBoardObjects {
      if let via = object as? BoardConnector, let isVia = via.isVia, isVia {
        let p = inConverter.dsnPointFromCanariPoint (via.location!)
        let netName = via.netNameFromTracks!
        ioString += "    (via \"viaForClassDefault\" \(p.x) \(p.y)\n"
        ioString += "      (net \"\(netName)\")\n"
        ioString += "      (clearance_class default)\n"
        ioString += "    )\n"
      }
    }
  //---
    ioString += "  )\n"
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

enum DSNUnit { case millimeter, micrometer}

//----------------------------------------------------------------------------------------------------------------------

struct CanariUnitToDSNUnitConverter {

  //····················································································································

  let unit : DSNUnit

  //····················································································································

  var unitString : String {
    switch unit {
    case .millimeter :
      return "mm"
    case .micrometer :
      return "um"
    }
  }

  //····················································································································

  var resolution : Int {
    switch unit {
    case .millimeter :
      return 10000
    case .micrometer :
      return 10
    }
  }

  //····················································································································

  func dsnUnitFromCanariUnit (_ inValue : Int ) -> Double {
    switch unit {
    case .millimeter :
      return Double (inValue) / Double (ONE_MILLIMETER_IN_CANARI_UNIT)
    case .micrometer :
      return 1000.0 * Double (inValue) / Double (ONE_MILLIMETER_IN_CANARI_UNIT)
    }
  }

  //····················································································································

  func dsnPointFromCanariPoint (_ inP : CanariPoint) -> NSPoint {
    return NSPoint (x: self.dsnUnitFromCanariUnit (inP.x), y: self.dsnUnitFromCanariUnit (inP.y))
  }

  //····················································································································

  func dsnRectFromCanariRect (_ inP : CanariRect) -> NSRect {
    return NSRect (
      x: self.dsnUnitFromCanariUnit (inP.origin.x),
      y: self.dsnUnitFromCanariUnit (inP.origin.y),
      width: self.dsnUnitFromCanariUnit (inP.size.width),
      height: self.dsnUnitFromCanariUnit (inP.size.height)
    )
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func indexForPackage (_ inDevice : DeviceInProject,
                                  _ inSelectedPackage : DevicePackageInProject,
                                  _ ioPackageDictionary : inout [PackageDictionaryKeyForDSNExport : Int],
                                  _ ioPackageArrayForRouting : inout [PackageTypeForDSNExport],
                                  _ ioPadTypeArrayForRouting : inout [PadTypeForDSNExport],
                                  _ inConverter : CanariUnitToDSNUnitConverter) -> Int {
  let key = PackageDictionaryKeyForDSNExport (device: inDevice, package: inSelectedPackage)
  if let idx = ioPackageDictionary [key] {
    return idx
  }else{
  //--- Enter device index in device dictionary
    let idx = ioPackageArrayForRouting.count
    ioPackageDictionary [key] = idx
  //--- Pad array
    let padDictionary = inSelectedPackage.packagePadDictionary!
    let deviceCenter = padDictionary.padsRect.center
    var padArrayForRouting = [PadInstanceForDSNExport] ()
    for (_, masterPad) in padDictionary {
    //--- Enter master pad
      let masterPadForRouting = findOrAddPadType (
        canariWidth: masterPad.padSize.width,
        canariHeight: masterPad.padSize.height,
        onComponentSide: true,
        onOppositeSide: masterPad.style == .traversing,
        shape: masterPad.shape,
        &ioPadTypeArrayForRouting
      )
      let psr = PadInstanceForDSNExport (
        name: masterPad.name,
        masterPad: masterPadForRouting,
        centerX: inConverter.dsnUnitFromCanariUnit (masterPad.center.x - deviceCenter.x),
        centerY: inConverter.dsnUnitFromCanariUnit (masterPad.center.y - deviceCenter.y)
      )
      padArrayForRouting.append (psr)
    //--- Enter slave pads
      for slavePad in masterPad.slavePads {
        let onComponentSide : Bool
        let onOppositeSide : Bool
        switch slavePad.style {
        case .oppositeSide : onComponentSide = false ; onOppositeSide = true
        case .componentSide : onComponentSide = true  ; onOppositeSide = false
        case .traversing : onComponentSide = true  ; onOppositeSide = true
        }
      //--- Enter slave pad
        let slavePadForRouting = findOrAddPadType (
          canariWidth: slavePad.padSize.width,
          canariHeight: slavePad.padSize.height,
          onComponentSide: onComponentSide,
          onOppositeSide: onOppositeSide,
          shape: slavePad.shape,
          &ioPadTypeArrayForRouting
        )
        let pir = PadInstanceForDSNExport (
          name: masterPad.name, // + ":\(slavePadIndex)",
          masterPad: slavePadForRouting,
          centerX: inConverter.dsnUnitFromCanariUnit (slavePad.center.x - deviceCenter.x),
          centerY: inConverter.dsnUnitFromCanariUnit (slavePad.center.y - deviceCenter.y)
        )
        padArrayForRouting.append (pir)
      }
    }
  //--- Enter in package array
    let pfr = PackageTypeForDSNExport (
      typeName: inDevice.mDeviceName + ":" + inSelectedPackage.mPackageName,
      padArray: padArrayForRouting.sorted { $0.name < $1.name }
    )
    ioPackageArrayForRouting.append (pfr)
  //---
    return idx
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func findOrAddPadType (canariWidth inWidth : Int,
                                   canariHeight inHeight : Int,
                                   onComponentSide inComponentSide : Bool,
                                   onOppositeSide  inOppositeSide : Bool,
                                   shape inShape : PadShape,
                                   _ ioPadTypeArrayForRouting : inout [PadTypeForDSNExport]) -> PadTypeForDSNExport {
//--- Search in existing pads
  for mp in ioPadTypeArrayForRouting {
    if ((mp.canariWidth == inWidth) && (mp.canariHeight == inHeight) && (mp.onComponentSide == inComponentSide)  && (mp.onOppositeSide == inOppositeSide) && (mp.shape == inShape)) {
      return mp
    }
  }
//--- If not found, create it
  let newPad = PadTypeForDSNExport (
    name: "ps\(ioPadTypeArrayForRouting.count)",
    canariWidth: inWidth,
    canariHeight: inHeight,
    shape: inShape,
    onComponentSide: inComponentSide,
    onOppositeSide: inOppositeSide
  )
  ioPadTypeArrayForRouting.append (newPad)
  return newPad
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct PadNetDescriptorForDSNExport {
  let padString : String
  let netName : String?
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct PackageDictionaryKeyForDSNExport : Hashable {
  let device : DeviceInProject
  let package : DevicePackageInProject
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct NetClassForDSNExport {
  let name : String
  let trackWidthInDSNUnit : Double
  let viaPadDiameterInDSNUnit : Double
  let netNames : [String]
  let allowTracksOnFrontSide : Bool
  let allowTracksOnBackSide : Bool
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct RestrictRectangleForDSNExport {
  let rect : CanariRect
  let frontSide : Bool
  let backSide  : Bool
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct ComponentForDSNExport {
  let packageIndex : Int
  let componentName : String
  let placed : Bool
  let originX : Int
  let originY : Int
  let rotation : Double
  let side : ComponentSide
  let netList : [PadNetDescriptorForDSNExport]
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct PackageTypeForDSNExport {
  let typeName : String
  let padArray : [PadInstanceForDSNExport]
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct PadInstanceForDSNExport {
  let name : String
  let masterPad : PadTypeForDSNExport
  let centerX : Double // In DSN Unit
  let centerY : Double // In DSN Unit
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate struct PadTypeForDSNExport {
  let name : String
  let canariWidth  : Int
  let canariHeight : Int
  let shape : PadShape
  let onComponentSide : Bool
  let onOppositeSide  : Bool

  //····················································································································

  func padStringFor (side inSide : String,
                     _ inConverter : CanariUnitToDSNUnitConverter) -> String {
    let halfWidth = inConverter.dsnUnitFromCanariUnit (self.canariWidth) / 2.0
    let halfHeight = inConverter.dsnUnitFromCanariUnit (self.canariHeight) / 2.0
    let shapeString : String
    switch self.shape {
    case .rect :
      shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
    case .round :
      if halfWidth == halfHeight { // Circular pad
        shapeString = "(circle \(inSide) \(halfWidth * 2.0))"
      }else{ // Oblong: generate an octogon
        //shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
        let s2 : Double = sqrt (2.0)
        let w = halfWidth * 2.0
        let h = halfHeight * 2.0
        let x = -halfWidth
        let y = -halfHeight
        let lg = min (w, h) / (1.0 + s2)
        var vertices = [NSPoint] ()
        vertices.append (NSPoint (x: x + lg / s2,     y: y + h))
        vertices.append (NSPoint (x: x + w - lg / s2, y: y + h))
        vertices.append (NSPoint (x: x + w,           y: y + h - lg / s2))
        vertices.append (NSPoint (x: x + w,           y: y + lg / s2))
        vertices.append (NSPoint (x: x + w - lg / s2, y: y))
        vertices.append (NSPoint (x: x + lg / s2,     y: y))
        vertices.append (NSPoint (x: x,               y: y + lg / s2))
        vertices.append (NSPoint (x: x,               y: y + h - lg / s2))
        var s = "(polygon \(inSide) 0"
        for p in vertices {
          s += " \(p.x) \(p.y)"
        }
        s += " \(vertices [0].x) \(vertices [0].y)" // Close path
        s += ")"
        shapeString = s
      }
    case .octo :
      let s2 : Double = sqrt (2.0)
      let w = halfWidth * 2.0
      let h = halfHeight * 2.0
      let x = -halfWidth
      let y = -halfHeight
      let lg = min (w, h) / (1.0 + s2)
      var vertices = [NSPoint] ()
      vertices.append (NSPoint (x: x + lg / s2,     y: y + h))
      vertices.append (NSPoint (x: x + w - lg / s2, y: y + h))
      vertices.append (NSPoint (x: x + w,           y: y + h - lg / s2))
      vertices.append (NSPoint (x: x + w,           y: y + lg / s2))
      vertices.append (NSPoint (x: x + w - lg / s2, y: y))
      vertices.append (NSPoint (x: x + lg / s2,     y: y))
      vertices.append (NSPoint (x: x,               y: y + lg / s2))
      vertices.append (NSPoint (x: x,               y: y + h - lg / s2))
      var s = "(polygon \(inSide) 0"
      for p in vertices {
        s += " \(p.x) \(p.y)"
      }
      s += " \(vertices [0].x) \(vertices [0].y)" // Close path
      s += ")"
      shapeString = s
    }
    return shapeString
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addNetwork (_ ioString : inout String,
                             _ inComponentArrayForRouting : [ComponentForDSNExport]) {
  var netWorkDictionary = [String : [String]] ()
  for component in inComponentArrayForRouting {
    let componentName = component.componentName
    for padDescriptor in component.netList {
      if let netName = padDescriptor.netName {
        netWorkDictionary [netName] = (netWorkDictionary [netName] ?? []) + [componentName + "-" + padDescriptor.padString]
      }
    }
  }
  for (netName, padList) in netWorkDictionary {
    ioString += "    (net \"\(netName)\"\n"
    ioString += "      (pins\n"
    for pad in padList {
      ioString += "        \(pad)\n"
    }
    ioString += "      )\n"
    ioString += "    )\n"
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addViaPadStackLibrary (_ ioString : inout String,
                                        _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (padstack \"viaForClass\(netClass.name)\"\n"
    ioString += "      (shape (circle \(SOLDER_SIDE) \(netClass.viaPadDiameterInDSNUnit)))\n"
    ioString += "      (shape (circle \(COMPONENT_SIDE) \(netClass.viaPadDiameterInDSNUnit)))\n"
    ioString += "    )\n"
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addComponentPadStackLibrary (_ ioString : inout String,
                                              _ inPadTypeArrayForRouting : [PadTypeForDSNExport],
                                              _ inConverter : CanariUnitToDSNUnitConverter) {
  for pad in inPadTypeArrayForRouting {
    ioString += "    (padstack \"\(pad.name)\"\n"
    if pad.onComponentSide {
      ioString += "      (shape \(pad.padStringFor (side: COMPONENT_SIDE, inConverter)))\n"
    }
    if pad.onOppositeSide {
      ioString += "      (shape \(pad.padStringFor (side: SOLDER_SIDE, inConverter)))\n"
    }
    ioString += "    )\n"
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addDeviceLibrary (_ ioString : inout String,
                                   _ inPackageArrayForRouting : [PackageTypeForDSNExport]) {
  for package in inPackageArrayForRouting {
    ioString += "    (image \"\(package.typeName)\"\n"
    for pad in package.padArray {
      ioString += "      (pin \(pad.masterPad.name) \(pad.name) \(pad.centerX) \(pad.centerY))\n"
    }
    ioString += "    )\n"
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addBoardBoundary (_ ioString : inout String,
                                   _ inBoardBoundBox : CanariRect,
                                   _ inSignalPolygonVertices : EBLinePath, // In DSN Unit
                                   _ inConverter : CanariUnitToDSNUnitConverter) {
//  let bbLeft = inConverter.dsnUnitFromCanariUnit (inBoardBoundBox.origin.x)
//  let bbBottom = inConverter.dsnUnitFromCanariUnit (inBoardBoundBox.origin.y)
//  let bbRight = bbLeft + inConverter.dsnUnitFromCanariUnit (inBoardBoundBox.size.width)
//  let bbTop = bbBottom + inConverter.dsnUnitFromCanariUnit (inBoardBoundBox.size.height)
//  ioString += "    (boundary\n"
//  ioString += "      (rect pcb \(bbLeft) \(bbBottom) \(bbRight) \(bbTop))\n"
//  ioString += "    )\n"
  ioString += "    (boundary\n"
  ioString += "      (path pcb 0\n"
  ioString += "        \(inSignalPolygonVertices.origin.x) \(inSignalPolygonVertices.origin.y)\n"
  for p in inSignalPolygonVertices.lines {
    ioString += "        \(p.x) \(p.y)\n"
  }
  if inSignalPolygonVertices.closed {
    ioString += "        \(inSignalPolygonVertices.origin.x) \(inSignalPolygonVertices.origin.y)\n"
  }
  ioString += "      )\n"
  ioString += "    )\n"
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addSnapAngle (_ ioString : inout String, _ inSnapAngle : AutorouterSnapAngle) {
  ioString += "    (snap_angle\n"
  switch inSnapAngle {
  case .rectilinear :
    ioString += "      ninety_degree\n"
  case .octolinear :
    ioString += "      fortyfive_degree\n"
  case .anyAngle :
    ioString += "      none\n"
  }
  ioString += "    )\n"
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func autorouteSettings (_ ioString : inout String,
                                    _ inRouterPreferredDirection : AutorouterPreferredDirections) {
  let frontPreferredDir : String
  let backPreferredDir : String
  switch inRouterPreferredDirection {
  case .hFrontVback :
    frontPreferredDir = "horizontal"
    backPreferredDir = "vertical"
  case .vFrontHback :
    frontPreferredDir = "vertical"
    backPreferredDir = "horizontal"
  }
  ioString += "    (layer \(COMPONENT_SIDE) (type signal))\n"
  ioString += "    (layer \(SOLDER_SIDE) (type signal))\n"
  ioString += "    (autoroute_settings\n"
  ioString += "      (vias on)\n"
  ioString += "      (via_costs 50)\n"
  ioString += "      (plane_via_costs 5)\n"
  ioString += "      (start_ripup_costs 100)\n"
  ioString += "      (start_pass_no 1)\n"
  ioString += "      (layer_rule \(COMPONENT_SIDE)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction \(frontPreferredDir))\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
  ioString += "      )\n"
  ioString += "      (layer_rule \(SOLDER_SIDE)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction \(backPreferredDir))\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
  ioString += "      )\n"
  ioString += "    )\n"
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addViaClasses (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  ioString += "    (via"
  for netClass in inNetClasses {
    ioString += " \"viaForClass\(netClass.name)\""
  }
  ioString += ")\n"
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addViaRules (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (via_rule\n"
    ioString += "      \"viaRuleForClass\(netClass.name)\" \"viaForClass\(netClass.name)\"\n"
    ioString += "    )\n"
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addNetClasses (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (class \"class_\(netClass.name)\"\n"
    for netName in netClass.netNames {
      ioString += "      \"\(netName)\"\n"
    }
    ioString += "      (clearance_class default)\n"
    ioString += "      (via_rule \"viaRuleForClass\(netClass.name)\")\n"
    ioString += "      (rule\n"
    ioString += "        (width \(netClass.trackWidthInDSNUnit))\n"
    ioString += "      )\n"
    ioString += "      (circuit\n"
    ioString += "        (use_layer"
    if netClass.allowTracksOnFrontSide {
      ioString += " \(COMPONENT_SIDE)"
    }
    if netClass.allowTracksOnBackSide {
      ioString += " \(SOLDER_SIDE)"
    }
    ioString += ")\n"
    ioString += "      )\n"
    ioString += "    )\n"
  }
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addDefaultRule (_ ioString : inout String,
                                 maxWidthInDSNUnit inTrackMaxWidth : Double,
                                 clearanceInDSNUnit inClearance : Double) {
  ioString += "    (rule\n"
  ioString += "      (width \(inTrackMaxWidth))\n" // Required !!!!
  ioString += "      (clearance \(inClearance))\n"
  ioString += "    )\n"
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func componentComparison (_ inLeft : ComponentForDSNExport,
                                      _ inOrigin : CanariPoint,
                                      _ inRight : ComponentForDSNExport) -> Bool {
  let leftDx = inOrigin.x - inLeft.originX
  let leftDy = inOrigin.y - inLeft.originY
  let squareDistanceLeft = leftDx * leftDx + leftDy * leftDy
  let rightDx = inOrigin.x - inRight.originX
  let rightDy = inOrigin.y - inRight.originY
  let squareDistanceRight = rightDx * rightDx + rightDy * rightDy
  return squareDistanceLeft < squareDistanceRight
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addComponentsPlacement (_ ioString : inout String,
                                         _ inComponents : [ComponentForDSNExport],
                                         _ inPackageArrayForRouting : [PackageTypeForDSNExport],
                                         _ inRouteDirection : RouteDirection,
                                         _ inRouteOrigin : RouteOrigin,
                                         _ inBoardRect : CanariRect,
                                         _ inConverter : CanariUnitToDSNUnitConverter) {
//--- Sort components

  let origin : CanariPoint
  switch inRouteOrigin {
  case .center:
    origin = inBoardRect.center
  case .bottomLeft:
    origin = inBoardRect.bottomLeft
  case .middleBottom:
    origin = inBoardRect.bottomCenter
  case .bottomRight:
    origin = inBoardRect.bottomRight
  case .middleRight:
    origin = inBoardRect.middleRight
  case .topRight:
    origin = inBoardRect.topRight
  case .middleTop:
    origin = inBoardRect.topCenter
  case .topLeft:
    origin = inBoardRect.topLeft
  case .middleLeft:
    origin = inBoardRect.middleLeft
  }
  let components : [ComponentForDSNExport]
  switch inRouteDirection {
  case .from :
    components = inComponents.sorted { componentComparison ($1, origin, $0) }
  case .to :
    components = inComponents.sorted { componentComparison ($0, origin, $1) }
  }
//--- Write components
  ioString += "  (placement\n"
  for component in components {
    let x = inConverter.dsnUnitFromCanariUnit (component.originX)
    let y = inConverter.dsnUnitFromCanariUnit (component.originY)
    let side : String
    switch component.side {
    case .back : side = "back"
    case .front : side = "front"
    }
    ioString += "    (component \"\(inPackageArrayForRouting [component.packageIndex].typeName)\"\n"
    ioString += "      (place\n"
    ioString += "        \(component.componentName) \(x) \(y) \(side) \(component.rotation)\n"
    var idx = 1
    for padDescriptor in component.netList {
      ioString += "        (pin \(padDescriptor.padString) (clearance_class default))\n"
      idx += 1
    }
    ioString += "      )\n"
    ioString += "    )\n"
  }
  ioString += "  )\n"
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate func addRestrictRectangles (_ ioString : inout String,
                                        _ inRestrictRectangles : [RestrictRectangleForDSNExport],
                                        _ inConverter : CanariUnitToDSNUnitConverter) {
  for rr in inRestrictRectangles {
    let left = inConverter.dsnUnitFromCanariUnit (rr.rect.left)
    let bottom = inConverter.dsnUnitFromCanariUnit (rr.rect.bottom)
    let right = left + inConverter.dsnUnitFromCanariUnit (rr.rect.width)
    let top = bottom + inConverter.dsnUnitFromCanariUnit (rr.rect.height)
    if rr.frontSide {
      ioString += "    (keepout\n"
      ioString += "      (rect \(COMPONENT_SIDE) \(left) \(bottom) \(right) \(top))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.backSide {
      ioString += "    (keepout\n"
      ioString += "      (rect \(SOLDER_SIDE) \(left) \(bottom) \(right) \(top))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
  }
}

//----------------------------------------------------------------------------------------------------------------------
