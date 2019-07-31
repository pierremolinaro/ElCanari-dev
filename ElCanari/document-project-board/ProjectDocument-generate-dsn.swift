//
//  ProjectDocument-generate-dsn.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let COMPONENT_SIDE = "ComponentSide"
let SOLDER_SIDE    = "SolderSide"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction internal func performGenerateDSNFileAction (_ inUnusedSender : Any?) {
    let s = self.dsnContents ()
    let savePanel = NSSavePanel ()
    savePanel.allowedFileTypes = ["dsn"]
    savePanel.allowsOtherFileTypes = false
    savePanel.nameFieldStringValue = "design.dsn"
    savePanel.beginSheetModal (for: self.windowForSheet!) { inResponse in
      if inResponse == .OK, let url = savePanel.url {
        try? s.write (to: url, atomically: true, encoding: .ascii)
      }
    }
  }

  //····················································································································

  private func dsnContents () -> String {
  //--- Border
    let boardLimitExtend = -self.rootObject.mBoardLimitsWidth / 2
    let boardBoundBox = self.rootObject.interiorBoundBox!.insetBy (dx: boardLimitExtend, dy: boardLimitExtend)
    let signalPolygonVertices = self.buildSignalPolygon ()
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
    var netClasses = [NetClassForDSNExport] ()
    for netClass in self.rootObject.mNetClasses {
      var netNames = [String] ()
      for net in netClass.mNets {
        netNames.append (net.mNetName)
      }
      let nc = NetClassForDSNExport (
        name: netClass.mNetClassName,
        trackWidthInMM: canariUnitToMillimeter (netClass.mTrackWidth),
        viaPadDiameterInMM: canariUnitToMillimeter (netClass.mViaPadDiameter),
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
          &padTypeArrayForRouting
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
          rotation: CGFloat (component.mRotation) / 1000.0,
          side: component.mSide,
          netList: padNetArray.sorted { $0.padString < $1.padString }
        )
        componentArrayForRouting.append (cfr)
      }
    }
    let clearanceInMM = canariUnitToMillimeter (self.rootObject.mLayoutClearance)
  //--- Generate
    var s = ""
    s += "(pcb routing_problem\n"
    s += "  (parser\n"
    s += "    (string_quote \")\n"
    s += "    (space_in_quoted_tokens on)\n"
    s += "  )\n"
    s += "  (resolution mm 300)\n"
    s += "  (structure\n"
    addBoardBoundary (&s, boardBoundBox, signalPolygonVertices)
    addSnapAngle (&s, self.rootObject.mAutorouterSnapAngle)
    addViaClasses (&s, netClasses)
    s += "    (control (via_at_smd off))\n"
    addRuleClearance (&s, clearanceInMM: clearanceInMM)
    autorouteSettings (&s, self.rootObject.mAutoRouterPreferredDirections)
    addRestrictRectangles (&s, restrictRectangles)
    s += "  )\n"
    addComponentsPlacement (&s, componentArrayForRouting, packageArrayForRouting)
    s += "  (library\n"
    addDeviceLibrary (&s, packageArrayForRouting)
    addViaPadStackLibrary (&s, netClasses)
    addComponentPadStackLibrary (&s, padTypeArrayForRouting)
    s += "  )\n"
    s += "  (network\n"
    addNetwork (&s, componentArrayForRouting)
    addViaRules (&s, netClasses)
    addNetClasses (&s, netClasses)
    s += "  )\n"
    s += ")\n"
    return s
  }

  //····················································································································

  private func buildSignalPolygon () -> LinePath { // Points in millimeters
    var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
    for curve in self.rootObject.mBorderCurves {
      let descriptor = curve.descriptor!
      curveDictionary [descriptor.p1] = descriptor
    }
    var clearanceBP = EBBezierPath ()
    var descriptor = self.rootObject.mBorderCurves [0].descriptor!
    let p = descriptor.p1
    clearanceBP.move (to: p.millimeterPoint)
    var loop = true
    while loop {
      switch descriptor.shape {
      case .line :
        clearanceBP.line (to: descriptor.p2.millimeterPoint)
      case .bezier :
        let cp1 = descriptor.cp1.millimeterPoint
        let cp2 = descriptor.cp2.millimeterPoint
        clearanceBP.curve (to: descriptor.p2.millimeterPoint, controlPoint1: cp1, controlPoint2: cp2)
      }
      descriptor = curveDictionary [descriptor.p2]!
      loop = p != descriptor.p1
    }
    return clearanceBP.pointsByFlattening (withFlatness: 0.1) [0]
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func indexForPackage (_ inDevice : DeviceInProject,
                                  _ inSelectedPackage : DevicePackageInProject,
                                  _ ioPackageDictionary : inout [PackageDictionaryKeyForDSNExport : Int],
                                  _ ioPackageArrayForRouting : inout [PackageTypeForDSNExport],
                                  _ ioPadTypeArrayForRouting : inout [PadTypeForDSNExport]) -> Int {
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
        centerXmm: canariUnitToMillimeter (masterPad.center.x - deviceCenter.x),
        centerYmm: canariUnitToMillimeter (masterPad.center.y - deviceCenter.y)
      )
      padArrayForRouting.append (psr)
    //--- Enter slave pads
      for slavePad in masterPad.slavePads {
        let onComponentSide : Bool
        let onOppositeSide : Bool
        switch slavePad.style {
        case .bottomSide : onComponentSide = false ; onOppositeSide = true
        case .topSide    : onComponentSide = true  ; onOppositeSide = false
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
          centerXmm: canariUnitToMillimeter (slavePad.center.x - deviceCenter.x),
          centerYmm: canariUnitToMillimeter (slavePad.center.y - deviceCenter.y)
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PadNetDescriptorForDSNExport {
  let padString : String
  let netName : String?
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PackageDictionaryKeyForDSNExport : Hashable {
  let device : DeviceInProject
  let package : DevicePackageInProject
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct NetClassForDSNExport {
  let name : String
  let trackWidthInMM : CGFloat
  let viaPadDiameterInMM : CGFloat
  let netNames : [String]
  let allowTracksOnFrontSide : Bool
  let allowTracksOnBackSide : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct RestrictRectangleForDSNExport {
  let rect : CanariRect
  let frontSide : Bool
  let backSide  : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct ComponentForDSNExport {
  let packageIndex : Int
  let componentName : String
  let placed : Bool
  let originX : Int
  let originY : Int
  let rotation : CGFloat
  let side : ComponentSide
  let netList : [PadNetDescriptorForDSNExport]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PackageTypeForDSNExport {
  let typeName : String
  let padArray : [PadInstanceForDSNExport]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PadInstanceForDSNExport {
  let name : String
  let masterPad : PadTypeForDSNExport
  let centerXmm : CGFloat // In mm
  let centerYmm : CGFloat // In mm
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PadTypeForDSNExport {
  let name : String
  let canariWidth  : Int
  let canariHeight : Int
  let shape : PadShape
  let onComponentSide : Bool
  let onOppositeSide  : Bool

  //····················································································································

  func padStringFor (side inSide : String) -> String {
    let halfWidth = canariUnitToMillimeter (self.canariWidth) / 2.0
    let halfHeight = canariUnitToMillimeter (self.canariHeight) / 2.0
    let shapeString : String
    switch self.shape {
    case .rect :
      shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
    case .round :
      if halfWidth == halfHeight { // Circular pad
        shapeString = "(circle \(inSide) \(halfWidth * 2.0) 0 0)"
      }else{ // Oblong: generate an octogon
        //shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
        let s2 : CGFloat = sqrt (2.0)
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
      let s2 : CGFloat = sqrt (2.0)
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addViaPadStackLibrary (_ ioString : inout String,
                                        _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (padstack \"viaForClass\(netClass.name)\"\n"
    ioString += "      (shape (circle \(SOLDER_SIDE) \(netClass.viaPadDiameterInMM) 0 0))\n"
    ioString += "      (shape (circle \(COMPONENT_SIDE) \(netClass.viaPadDiameterInMM) 0 0))\n"
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addComponentPadStackLibrary (_ ioString : inout String,
                                              _ inPadTypeArrayForRouting : [PadTypeForDSNExport]) {
  for pad in inPadTypeArrayForRouting {
    ioString += "    (padstack \"\(pad.name)\"\n"
    if pad.onComponentSide {
      ioString += "      (shape \(pad.padStringFor (side: COMPONENT_SIDE)))\n"
    }
    if pad.onOppositeSide {
      ioString += "      (shape \(pad.padStringFor (side: SOLDER_SIDE)))\n"
    }
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addDeviceLibrary (_ ioString : inout String,
                                   _ inPackageArrayForRouting : [PackageTypeForDSNExport]) {
  for package in inPackageArrayForRouting {
    ioString += "    (image \"\(package.typeName)\"\n"
    for pad in package.padArray {
      ioString += "      (pin \(pad.masterPad.name) \(pad.name) \(pad.centerXmm) \(pad.centerYmm))\n"
    }
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addBoardBoundary (_ ioString : inout String,
                                   _ inBoardBoundBox : CanariRect,
                                   _ inSignalPolygonVertices : LinePath) { // In millimeters
  let bbLeft = canariUnitToMillimeter (inBoardBoundBox.origin.x)
  let bbBottom = canariUnitToMillimeter (inBoardBoundBox.origin.y)
  let bbRight = bbLeft + canariUnitToMillimeter (inBoardBoundBox.size.width)
  let bbTop = bbBottom + canariUnitToMillimeter (inBoardBoundBox.size.height)
  ioString += "    (boundary\n"
  ioString += "      (rect pcb \(bbLeft) \(bbBottom) \(bbRight) \(bbTop))\n"
  ioString += "    )\n"
  ioString += "    (boundary\n"
  ioString += "      (polygon signal 0\n"
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
  ioString += "        (against_prefered_direction_trace_costs 2.7)\n"
  ioString += "      )\n"
  ioString += "      (layer_rule \(SOLDER_SIDE)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction \(backPreferredDir))\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.7)\n"
  ioString += "      )\n"
  ioString += "    )\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addViaClasses (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  ioString += "    (via"
  for netClass in inNetClasses {
    ioString += " \"viaForClass\(netClass.name)\""
  }
  ioString += ")\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addViaRules (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (via_rule\n"
    ioString += "      \"viaRuleForClass\(netClass.name)\" \"viaForClass\(netClass.name)\"\n"
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addNetClasses (_ ioString : inout String, _ inNetClasses : [NetClassForDSNExport]) {
  for netClass in inNetClasses {
    ioString += "    (class \"class_\(netClass.name)\"\n"
    for netName in netClass.netNames {
      ioString += "      \"\(netName)\"\n"
    }
    ioString += "      (clearance_class default)\n"
    ioString += "      (via_rule \"viaRuleForClass\(netClass.name)\")\n"
    ioString += "      (rule\n"
    ioString += "        (width \(netClass.trackWidthInMM))\n"
    ioString += "      )\n"
    ioString += "      (circuit\n"
//    ioString += "        (use_layer \(COMPONENT_SIDE) \(SOLDER_SIDE))\n"
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addRuleClearance (_ ioString : inout String, clearanceInMM inClearance : CGFloat) {
  ioString += "    (rule (clearance \(inClearance)))\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addComponentsPlacement (_ ioString : inout String,
                                         _ inComponents : [ComponentForDSNExport],
                                         _ inPackageArrayForRouting : [PackageTypeForDSNExport]) {
  ioString += "  (placement\n"
  for component in inComponents {
    let x = canariUnitToMillimeter (component.originX)
    let y = canariUnitToMillimeter (component.originY)
    let side : String
    switch component.side {
    case .back : side = "back"
    case .front : side = "front"
    }
    ioString += "    (component \"\(inPackageArrayForRouting [component.packageIndex].typeName)\"\n"
    ioString += "      (place\n"
    ioString += "        \"\(component.componentName)\" \(x) \(y) \(side) \(component.rotation)\n"
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addRestrictRectangles (_ ioString : inout String,
                                        _ inRestrictRectangles : [RestrictRectangleForDSNExport]) {
  for rr in inRestrictRectangles {
    let left = canariUnitToMillimeter (rr.rect.left)
    let bottom = canariUnitToMillimeter (rr.rect.bottom)
    let right = left + canariUnitToMillimeter (rr.rect.width)
    let top = bottom + canariUnitToMillimeter (rr.rect.height)
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
