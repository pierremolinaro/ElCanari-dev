//
//  ProjectDocument-generate-dsn.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let FRONT_SIDE_LAYOUT = "ComponentSideLayer"
let BACK_SIDE_LAYOUT  = "BackSideLayer"
let INNER1_LAYOUT     = "Inner1Layer"
let INNER2_LAYOUT     = "Inner2Layer"
let INNER3_LAYOUT     = "Inner3Layer"
let INNER4_LAYOUT     = "Inner4Layer"

//--------------------------------------------------------------------------------------------------

let DSN_SES_DIRECTORY_USER_DEFAULT_KEY = "dsn.ses.directory"

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func performGenerateDSNFile () {
    var hasTrack = false
    for object in self.rootObject.mBoardObjects.values {
      if object is BoardTrack {
        hasTrack = true
        break
      }
    }
    let savePanel = NSSavePanel ()
    let savedDirectoryURL = savePanel.directoryURL
  //--- Default directory
    if let url = UserDefaults.standard.url (forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY) {
      savePanel.directoryURL = url
    }
  //--- Save Panel
    savePanel.allowedFileTypes = ["dsn"]
    savePanel.allowsOtherFileTypes = false
    savePanel.nameFieldStringValue = self.rootObject.mDSNFileProposedName
    savePanel.beginSheetModal (for: self.windowForSheet!) { inResponse in
      DispatchQueue.main.async {
        savePanel.orderOut (nil)
        if inResponse == .OK, let url = savePanel.url {
          let ud = UserDefaults.standard
          ud.set (savePanel.directoryURL, forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY)
          do{
            let exportTracks = hasTrack && self.rootObject.mExportExistingTracksAndVias
            let s = self.dsnContents (exportTracks)
            try s.write (to: url, atomically: true, encoding: .utf8)
          }catch (let error) {
            _ = self.windowForSheet!.presentError (error)
          }
          savePanel.directoryURL = savedDirectoryURL
          self.rootObject.mDSNFileProposedName = savePanel.nameFieldStringValue
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func dsnContents (_ inExportTracks : Bool) -> String {
  //--- Selecting DSN Unit
    let converter = CanariUnitToDSNUnitConverter (unit: .millimeter)
//    let converter = CanariUnitToDSNUnitConverter (unit: .mil)
//    let converter = CanariUnitToDSNUnitConverter (unit: .micrometer)
    let clearanceInDSNUnit = converter.dsnUnitFromCanariUnit (self.rootObject.mLayoutClearance)
  //--- Border
    let boardLimitExtend = -self.rootObject.mBoardLimitsWidth / 2
    let boardBoundBox = self.rootObject.interiorBoundBox!.insetBy (dx: boardLimitExtend, dy: boardLimitExtend)
    let signalPolygonVertices = self.buildSignalPolygon (converter)
  //--- Layer configuration
    let layerConfiguration = self.rootObject.mLayerConfiguration
  //--- Restrict rectangles
    var restrictRectangles = [RestrictRectangleForDSNExport] ()
    for object in self.rootObject.mBoardObjects.values {
      if let propertyRectangle = object as? BoardRestrictRectangle, !propertyRectangle.mAllowTracksInside {
        let r = CanariRect (left: propertyRectangle.mX, bottom: propertyRectangle.mY, width: propertyRectangle.mWidth, height: propertyRectangle.mHeight)
        let rr = RestrictRectangleForDSNExport (
          rect: r,
          rotationInDegrees: 0.0,
          frontSide: propertyRectangle.mIsInFrontLayer,
          backSide: propertyRectangle.mIsInBackLayer,
          inner1Side: propertyRectangle.mIsInInner1Layer,
          inner2Side: propertyRectangle.mIsInInner2Layer,
          inner3Side: propertyRectangle.mIsInInner3Layer,
          inner4Side: propertyRectangle.mIsInInner4Layer
        )
        restrictRectangles.append (rr)
      }else if let nph = object as? NonPlatedHole {
        let r = CanariRect (
          center: CanariPoint (x: nph.mX, y: nph.mY),
          size: CanariSize (width: nph.mWidth, height: nph.mHeight)
        )
        let inner12 : Bool
        let inner34 : Bool
        switch layerConfiguration {
        case .twoLayers :
          inner12 = false
          inner34 = false
        case .fourLayers :
          inner12 = true
          inner34 = false
        case .sixLayers :
          inner12 = true
          inner34 = true
        }
        let rr = RestrictRectangleForDSNExport (
          rect: r,
          rotationInDegrees: Double (nph.mRotation) / 1000.0,
          frontSide: true,
          backSide: true,
          inner1Side: inner12,
          inner2Side: inner12,
          inner3Side: inner34,
          inner4Side: inner34
        )
        restrictRectangles.append (rr)
      }
    }
  //--- Net classes
    var maxTrackWithInDSNUnit : Double = 0.0
    var netClasses = [NetClassForDSNExport] ()
    for netClass in self.rootObject.mNetClasses.values {
      var netNames = [String] ()
      for net in netClass.mNets.values {
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
        allowTracksOnBackSide: netClass.mAllowTracksOnBackSide,
        allowTracksOnInner1Layer: netClass.mAllowTracksOnInner1Layer,
        allowTracksOnInner2Layer: netClass.mAllowTracksOnInner2Layer,
        allowTracksOnInner3Layer: netClass.mAllowTracksOnInner3Layer,
        allowTracksOnInner4Layer: netClass.mAllowTracksOnInner4Layer
      )
      netClasses.append (nc)
    }
  //--- Enumerate components
    var packageDictionary = [PackageDictionaryKeyForDSNExport : Int] ()
    var packageArrayForRouting = [PackageTypeForDSNExport] ()
    var componentArrayForRouting = [ComponentForDSNExport] ()
    var padTypeArrayForRouting = [PadTypeForDSNExport] ()
    for component in self.rootObject.mComponents.values {
      if component.mRoot != nil { // Placed on board
        let device = component.mDevice!
        let packageIndex = indexForPackage (
          device,
          component.mSlavePadsShouldBeRouted,
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
          rotationInDegrees: Double (component.mRotation) / 1000.0,
          side: component.mSide,
          netList: padNetArray.sorted { $0.padString < $1.padString }
        )
        componentArrayForRouting.append (cfr)
      }
    }
  //--- Generate
    var s = ""
    s += "(pcb \"\(self.documentFileName ?? "")\"\n"
    s += "  (parser\n"
    s += "    (string_quote \")\n"
    s += "    (space_in_quoted_tokens on)\n"
    s += "    (host_cad \"ElCanari\")\n"
    s += "    (host_version \"\(ElCanariApplicationVersionString ())\")\n"
    s += "  )\n"
    s += "  (resolution \(converter.unitString) \(converter.resolution))\n"
    s += "  (unit \(converter.unitString))\n"
    s += "  (structure\n"
    addBoardBoundary (&s, signalPolygonVertices)
    autorouteSettings (&s, self.rootObject.mAutoRouterPreferredDirections, layerConfiguration)
    addSnapAngle (&s, self.rootObject.mAutorouterSnapAngle)
    addViaClasses (&s, netClasses)
    let via_at_smd = self.rootObject.mAllowViaAtSMD
    s += "    (control (via_at_smd \(via_at_smd ? "on" : "off")))\n"
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
    addViaPadStackLibrary (&s, netClasses, layerConfiguration)
    addComponentPadStackLibrary (&s, padTypeArrayForRouting, converter, layerConfiguration)
    s += "  )\n"
    s += "  (network\n"
    addNetwork (&s, componentArrayForRouting)
    addViaRules (&s, netClasses)
    addNetClasses (&s, netClasses, layerConfiguration)
    s += "  )\n"
    if inExportTracks {
      self.exportTracksAndVias (&s, converter)
    }
    s += ")\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildSignalPolygon (_ inConverter : CanariUnitToDSNUnitConverter) -> EBLinePath { // Points in DSN Unit
    switch self.rootObject.mBoardShape {
    case .bezierPathes :
      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
      for curve in self.rootObject.mBorderCurves.values {
        let descriptor = curve.descriptor!
        curveDictionary [descriptor.p1] = descriptor
      }
      var clearanceBP = BézierPath ()
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
      return clearanceBP.linePathesByFlattening (withFlatness: 0.1) [0]
    case .rectangular :
      let d = self.rootObject.mBoardClearance + self.rootObject.mBoardLimitsWidth
      let r = CanariRect (
        left: d,
        bottom: d,
        width: self.rootObject.mRectangularBoardWidth - 2 * d,
        height: self.rootObject.mRectangularBoardHeight - 2 * d
      )
      return BézierPath (rect: inConverter.dsnRectFromCanariRect (r)).linePathesByFlattening (withFlatness: 0.1) [0]
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func exportTracksAndVias (_ ioString : inout String,
                                    _ inConverter : CanariUnitToDSNUnitConverter) {
    ioString += "  (wiring\n"
  //--- Export tracks
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        let side : String
        switch track.mSide {
        case .front : side = FRONT_SIDE_LAYOUT
        case .back : side = BACK_SIDE_LAYOUT
        case .inner1 : side = INNER1_LAYOUT
        case .inner2 : side = INNER2_LAYOUT
        case .inner3 : side = INNER3_LAYOUT
        case .inner4 : side = INNER4_LAYOUT
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
    for object in self.rootObject.mBoardObjects.values {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

enum DSNUnit { case millimeter, micrometer, mil}

//--------------------------------------------------------------------------------------------------

struct CanariUnitToDSNUnitConverter {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let unit : DSNUnit

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var unitString : String {
    switch unit {
    case .millimeter :
      return "mm"
    case .micrometer :
      return "um"
    case .mil :
      return "mil"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var resolution : Int {
    switch unit {
    case .millimeter :
      return 10000
    case .mil :
      return 1000
    case .micrometer :
      return 10
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func dsnUnitFromCanariUnit (_ inValue : Int ) -> Double {
    switch unit {
    case .millimeter :
      return Double (inValue) / Double (CANARI_UNITS_PER_MM)
    case .mil :
      return Double (inValue) / Double (CANARI_UNITS_PER_MIL)
    case .micrometer :
      return 1000.0 * Double (inValue) / Double (CANARI_UNITS_PER_MM)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func dsnPointFromCanariPoint (_ inP : CanariPoint) -> NSPoint {
    return NSPoint (x: self.dsnUnitFromCanariUnit (inP.x), y: self.dsnUnitFromCanariUnit (inP.y))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func dsnRectFromCanariRect (_ inP : CanariRect) -> NSRect {
    return NSRect (
      x: self.dsnUnitFromCanariUnit (inP.origin.x),
      y: self.dsnUnitFromCanariUnit (inP.origin.y),
      width: self.dsnUnitFromCanariUnit (inP.size.width),
      height: self.dsnUnitFromCanariUnit (inP.size.height)
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func indexForPackage (_ inDevice : DeviceInProject,
                                             _ inRouteSlavePads : Bool,
                                             _ inSelectedPackage : DevicePackageInProject,
                                             _ ioPackageDictionary : inout [PackageDictionaryKeyForDSNExport : Int],
                                             _ ioPackageArrayForRouting : inout [PackageTypeForDSNExport],
                                             _ ioPadTypeArrayForRouting : inout [PadTypeForDSNExport],
                                             _ inConverter : CanariUnitToDSNUnitConverter) -> Int {
  let key = PackageDictionaryKeyForDSNExport (device: inDevice, routeSlavePads: inRouteSlavePads, package: inSelectedPackage)
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
        onBackSide: masterPad.style == .traversing,
        shape: masterPad.shape,
        &ioPadTypeArrayForRouting
      )
      let psr = PadInstanceForDSNExport (
        name: masterPad.name,
        pad: masterPadForRouting,
        centerX: inConverter.dsnUnitFromCanariUnit (masterPad.center.x - deviceCenter.x),
        centerY: inConverter.dsnUnitFromCanariUnit (masterPad.center.y - deviceCenter.y)
      )
      padArrayForRouting.append (psr)
    //--- Enter slave pads
      for slavePad in masterPad.slavePads {
        let onComponentSide : Bool
        let onBackSide : Bool
        switch slavePad.style {
        case .oppositeSide : onComponentSide = false ; onBackSide = true
        case .componentSide : onComponentSide = true  ; onBackSide = false
        case .traversing : onComponentSide = true  ; onBackSide = true
        }
        let slavePadForRouting = findOrAddPadType (
          canariWidth: slavePad.padSize.width,
          canariHeight: slavePad.padSize.height,
          onComponentSide: onComponentSide,
          onBackSide: onBackSide,
          shape: slavePad.shape,
          &ioPadTypeArrayForRouting
        )
        let pir = PadInstanceForDSNExport (
          name: inRouteSlavePads ? masterPad.name : "nc::\(masterPad.name)",
          pad: slavePadForRouting,
          centerX: inConverter.dsnUnitFromCanariUnit (slavePad.center.x - deviceCenter.x),
          centerY: inConverter.dsnUnitFromCanariUnit (slavePad.center.y - deviceCenter.y)
        )
        padArrayForRouting.append (pir)
      }
    }
  //--- Enter in package array
    let pfr = PackageTypeForDSNExport (
      typeName: inDevice.mDeviceName + ":" + (inRouteSlavePads ? "Y" : "N") + ":" + inSelectedPackage.mPackageName,
      padArray: padArrayForRouting.sorted { $0.name < $1.name }
    )
    ioPackageArrayForRouting.append (pfr)
  //---
    return idx
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate func findOrAddPadType (canariWidth inWidth : Int,
                                   canariHeight inHeight : Int,
                                   onComponentSide inComponentSide : Bool,
                                   onBackSide  inBackSide : Bool,
                                   shape inShape : PadShape,
                                   _ ioPadTypeArrayForRouting : inout [PadTypeForDSNExport]) -> PadTypeForDSNExport {
//--- Search in existing pads
  for mp in ioPadTypeArrayForRouting {
    if ((mp.canariWidth == inWidth) && (mp.canariHeight == inHeight) && (mp.onComponentSide == inComponentSide)  && (mp.onBackSide == inBackSide) && (mp.shape == inShape)) {
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
    onBackSide: inBackSide
  )
  ioPadTypeArrayForRouting.append (newPad)
  return newPad
}

//--------------------------------------------------------------------------------------------------

fileprivate struct PadNetDescriptorForDSNExport {
  let padString : String
  let netName : String?
}

//--------------------------------------------------------------------------------------------------

fileprivate struct PackageDictionaryKeyForDSNExport : Hashable {
  let device : DeviceInProject
  let routeSlavePads : Bool
  let package : DevicePackageInProject

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Equatable Protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func == (lhs : PackageDictionaryKeyForDSNExport, rhs : PackageDictionaryKeyForDSNExport) -> Bool {
    return (lhs.device === rhs.device) && (lhs.routeSlavePads == rhs.routeSlavePads) && (lhs.package === rhs.package)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Hashable Protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   func hash (into hasher: inout Hasher) {
    ObjectIdentifier (self.device).hash (into: &hasher)
    self.routeSlavePads.hash (into: &hasher)
    ObjectIdentifier (self.package).hash (into: &hasher)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate struct NetClassForDSNExport {
  let name : String
  let trackWidthInDSNUnit : Double
  let viaPadDiameterInDSNUnit : Double
  let netNames : [String]
  let allowTracksOnFrontSide : Bool
  let allowTracksOnBackSide : Bool
  let allowTracksOnInner1Layer : Bool
  let allowTracksOnInner2Layer : Bool
  let allowTracksOnInner3Layer : Bool
  let allowTracksOnInner4Layer : Bool
}

//--------------------------------------------------------------------------------------------------

fileprivate struct RestrictRectangleForDSNExport {
  let rect : CanariRect
  let rotationInDegrees : Double
  let frontSide : Bool
  let backSide  : Bool
  let inner1Side  : Bool
  let inner2Side  : Bool
  let inner3Side  : Bool
  let inner4Side  : Bool

  func vertexString (_ inConverter : CanariUnitToDSNUnitConverter) -> String {
    var af = AffineTransform ()
    let centerX = canariUnitToCocoa (self.rect.center.x)
    let centerY = canariUnitToCocoa (self.rect.center.y)
    af.translate (x: centerX, y: centerY)
    af.rotate (byDegrees: self.rotationInDegrees)
    let halfWidth  = canariUnitToCocoa (self.rect.width) / 2.0
    let halfHeight = canariUnitToCocoa (self.rect.height) / 2.0
    let bottomLeft  = af.transform (NSPoint (x: -halfWidth, y: -halfHeight)).canariPoint
    let bottomRight = af.transform (NSPoint (x: +halfWidth, y: -halfHeight)).canariPoint
    let topRight    = af.transform (NSPoint (x: +halfWidth, y: +halfHeight)).canariPoint
    let topLeft     = af.transform (NSPoint (x: -halfWidth, y: +halfHeight)).canariPoint
    let bottomLeftStr  = "\(inConverter.dsnUnitFromCanariUnit (bottomLeft.x)) \(inConverter.dsnUnitFromCanariUnit (bottomLeft.y))"
    let bottomRightStr = "\(inConverter.dsnUnitFromCanariUnit (bottomRight.x)) \(inConverter.dsnUnitFromCanariUnit (bottomRight.y))"
    let topRightStr    = "\(inConverter.dsnUnitFromCanariUnit (topRight.x)) \(inConverter.dsnUnitFromCanariUnit (topRight.y))"
    let topLeftStr     = "\(inConverter.dsnUnitFromCanariUnit (topLeft.x)) \(inConverter.dsnUnitFromCanariUnit (topLeft.y))"
    return " \(bottomLeftStr) \(bottomRightStr) \(topRightStr) \(topLeftStr) \(bottomLeftStr)"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate struct ComponentForDSNExport {
  let packageIndex : Int
  let componentName : String
  let placed : Bool
  let originX : Int
  let originY : Int
  let rotationInDegrees : Double
  let side : ComponentSide
  let netList : [PadNetDescriptorForDSNExport]
}

//--------------------------------------------------------------------------------------------------

fileprivate struct PackageTypeForDSNExport {
  let typeName : String
  let padArray : [PadInstanceForDSNExport]
}

//--------------------------------------------------------------------------------------------------

fileprivate struct PadInstanceForDSNExport {
  let name : String
  let pad : PadTypeForDSNExport
  let centerX : Double // In DSN Unit
  let centerY : Double // In DSN Unit
}

//--------------------------------------------------------------------------------------------------

fileprivate struct PadTypeForDSNExport {
  let name : String
  let canariWidth  : Int
  let canariHeight : Int
  let shape : PadShape
  let onComponentSide : Bool
  let onBackSide  : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate func addNetwork (_ ioString : inout String,
                             _ inComponentArrayForRouting : [ComponentForDSNExport]) {
  var netWorkDictionary = [String : [String]] ()
  for component in inComponentArrayForRouting {
    let componentName = component.componentName
    for padDescriptor in component.netList {
      if let netName = padDescriptor.netName {
        netWorkDictionary [netName] = netWorkDictionary [netName, default: []] + ["\"" + componentName + "\"-\"" + padDescriptor.padString + "\""]
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

//--------------------------------------------------------------------------------------------------

fileprivate func addViaPadStackLibrary (_ ioString : inout String,
                                        _ inNetClasses : [NetClassForDSNExport],
                                        _ inLayerConfiguration : LayerConfiguration) {
  for netClass in inNetClasses {
    ioString += "    (padstack \"viaForClass\(netClass.name)\"\n"
    switch inLayerConfiguration {
    case .twoLayers :
      ioString += "      (shape (circle \(FRONT_SIDE_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(BACK_SIDE_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
    case .fourLayers :
      ioString += "      (shape (circle \(FRONT_SIDE_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(INNER1_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(INNER2_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(BACK_SIDE_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
    case .sixLayers :
      ioString += "      (shape (circle \(FRONT_SIDE_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(INNER1_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(INNER2_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(INNER3_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(INNER4_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
      ioString += "      (shape (circle \(BACK_SIDE_LAYOUT) \(netClass.viaPadDiameterInDSNUnit)))\n"
    }
    ioString += "    )\n"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate func addComponentPadStackLibrary (_ ioString : inout String,
                                              _ inPadTypeArrayForRouting : [PadTypeForDSNExport],
                                              _ inConverter : CanariUnitToDSNUnitConverter,
                                              _ inLayerConfiguration : LayerConfiguration) {
  for pad in inPadTypeArrayForRouting {
    ioString += "    (padstack \"\(pad.name)\"\n"
    if pad.onBackSide {
      ioString += "      (shape \(pad.padStringFor (side: BACK_SIDE_LAYOUT, inConverter)))\n"
    }
    if pad.onComponentSide {
      ioString += "      (shape \(pad.padStringFor (side: FRONT_SIDE_LAYOUT, inConverter)))\n"
    }
    if pad.onComponentSide && pad.onBackSide && (inLayerConfiguration == .fourLayers) {
      ioString += "      (shape \(pad.padStringFor (side: INNER1_LAYOUT, inConverter)))\n"
      ioString += "      (shape \(pad.padStringFor (side: INNER2_LAYOUT, inConverter)))\n"
    }
    if pad.onComponentSide && pad.onBackSide && (inLayerConfiguration == .sixLayers) {
      ioString += "      (shape \(pad.padStringFor (side: INNER1_LAYOUT, inConverter)))\n"
      ioString += "      (shape \(pad.padStringFor (side: INNER2_LAYOUT, inConverter)))\n"
      ioString += "      (shape \(pad.padStringFor (side: INNER3_LAYOUT, inConverter)))\n"
      ioString += "      (shape \(pad.padStringFor (side: INNER4_LAYOUT, inConverter)))\n"
    }
    ioString += "    )\n"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate func addDeviceLibrary (_ ioString : inout String,
                                   _ inPackageArrayForRouting : [PackageTypeForDSNExport]) {
  for package in inPackageArrayForRouting {
    ioString += "    (image \"\(package.typeName)\"\n"
    for padType in package.padArray {
      ioString += "      (pin \"\(padType.pad.name)\" \"\(padType.name)\" \(padType.centerX) \(padType.centerY))\n"
    }
    ioString += "    )\n"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate func addBoardBoundary (_ ioString : inout String,
//                                   _ inBoardBoundBox : CanariRect,
                                   _ inSignalPolygonVertices : EBLinePath) { // In DSN Unit
//                                   _ inConverter : CanariUnitToDSNUnitConverter) {

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

//--------------------------------------------------------------------------------------------------

fileprivate func addSnapAngle (_ ioString : inout String, _ inSnapAngle : AutorouterSnapAngle) {
  ioString += "    (snap_angle "
  switch inSnapAngle {
  case .rectilinear :
    ioString += "ninety_degree"
  case .octolinear :
    ioString += "fortyfive_degree"
  case .anyAngle :
    ioString += "none"
  }
  ioString += ")\n"
}

//--------------------------------------------------------------------------------------------------

fileprivate func autorouteSettings (_ ioString : inout String,
                                    _ inRouterPreferredDirection : AutorouterPreferredDirections,
                                    _ inLayerConfiguration : LayerConfiguration) {
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
  ioString += "    (layer \(BACK_SIDE_LAYOUT) (type signal))\n"
  ioString += "    (layer \(FRONT_SIDE_LAYOUT) (type signal))\n"
  switch inLayerConfiguration {
  case .twoLayers :
    ()
  case .fourLayers :
    ioString += "    (layer \(INNER1_LAYOUT) (type signal))\n"
    ioString += "    (layer \(INNER2_LAYOUT) (type signal))\n"
  case .sixLayers :
    ioString += "    (layer \(INNER1_LAYOUT) (type signal))\n"
    ioString += "    (layer \(INNER2_LAYOUT) (type signal))\n"
    ioString += "    (layer \(INNER3_LAYOUT) (type signal))\n"
    ioString += "    (layer \(INNER4_LAYOUT) (type signal))\n"
  }
  ioString += "    (autoroute_settings\n"
  ioString += "      (vias on)\n"
  ioString += "      (via_costs 50)\n"
  ioString += "      (plane_via_costs 5)\n"
  ioString += "      (start_ripup_costs 100)\n"
  ioString += "      (start_pass_no 1)\n"
  ioString += "      (layer_rule \(BACK_SIDE_LAYOUT)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction \(backPreferredDir))\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
  ioString += "      )\n"
  ioString += "      (layer_rule \(FRONT_SIDE_LAYOUT)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction \(frontPreferredDir))\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
  ioString += "      )\n"
  if (inLayerConfiguration == .fourLayers) || (inLayerConfiguration == .sixLayers) {
    ioString += "      (layer_rule \(INNER1_LAYOUT)\n"
    ioString += "        (active on)\n"
    ioString += "        (prefered_direction \(frontPreferredDir))\n"
    ioString += "        (prefered_direction_trace_costs 1.0)\n"
    ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
    ioString += "      )\n"
    ioString += "      (layer_rule \(INNER2_LAYOUT)\n"
    ioString += "        (active on)\n"
    ioString += "        (prefered_direction \(backPreferredDir))\n"
    ioString += "        (prefered_direction_trace_costs 1.0)\n"
    ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
    ioString += "      )\n"
  }
  if inLayerConfiguration == .sixLayers {
    ioString += "      (layer_rule \(INNER3_LAYOUT)\n"
    ioString += "        (active on)\n"
    ioString += "        (prefered_direction \(frontPreferredDir))\n"
    ioString += "        (prefered_direction_trace_costs 1.0)\n"
    ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
    ioString += "      )\n"
    ioString += "      (layer_rule \(INNER4_LAYOUT)\n"
    ioString += "        (active on)\n"
    ioString += "        (prefered_direction \(backPreferredDir))\n"
    ioString += "        (prefered_direction_trace_costs 1.0)\n"
    ioString += "        (against_prefered_direction_trace_costs 2.5)\n"
    ioString += "      )\n"
  }
  ioString += "    )\n"
}

//--------------------------------------------------------------------------------------------------

fileprivate func addViaClasses (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  ioString += "    (via"
  for netClass in inNetClasses {
    ioString += " \"viaForClass\(netClass.name)\""
  }
  ioString += ")\n"
}

//--------------------------------------------------------------------------------------------------

fileprivate func addViaRules (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (via_rule\n"
    ioString += "      \"viaRuleForClass\(netClass.name)\" \"viaForClass\(netClass.name)\"\n"
    ioString += "    )\n"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate func addNetClasses (_ ioString : inout String,
                                _ inNetClasses : [NetClassForDSNExport],
                                _ inLayerConfiguration : LayerConfiguration) {
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
    if netClass.allowTracksOnBackSide {
      ioString += " \(BACK_SIDE_LAYOUT)"
    }
    if netClass.allowTracksOnFrontSide {
      ioString += " \(FRONT_SIDE_LAYOUT)"
    }
    if netClass.allowTracksOnInner1Layer && (inLayerConfiguration != .twoLayers) {
      ioString += " \(INNER1_LAYOUT)"
    }
    if netClass.allowTracksOnInner2Layer && (inLayerConfiguration != .twoLayers) {
      ioString += " \(INNER2_LAYOUT)"
    }
    if netClass.allowTracksOnInner3Layer && (inLayerConfiguration == .sixLayers) {
      ioString += " \(INNER3_LAYOUT)"
    }
    if netClass.allowTracksOnInner4Layer && (inLayerConfiguration == .sixLayers) {
      ioString += " \(INNER4_LAYOUT)"
    }
    ioString += ")\n"
    ioString += "      )\n"
    ioString += "    )\n"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate func addDefaultRule (_ ioString : inout String,
                                 maxWidthInDSNUnit inTrackMaxWidth : Double,
                                 clearanceInDSNUnit inClearance : Double) {
  ioString += "    (rule\n"
  ioString += "      (width \(inTrackMaxWidth))\n" // Required !!!!
  ioString += "      (clearance \(inClearance))\n"
  ioString += "    )\n"
}

//--------------------------------------------------------------------------------------------------

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

//--------------------------------------------------------------------------------------------------

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
    ioString += "      (place \"\(component.componentName)\" \(x) \(y) \(side) \(component.rotationInDegrees)\n"
    for padDescriptor in component.netList {
      ioString += "        (pin \"\(padDescriptor.padString)\" (clearance_class default))\n"
    }
    ioString += "      )\n"
    ioString += "    )\n"
  }
  ioString += "  )\n"
}

//--------------------------------------------------------------------------------------------------

fileprivate func addRestrictRectangles (_ ioString : inout String,
                                        _ inRestrictRectangles : [RestrictRectangleForDSNExport],
                                        _ inConverter : CanariUnitToDSNUnitConverter) {
  for rr in inRestrictRectangles {
    if rr.frontSide {
      ioString += "    (keepout\n"
      ioString += "      (polygon \(FRONT_SIDE_LAYOUT) 0\(rr.vertexString (inConverter)))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.backSide {
      ioString += "    (keepout\n"
      ioString += "      (polygon \(BACK_SIDE_LAYOUT) 0\(rr.vertexString (inConverter)))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.inner1Side {
      ioString += "    (keepout\n"
      ioString += "      (polygon \(INNER1_LAYOUT) 0\(rr.vertexString (inConverter))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.inner2Side {
      ioString += "    (keepout\n"
      ioString += "      (polygon \(INNER2_LAYOUT) 0\(rr.vertexString (inConverter)))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.inner3Side {
      ioString += "    (keepout\n"
      ioString += "      (polygon \(INNER3_LAYOUT) 0\(rr.vertexString (inConverter)))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.inner4Side {
      ioString += "    (keepout\n"
      ioString += "      (polygon \(INNER4_LAYOUT) 0\(rr.vertexString (inConverter)))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
  }
}

//--------------------------------------------------------------------------------------------------
