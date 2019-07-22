//
//  ProjectDocument-generate-dsn.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let FRONT_SIDE = "ComponentSide"
fileprivate let BACK_SIDE  = "SolderSide"

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
  //--- Restrict rectangles
    var restrictRectangles = [RestrictRectangleForRouting] ()
    for object in self.rootObject.mBoardObjects {
      if let restrictRectangle = object as? BoardRestrictRectangle {
        let r = CanariRect (left: restrictRectangle.mX, bottom: restrictRectangle.mY, width: restrictRectangle.mWidth, height: restrictRectangle.mHeight)
        let rr = RestrictRectangleForRouting (
          rect: r,
          frontSide: restrictRectangle.mIsInFrontLayer,
          backSide: restrictRectangle.mIsInBackLayer
        )
        restrictRectangles.append (rr)
      }
    }
  //--- Net classes
    var netClasses = [NetClassForRouting] ()
    for netClass in self.rootObject.mNetClasses {
      var netNames = [String] ()
      for net in netClass.mNets {
        netNames.append (net.mNetName)
      }
      let nc = NetClassForRouting (
        name: netClass.mNetClassName,
        trackWidthInMM: canariUnitToMillimeter (netClass.mTrackWidth),
        viaPadDiameterInMM: canariUnitToMillimeter (netClass.mViaPadDiameter),
        netNames: netNames
      )
      netClasses.append (nc)
    }
  //--- Enumerate components
    var packageDictionary = [DevicePackageInProject : Int] ()
    var packageArrayForRouting = [PackageTypeForRouting] ()
    var componentArrayForRouting = [ComponentForRouting] ()
    var deviceDictionary = [DeviceDictionaryKey : Int] ()
    var deviceArrayForRouting = [DeviceForRouting] ()
    var padTypeArrayForRouting = [MasterPadForRouting] ()
    for component in self.rootObject.mComponents {
      let device = component.mDevice!
      let deviceIndex = indexForDevice (
        device,
        component.mSelectedPackage!,
        &deviceDictionary,
        &deviceArrayForRouting,
        &packageDictionary,
        &packageArrayForRouting,
        &padTypeArrayForRouting
      )
    //--- Build net list
      var padNetArray = [PadNetDescriptor] ()
      let componentPadDictionary : ComponentPadDescriptorDictionary = component.componentPadDictionary!
      let componentPads : [ComponentPadDescriptor] = Array (componentPadDictionary.values)
      let padNetDictionary : PadNetDictionary = component.padNetDictionary!
      for pad in componentPads {
        let pnd = PadNetDescriptor (padString: pad.padName, netName: padNetDictionary [pad.padName])
        padNetArray.append (pnd)
      }
//   for symbol in component.mSymbols {
//     for pin in symbol.mPoints {
//       let pnd = PadNetDescriptor (padString: "", net: pin.mNet)
//       padNetArray.append (pnd)
//     }
//
//   }
//    NSMutableArray * pinArray = [NSMutableArray new] ;
//    NSArray * sortedSymbolArray = [component.symbols.allObjects sortedArrayUsingSelector:@selector(compareByIdentifier:)] ;
//    for (PMClassForSymbolInProjectEntity * sis in sortedSymbolArray) {
//      macroCheckObject (sis, PMClassForSymbolInProjectEntity) ;
//      NSArray * pins = [sis.pins.allObjects sortedArrayUsingSelector:@selector(compareByIdentifier:)] ;
//      for (PMClassForPinInProjectPadInBoardEntity * pin in pins) {
//        macroCheckObject (pin, PMClassForPinInProjectPadInBoardEntity) ;
//        PMPadNetDescriptor * descriptor = [[PMPadNetDescriptor alloc]
//          initWithPadString:[pin padString]
//          net:[pin net]
//        ] ;
//        [pinArray addObject:descriptor] ;
//      }
//    }
//  //--- Add not connected pads
//    for (PMClassForPadRepresentantInProjectEntity * ppa in device.pads) {
//      macroCheckObject (ppa, PMClassForPadRepresentantInProjectEntity) ;
//      if (nil == ppa.pin) {
//        PMPadNetDescriptor * descriptor = [[PMPadNetDescriptor alloc]
//          initWithPadString:ppa.padQualifiedName
//          net:nil
//        ] ;
//        [pinArray addObject:descriptor] ;
//      }
//    }
//  //---
//    NSArray * sortedPinArray = [pinArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:
//      [[NSSortDescriptor alloc] initWithKey:@"padString" ascending:YES] HERE
//    ]] ;
//    for (PMPadNetDescriptor * pip in sortedPinArray) {
//      macroCheckObject (pip, PMPadNetDescriptor) ;
//      PMClassForNetEntity * net = pip.net ;
//      if (net == nil) { // Not connected
//        [componentNetListArrayForRouting addObject:[NSNumber numberWithInteger:-1] HERE] ;
//      }else{
//        NSNumber * v = [netDictionary objectForKey:[NSValue valueWithNonretainedObject:net]] ;
//        if (nil == v) {
//          [componentNetListArrayForRouting addObject:[NSNumber numberWithInteger:-1] HERE] ;
//        }else{
//          [componentNetListArrayForRouting addObject:v HERE] ;
//        }
//      }
//    }
    //--- Enter component
      let cfr = ComponentForRouting (
        deviceIndex: deviceIndex,
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
    addBoardBoundary (&s)
    addSnapAngle (&s)
    addViaClasses (&s, netClasses)
    s += "    (control (via_at_smd off))\n"
    addRuleClearance (&s, clearanceInMM: clearanceInMM)
    autorouteSettings (&s)
    addRestrictRectangles (&s, restrictRectangles)
    s += "  )\n"
    addComponentsPlacement (&s, componentArrayForRouting, deviceArrayForRouting)
    s += "  (library\n"
    addDeviceLibrary (&s, deviceArrayForRouting, packageArrayForRouting)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func indexForDevice (_ inDevice : DeviceInProject,
                                 _ inSelectedPackage : DevicePackageInProject,
                                 _ ioDeviceDictionary : inout [DeviceDictionaryKey : Int],
                                 _ ioDeviceArrayForRouting : inout [DeviceForRouting],
                                 _ ioPackageDictionary : inout [DevicePackageInProject : Int],
                                 _ ioPackageArrayForRouting : inout [PackageTypeForRouting],
                                 _ ioPadTypeArrayForRouting : inout [MasterPadForRouting]) -> Int {
  let key = DeviceDictionaryKey (device: inDevice, package: inSelectedPackage)
  if let idx = ioDeviceDictionary [key] {
    return idx
  }else{
    let idx = ioDeviceArrayForRouting.count
    ioDeviceDictionary [key] = idx
    let packageIndex = indexForPackage (
      inSelectedPackage,
      &ioPackageDictionary,
      &ioPackageArrayForRouting,
      &ioPadTypeArrayForRouting
    )
    let d = DeviceForRouting (name: inDevice.mDeviceName, packageIndex: packageIndex)
    ioDeviceArrayForRouting.append (d)
    return idx
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func indexForPackage (_ inPackageType : DevicePackageInProject,
                                  _ ioPackageDictionary : inout [DevicePackageInProject : Int],
                                  _ ioPackageArrayForRouting : inout [PackageTypeForRouting],
                                  _ ioPadTypeArrayForRouting : inout [MasterPadForRouting]
                                   ) -> Int {
  let key = inPackageType
  if let idx = ioPackageDictionary [key] {
    return idx
  }else{
  //--- Enter device index in device dictionary
    let idx = ioPackageArrayForRouting.count
    ioPackageDictionary [key] = idx
  //--- Pad array
    let padDictionary = inPackageType.packagePadDictionary!
    let componentCenter = padDictionary.padsRect.center
    var padArrayForRouting = [PadStackForRouting] ()
    for (_, masterPad) in padDictionary {
    //--- Enter master pad
      let masterPadForRouting = findOrAddMasterPad (
        canariWidth: masterPad.padSize.width,
        canariHeight: masterPad.padSize.height,
        style: masterPad.style,
        shape: masterPad.shape,
        &ioPadTypeArrayForRouting
      )
      let psr = PadStackForRouting (
        name: masterPad.name,
        masterPad: masterPadForRouting,
        centerXmm: canariUnitToMillimeter (masterPad.center.x - componentCenter.x),
        centerYmm: canariUnitToMillimeter (masterPad.center.y - componentCenter.y),
    //    slavePadStack: slavePadStack,
        netIndex: nil
      )
      padArrayForRouting.append (psr)
    }
  //--- Enter in package array
    let pfr = PackageTypeForRouting (
      typeName: inPackageType.mPackageName,
      padArray: padArrayForRouting.sorted { $0.name < $1.name }
    )
    ioPackageArrayForRouting.append (pfr)
  //---
    return idx
  }
//  NSValue * key = [NSValue valueWithNonretainedObject:inPackageType] ;
//  NSNumber * idx = [ioPackageDictionary objectForKey:key] ;
//  if (idx == nil) {
//  //--- Enter device index in device dictionary
//    idx = [NSNumber numberWithUnsignedInteger:[ioPackageArrayForRouting count]] ;
//    [ioPackageDictionary setObject:idx forKey:key HERE] ;
//  //--- pad array
//    NSMutableArray * padArrayForRouting = [NSMutableArray arrayWithCapacity:0] ;
//    NSArray * padArray = inPackageType.pads.allObjects ;
//    NSArray * sortedPadArray = [padArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:
//      [[NSSortDescriptor alloc] initWithKey:@"padQualifiedName" ascending:YES] HERE
//    ]] ;
//    const EBPoint offset = [[sortedPadArray objectAtIndex:0 HERE OFCLASS (PMClassForMasterPadInProjectEntity)] padCenter] ;
//  //--- Enter slave pads
//    for (PMClassForMasterPadInProjectEntity * pad in sortedPadArray) {
//      macroCheckObject (pad, PMClassForMasterPadInProjectEntity) ;
//      NSMutableArray * slavePadStack = [NSMutableArray new] ;
//    //--- Enter slave pads
//      for (PMClassForSlavePadInProjectEntity * sp in pad.slavePads) {
//        macroCheckObject (sp, PMClassForSlavePadInProjectEntity) ;
//        const EBPoint center = {
//          sp.padCenter.x - offset.x,
//          sp.padCenter.y - offset.y
//        } ;
//        const NSInteger slavePadSide = [sp side] ;
//        // NSLog (@"slavePadSide %d", slavePadSide) ;
//        if ((slavePadSide == 0) || (slavePadSide == 1)) {
//          PMPadElementForRouting * pt = [[PMPadElementForRouting alloc]
//            initWithX:center.x
//            y:center.y
//            width:sp.padSize.width
//            height:sp.padSize.height
//            holeDiameter:sp.holeDiameter
//            shape:sp.padShape
//            onComponentSide:YES
//          ] ;
//          [slavePadStack addObject:pt] ;
//        }
//        if ((slavePadSide == 0) || (slavePadSide == 2)) {
//          PMPadElementForRouting * pt = [[PMPadElementForRouting alloc]
//            initWithX:center.x
//            y:center.y
//            width:sp.padSize.width
//            height:sp.padSize.height
//            holeDiameter:sp.holeDiameter
//            shape:sp.padShape
//            onComponentSide:NO
//          ] ;
//          [slavePadStack addObject:pt] ;
//        }
//      }
//    //--- Enter master pad
//      const EBPoint center = {pad.padCenter.x - offset.x, pad.padCenter.y - offset.y} ;
//      PMMasterPadForRouting * masterPad = findOrAddMasterPad (pad.padSize.width,
//                                                              pad.padSize.height,
//                                                              pad.side,
//                                                              pad.padShape,
//                                                              ioPadTypeArrayForRouting) ;
//      PMPadStackForRouting * pfr = [[PMPadStackForRouting alloc]
//        initWithName:[pad padQualifiedName]
//        masterPad:masterPad
//        masterPadCenter:center
//        slavePadStack:slavePadStack
//        netIndex:-1
//      ] ;
//      [padArrayForRouting addObject:pfr] ;
//    }
//  //--- Enter in device array
//    PMPackageTypeForRouting * pfr = [[PMPackageTypeForRouting alloc]
//      initWithPackageTypeName:inPackageType.packageTypeName
//      padArray:padArrayForRouting
//    ] ;
//    [ioPackageArrayForRouting addObject:pfr] ;
//  }
//  return idx.unsignedIntegerValue ;
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func findOrAddMasterPad (canariWidth inWidth : Int,
                                     canariHeight inHeight : Int,
                                     style inStyle : PadStyle,
                                     shape inShape : PadShape,
                                     _ ioPadTypeArrayForRouting : inout [MasterPadForRouting]) -> MasterPadForRouting {
//--- Search in existing pads
  for mp in ioPadTypeArrayForRouting {
    if ((mp.canariWidth == inWidth) && (mp.canariHeight == inHeight) && (mp.style == inStyle) && (mp.shape == inShape)) {
      return mp
    }
  }
//  for (NSUInteger i=0 ; (i<ioPadTypeArrayForRouting.count) && (nil == result) ; i++) {
//    PMMasterPadForRouting * mp = [ioPadTypeArrayForRouting objectAtIndex:i] ;
//    if ((mp.width == inWidth) && (mp.height == inHeight) && (mp.side == inSide) && (mp.shape == inShape)) {
//      result = mp ;
//    }
//  }
//--- If not found, create it
 let newPad = MasterPadForRouting (
   name: "ps\(ioPadTypeArrayForRouting.count)",
   canariWidth: inWidth,
   canariHeight: inHeight,
   shape: inShape,
   style: inStyle
 )
 ioPadTypeArrayForRouting.append (newPad)
 return newPad
// if (nil == result) {
//   NSString * padTypeName = [NSString stringWithFormat:@"ps%lu", ioPadTypeArrayForRouting.count] ;
//   result = [[PMMasterPadForRouting alloc]
//     initWithName:padTypeName
//     width:inWidth
//     height:inHeight
//     side:inSide
//     shape:inShape
//   ] ;
//   [ioPadTypeArrayForRouting addObject:result] ;
// }
////---
//  return result ;
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PadNetDescriptor {
  let padString : String
  let netName : String?
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DeviceDictionaryKey : Hashable {
  let device : DeviceInProject
  let package : DevicePackageInProject
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DeviceForRouting {
  let name : String
  let packageIndex : Int
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct NetClassForRouting {
  let name : String
  let trackWidthInMM : CGFloat
  let viaPadDiameterInMM : CGFloat
  let netNames : [String]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct RestrictRectangleForRouting {
  let rect : CanariRect
  let frontSide : Bool
  let backSide  : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentForRouting {
  let deviceIndex : Int
  let componentName : String
  let placed : Bool
  let originX : Int
  let originY : Int
  let rotation : CGFloat
  let side : ComponentSide
  let netList : [PadNetDescriptor]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PackageTypeForRouting {
  let typeName : String
  let padArray : [PadStackForRouting]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PadStackForRouting {
  let name : String
  let masterPad : MasterPadForRouting
  let centerXmm : CGFloat // In mm
  let centerYmm : CGFloat // In mm
//  slavePadStack:slavePadStack
  let netIndex : Int? // nil means no net
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PadElementForRouting {
  let centerX : Int
  let centerY : Int
  let width : Int
  let height : Int
  let shape : PadShape
  let side : ComponentSide
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct MasterPadForRouting {
  let name : String
  let canariWidth  : Int
  let canariHeight : Int
  let shape : PadShape
  let style : PadStyle

  //····················································································································

  func padStringFor (side inSide : String) -> String {
    let halfWidth = canariUnitToMillimeter (self.canariWidth) / 2.0
    let halfHeight = canariUnitToMillimeter (self.canariHeight) / 2.0
    let shapeString : String
    switch self.shape {
    case .rect :
      shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
    case .round :
      if halfWidth < halfHeight {
        shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
      }else if halfWidth > halfHeight {
        shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
      }else{
        shapeString = "(circle \(inSide) \(halfWidth * 2.0) 0 0)"
      }
    case .octo :
      shapeString = "(rect \(inSide) \(-halfWidth) \(-halfHeight) \(halfWidth) \(halfHeight))"
    }
    return shapeString
  }
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addNetwork (_ ioString : inout String,
                             _ inComponentArrayForRouting : [ComponentForRouting]) {
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
                                        _ inNetClasses : [NetClassForRouting]) {
  for netClass in inNetClasses {
    ioString += "    (padstack \"viaForClass\(netClass.name)\"\n"
    ioString += "      (shape (circle \(BACK_SIDE) \(netClass.viaPadDiameterInMM) 0 0))\n"
    ioString += "      (shape (circle \(FRONT_SIDE) \(netClass.viaPadDiameterInMM) 0 0))\n"
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addComponentPadStackLibrary (_ ioString : inout String,
                                              _ inPadTypeArrayForRouting : [MasterPadForRouting]) {
  for pad in inPadTypeArrayForRouting {
    ioString += "    (padstack \"\(pad.name)\"\n"
    switch pad.style {
    case .surface :
      ioString += "      (shape \(pad.padStringFor (side: FRONT_SIDE)))\n"
    case .traversing :
      ioString += "      (shape \(pad.padStringFor (side: FRONT_SIDE)))\n"
      ioString += "      (shape \(pad.padStringFor (side: BACK_SIDE)))\n"
    }
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addDeviceLibrary (_ ioString : inout String,
                                   _ inDeviceArrayForRouting : [DeviceForRouting],
                                   _ inPackageArrayForRouting : [PackageTypeForRouting]) {
  var imageNameSet = Set <String> ()
  for device in inDeviceArrayForRouting {
    let key = "\(device.name)_\(device.packageIndex)"
    if !imageNameSet.contains (key) {
      imageNameSet.insert (key)
      ioString += "    (image \"\(device.name)\"\n"
      let packageType : PackageTypeForRouting = inPackageArrayForRouting [device.packageIndex]
      for pad in packageType.padArray {
        ioString += "      (pin \(pad.masterPad.name) \(pad.name) \(pad.centerXmm) \(pad.centerYmm))\n"
//  let name : String
//  let masterPad : MasterPadForRouting
//  let masterPadCenter : NSPoint
////  slavePadStack:slavePadStack
//  let netIndex : Int? // nil means no net
      }
      ioString += "    )\n"
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addBoardBoundary (_ ioString : inout String) {
  ioString += "    (boundary\n"
  ioString += "      (rect pcb 0 0 100 100)\n"
  ioString += "    )\n"
  ioString += "    (boundary\n"
  ioString += "      (rect signal 1.5 1.5 98.5 98.5)\n"
  ioString += "    )\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addSnapAngle (_ ioString : inout String) {
  ioString += "    (snap_angle\n"
  ioString += "      fortyfive_degree\n"
  ioString += "    )\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func autorouteSettings (_ ioString : inout String) {
  ioString += "    (layer \(FRONT_SIDE) (type signal))\n"
  ioString += "    (layer \(BACK_SIDE) (type signal))\n"
  ioString += "    (autoroute_settings\n"
  ioString += "      (vias on)\n"
  ioString += "      (via_costs 50)\n"
  ioString += "      (plane_via_costs 5)\n"
  ioString += "      (start_ripup_costs 100)\n"
  ioString += "      (start_pass_no 1)\n"
  ioString += "      (layer_rule \(BACK_SIDE)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction horizontal)\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.7)\n"
  ioString += "      )\n"
  ioString += "      (layer_rule \(FRONT_SIDE)\n"
  ioString += "        (active on)\n"
  ioString += "        (prefered_direction vertical)\n"
  ioString += "        (prefered_direction_trace_costs 1.0)\n"
  ioString += "        (against_prefered_direction_trace_costs 2.7)\n"
  ioString += "      )\n"
  ioString += "    )\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addViaClasses (_ ioString : inout String, _ inNetClasses : [NetClassForRouting]) {
  ioString += "    (via"
  for netClass in inNetClasses {
    ioString += " \"viaForClass\(netClass.name)\""
  }
  ioString += ")\n"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addViaRules (_ ioString : inout String, _ inNetClasses : [NetClassForRouting]) {
  for netClass in inNetClasses {
    ioString += "    (via_rule\n"
    ioString += "      \"viaRuleForClass\(netClass.name)\" \"viaForClass\(netClass.name)\"\n"
    ioString += "    )\n"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addNetClasses (_ ioString : inout String, _ inNetClasses : [NetClassForRouting]) {
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
    ioString += "        (use_layer \(FRONT_SIDE) \(BACK_SIDE))\n"
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
                                         _ inComponents : [ComponentForRouting],
                                         _ inDeviceArrayForRouting : [DeviceForRouting]) {
  ioString += "  (placement\n"
  for component in inComponents {
    let x = canariUnitToMillimeter (component.originX)
    let y = canariUnitToMillimeter (component.originY)
    let side : String
    switch component.side {
    case .back : side = "back"
    case .front : side = "front"
    }
    ioString += "    (component \"\(inDeviceArrayForRouting [component.deviceIndex].name)\"\n"
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
                                        _ inRestrictRectangles : [RestrictRectangleForRouting]) {
  for rr in inRestrictRectangles {
    let left = canariUnitToMillimeter (rr.rect.left)
    let bottom = canariUnitToMillimeter (rr.rect.bottom)
    let right = left + canariUnitToMillimeter (rr.rect.width)
    let top = bottom + canariUnitToMillimeter (rr.rect.height)
    if rr.frontSide {
      ioString += "    (keepout\n"
      ioString += "      (rect \(FRONT_SIDE) \(left) \(bottom) \(right) \(top))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
    if rr.backSide {
      ioString += "    (keepout\n"
      ioString += "      (rect \(BACK_SIDE) \(left) \(bottom) \(right) \(top))\n"
      ioString += "      (clearance_class default)\n"
      ioString += "    )\n"
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

