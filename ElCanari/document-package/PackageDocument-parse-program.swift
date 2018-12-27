//
//  PackageDocument-parse-program.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedPackageDocument {

  //····················································································································

//- (BOOL) scanIdentifier: (NSString * *) outResult
//         withScanner: (NSScanner *) inScanner {
//  NSString * firstPart = nil ;
//  BOOL ok = [inScanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:& firstPart] ;
//  NSString * secondPart = @"" ;
//  if (ok) {
//    NSMutableCharacterSet  * s = [NSMutableCharacterSet  new] ;
//    [s formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]] ;
//    [s formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]] ;
//    [inScanner scanCharactersFromSet:s intoString:& secondPart] ;
//  }
//  if (outResult != NULL) {
//    * outResult = [firstPart stringByAppendingString:secondPart] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanUnit: (NSInteger *) outUnit
//         withScanner: (NSScanner *) inScanner {
//  BOOL ok = YES ;
//  NSInteger unit = 0 ;
//  if ([inScanner scanString:@"um" intoString:NULL]) {
//    unit = 90 ;
//  }else if ([inScanner scanString:@"mil" intoString:NULL]) {
//    unit = 2286 ;
//  }else if ([inScanner scanString:@"in" intoString:NULL]) {
//    unit = 2286000 ;
//  }else if ([inScanner scanString:@"mm" intoString:NULL]) {
//    unit = 90000 ;
//  }else if ([inScanner scanString:@"cm" intoString:NULL]) {
//    unit = 900000 ;
//  }else{
//    ok = NO ;
//  }
//  if (outUnit != NULL) {
//    (* outUnit) = unit ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanValueWithUnit: (NSInteger *) outValue
//         unit: (NSInteger *) outUnit
//         withScanner: (NSScanner *) inScanner {
//  NSInteger unit = 0 ;
//  BOOL ok = [inScanner scanInteger:outValue]
//         && [self scanUnit:& unit withScanner:inScanner] ;
//  if (ok) {
//    (* outValue) *= unit ;
//    if (outUnit != NULL) {
//      (* outUnit) = unit ;
//    }
//  }
//  BOOL loop = YES ;
//  while (loop && ok) {
//    if ([inScanner scanString:@"+" intoString:NULL]) {
//      NSInteger value ;
//      ok = [inScanner scanInteger:& value]
//        && [self scanUnit:& unit withScanner:inScanner] ;
//      (* outValue) += value * unit ;
//    }else if ([inScanner scanString:@"-" intoString:NULL]) {
//      NSInteger value ;
//      ok = [inScanner scanInteger:& value]
//        && [self scanUnit:& unit withScanner:inScanner] ;
//      (* outValue) -= value * unit ;
//    }else{
//      loop = NO ;
//    }
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanPoint: (EBPoint *) outPoint
//         unitX: (NSInteger *) outUnitX
//         unitY: (NSInteger *) outUnitY
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  NSString * identifier = nil ;
//  BOOL ok = [self scanIdentifier:& identifier withScanner:inScanner] ;
//  if (ok) {
//    PMIntPoint * point = [inPointDictionary objectForKey:identifier] ;
//    ok = point != nil ;
//    if (ok) {
//      if (outPoint != NULL) {
//        * outPoint = [point p] ;
//      }
//      if (outUnitX != NULL) {
//        * outUnitX = [point unitX] ;
//      }
//      if (outUnitY != NULL) {
//        * outUnitY = [point unitY] ;
//      }
//    }
//  }else{
//    ok = [self scanValueWithUnit:& outPoint->x unit:outUnitX withScanner:inScanner]
//        && [inScanner scanString:@":" intoString:NULL]
//        && [self scanValueWithUnit:& outPoint->y unit:outUnitY withScanner:inScanner] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanLineDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint p1 ; EBPoint p2 ;
//  const BOOL ok = [self scanPoint: & p1 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"to" intoString:NULL]
//    && [self scanPoint: & p2 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary] ;
//  if (ok) {
//    PMClassForSegmentForPackageEntity * segment = [PMClassForSegmentForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [segment setP1:p1] ;
//    [segment setP2:p2] ;
//    [ioNewGraphicSet addObject:segment] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanBezierCurveDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint p1 ; EBPoint p2 ; EBPoint controlP1 ; EBPoint controlP2 ;
//  const BOOL ok = [self scanPoint: & p1 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"to" intoString:NULL]
//    && [self scanPoint: & p2 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"control1" intoString:NULL]
//    && [self scanPoint: & controlP1 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"control2" intoString:NULL]
//    && [self scanPoint: & controlP2 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary] ;
//  if (ok) {
//    PMClassForBezierCurveForPackageEntity * bezierCurve = [PMClassForBezierCurveForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [bezierCurve setP1:p1] ;
//    [bezierCurve setP2:p2] ;
//    [bezierCurve setControlP1:controlP1] ;
//    [bezierCurve setControlP2:controlP2] ;
//    [ioNewGraphicSet addObject:bezierCurve] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanArcDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint center ; NSInteger radius ; double startAngle ; double endAngle ;
//  const BOOL ok = [inScanner scanString:@"center" intoString:NULL]
//    && [self scanPoint: & center unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"radius" intoString:NULL]
//    && [self scanValueWithUnit: & radius unit:NULL withScanner:inScanner]
//    && [inScanner scanString:@"startangle" intoString:NULL]
//    && [inScanner scanDouble: & startAngle]
//    && [inScanner scanString:@"endangle" intoString:NULL]
//    && [inScanner scanDouble: & endAngle]
//  ;
//  if (ok) {
//    NSBezierPath * bp = [NSBezierPath bezierPath] ;
//    [bp
//      appendBezierPathWithArcWithCenter:toNSPoint (center)
//      radius: toNSUnit (radius)
//      startAngle:startAngle
//      endAngle:endAngle
//    ] ;
//    // NSLog (@"[pb elementCount] = %d", bp.elementCount) ;
//    EBPoint currentPoint = {0, 0} ;
//    for (NSInteger i=0 ; i<bp.elementCount ; i++) {
//      NSPoint pointArray [3] ;
//      const NSBezierPathElement element = [bp elementAtIndex:i associatedPoints:pointArray] ;
//      // NSLog (@" at #%d: element %d", i, element) ;
//      if (element == NSMoveToBezierPathElement) {
//        currentPoint = toEBPoint (pointArray [0]) ;
//      }else if (element == NSCurveToBezierPathElement) {
//        PMClassForBezierCurveForPackageEntity * bezierCurve = [PMClassForBezierCurveForPackageEntity
//          insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//        ] ;
//        [bezierCurve setP1:currentPoint] ;
//        [bezierCurve setP2:toEBPoint (pointArray [2])] ;
//        [bezierCurve setControlP1:toEBPoint (pointArray [0])] ;
//        [bezierCurve setControlP2:toEBPoint (pointArray [1])] ;
//        [ioNewGraphicSet addObject:bezierCurve] ;
//        currentPoint = toEBPoint (pointArray [2]) ;
//      }
//    }
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanGuideLineDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint p1 ; EBPoint p2 ;
//  const BOOL ok = [self scanPoint: & p1 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"to" intoString:NULL]
//    && [self scanPoint: & p2 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary] ;
//  if (ok) {
//    PMClassForGuideForPackageEntity * segment = [PMClassForGuideForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [segment setP1:p1] ;
//    [segment setP2:p2] ;
//    [ioNewGraphicSet addObject:segment] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanDimensionDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint p1 ; EBPoint p2 ; NSInteger unit ;
//  const BOOL ok = [self scanPoint: & p1 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"to" intoString:NULL]
//    && [self scanPoint: & p2 unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"unit" intoString:NULL]
//    && [self scanUnit:& unit withScanner:inScanner] ;
//  if (ok) {
//    PMClassForDimensionForPackageEntity * dim = [PMClassForDimensionForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [dim setP1:p1] ;
//    [dim setP2:p2] ;
//    [dim setMeasurementUnit:unit] ;
//    [ioNewGraphicSet addObject:dim] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//- (BOOL) scanOvalDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint center ; NSInteger width ; NSInteger height ;
//  const BOOL ok = [self scanPoint: & center unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"width" intoString:NULL]
//    && [self scanValueWithUnit:& width unit:NULL withScanner:inScanner]
//    && [inScanner scanString:@"height" intoString:NULL]
//    && [self scanValueWithUnit:& height unit:NULL withScanner:inScanner] ;
//  if (ok) {
//    PMClassForFramedOvalForPackageEntity * oval = [PMClassForFramedOvalForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [oval setR:makeEBRectFromCenterAndSize (center, EBMakeSize (width, height))] ;
//    [ioNewGraphicSet addObject:oval] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanPadDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary
//         currentMasterPad: (PMClassForMasterPadForPackageEntity * *) outCurrentMasterPad {
//  EBPoint center ;
//  NSInteger unitCenterX ; NSInteger unitCenterY ;
//  NSInteger width ; NSInteger unitWidth ;
//  NSInteger height ; NSInteger unitHeight ;
//  NSInteger hole = 0 ; NSInteger unitHole = 90000 ; // mm
//  NSString * shape = nil ;
//  NSString * kind = nil ;
//  const BOOL ok =
//    ([inScanner scanString:@"square" intoString:& shape] || [inScanner scanString:@"round" intoString:& shape])
//    && [self scanPoint:&center unitX:&unitCenterX unitY:&unitCenterY withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"width" intoString:NULL]
//    && [self scanValueWithUnit:&width unit:&unitWidth withScanner:inScanner]
//    && [inScanner scanString:@"height" intoString:NULL]
//    && [self scanValueWithUnit:&height unit:&unitHeight withScanner:inScanner]
//    && (([inScanner scanString:@"hole" intoString:& kind] && [self scanValueWithUnit:&hole unit:&unitHole withScanner:inScanner])
//        ||
//         [inScanner scanString:@"componentside" intoString:& kind]
//        ||
//         [inScanner scanString:@"solderside" intoString:& kind]
//       ) ;
//  if (ok) {
//    PMClassForMasterPadForPackageEntity * pad = [PMClassForMasterPadForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [pad setPadShape:[shape isEqualToString:@"square"] ? 0 : 1] ;
//    [pad setPadCenter:center] ;
//    [pad setMeasurementUnitForCenterX:unitCenterX] ;
//    [pad setMeasurementUnitForCenterY:unitCenterY] ;
//    [pad setPadSize:EBMakeSize (width, height)] ;
//    [pad setMeasurementUnitForWidth:unitWidth] ;
//    [pad setMeasurementUnitForHeight:unitHeight] ;
//    [pad setHoleDiameter:hole] ;
//    if ([kind isEqualToString:@"componentside"]) {
//      [pad setSide:1] ;
//    }else if ([kind isEqualToString:@"solderside"]) {
//      [pad setSide:2] ;
//    }
//    [pad setMeasurementUnitForHole:unitHole] ;
//    [ioNewGraphicSet addObject:pad] ;
//    * outCurrentMasterPad = pad ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanSlavePadDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary
//         withCurrentMasterPad: (PMClassForMasterPadForPackageEntity *) inCurrentMasterPad {
//  EBPoint center ; NSInteger unitCenterX ; NSInteger unitCenterY ;
//  NSInteger width ; NSInteger unitWidth ;
//  NSInteger height ; NSInteger unitHeight ;
//  NSInteger hole = 0 ; NSInteger unitHole = 90000 ; // mm
//  NSString * shape = nil ;
//  NSString * kind = nil ;
//  BOOL ok =
//    ([inScanner scanString:@"square" intoString:& shape] || [inScanner scanString:@"round" intoString:& shape])
//    && [self scanPoint:&center unitX:&unitCenterX unitY:&unitCenterY withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"width" intoString:NULL]
//    && [self scanValueWithUnit:&width unit:&unitWidth withScanner:inScanner]
//    && [inScanner scanString:@"height" intoString:NULL]
//    && [self scanValueWithUnit:&height unit:&unitHeight withScanner:inScanner]
//    && (([inScanner scanString:@"hole" intoString:& kind] && [self scanValueWithUnit:&hole unit:&unitHole withScanner:inScanner])
//        ||
//         [inScanner scanString:@"componentside" intoString:& kind]
//        ||
//         [inScanner scanString:@"solderside" intoString:& kind]
//       ) ;
//  if (ok) {
//    ok = inCurrentMasterPad != nil ;
//    PMClassForSlavePadForPackageEntity * pad = [PMClassForSlavePadForPackageEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [pad setMasterPad:inCurrentMasterPad] ;
//    [pad setPadShape:[shape isEqualToString:@"square"] ? 0 : 1] ;
//    [pad setPadCenter:center] ;
//    [pad setMeasurementUnitForCenterX:unitCenterX] ;
//    [pad setMeasurementUnitForCenterY:unitCenterY] ;
//    [pad setPadSize:EBMakeSize (width, height)] ;
//    [pad setMeasurementUnitForWidth:unitWidth] ;
//    [pad setMeasurementUnitForHeight:unitHeight] ;
//    [pad setHoleDiameter:hole] ;
//    if ([kind isEqualToString:@"componentside"]) {
//      [pad setSide:1] ;
//    }else if ([kind isEqualToString:@"solderside"]) {
//      [pad setSide:2] ;
//    }
//    [pad setMeasurementUnitForHole:unitHole] ;
//    [ioNewGraphicSet addObject:pad] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanZoneDefinition: (NSMutableSet *) ioNewGraphicSet
//         withScanner: (NSScanner *) inScanner
//         withPointDictionary: (NSDictionary *) inPointDictionary {
//  EBPoint center ;
//  EBPoint nameLocation ;
//  NSInteger width ;
//  NSInteger height ;
//  NSString * zoneName = nil ;
//  BOOL ok = [self scanPoint:&center unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"name" intoString:NULL]
//    && [inScanner scanUpToCharactersFromSet:[inScanner charactersToBeSkipped] intoString:&zoneName]
//    && [inScanner scanString:@"at" intoString:NULL]
//    && [self scanPoint:&nameLocation unitX:NULL unitY:NULL withScanner:inScanner withPointDictionary:inPointDictionary]
//    && [inScanner scanString:@"width" intoString:NULL]
//    && [self scanValueWithUnit:&width unit:NULL withScanner:inScanner]
//    && [inScanner scanString:@"height" intoString:NULL]
//    && [self scanValueWithUnit:&height unit:NULL withScanner:inScanner]
//    && [inScanner scanString:@"autonumbering" intoString:NULL] ;
//  NSInteger autonumbering ;
//  if (ok) {
//    if ([inScanner scanString:@"no" intoString:NULL]) {
//      autonumbering = 0 ;
//    }else if ([inScanner scanString:@"counterclock" intoString:NULL]) {
//      autonumbering = 1 ;
//    }else if ([inScanner scanString:@"upright" intoString:NULL]) {
//      autonumbering = 2 ;
//    }else if ([inScanner scanString:@"upleft" intoString:NULL]) {
//      autonumbering = 3 ;
//    }else if ([inScanner scanString:@"downright" intoString:NULL]) {
//      autonumbering = 4 ;
//    }else if ([inScanner scanString:@"upright" intoString:NULL]) {
//      autonumbering = 5 ;
//    }else if ([inScanner scanString:@"rightup" intoString:NULL]) {
//      autonumbering = 6 ;
//    }else if ([inScanner scanString:@"rightdown" intoString:NULL]) {
//      autonumbering = 7 ;
//    }else if ([inScanner scanString:@"leftup" intoString:NULL]) {
//      autonumbering = 8 ;
//    }else if ([inScanner scanString:@"leftdown" intoString:NULL]) {
//      autonumbering = 9 ;
//    }else{
//      ok = NO ;
//    }
//  }
//  if (ok) {
//    PMClassForZoneForPadEntity * zone = [PMClassForZoneForPadEntity
//      insertNewObjectIntoManagedObjectContext:self.managedObjectContext
//    ] ;
//    [zone setZoneName:zoneName] ;
//    [zone setPadAutoNumbering:autonumbering] ;
//    [zone setZoneNameOrigin:nameLocation] ;
//    [zone setRectangle:makeEBRectFromCenterAndSize (center, EBMakeSize (width, height))] ;
//    [ioNewGraphicSet addObject:zone] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (BOOL) scanPointDeclarationWithDictionary: (NSMutableDictionary *) ioPointDictionary
//         withScanner: (NSScanner *) inScanner {
//  EBPoint p ={0, 0} ;
//  NSString * pointName = nil ;
//  NSInteger unitX = 0 ;
//  NSInteger unitY = 0 ;
//  BOOL ok = [self scanIdentifier:& pointName withScanner:inScanner]
//    && [inScanner scanString:@"=" intoString:NULL]
//    && [self scanPoint: & p unitX:& unitX unitY:& unitY withScanner:inScanner withPointDictionary:ioPointDictionary] ;
//  NSLog (@"pointName '%@'", pointName) ;
//  if ([ioPointDictionary objectForKey:pointName] != nil) {
//    ok = NO ;
//  }else{
//    PMIntPoint * pointDef = [[PMIntPoint alloc] initWithPoint:p unitX:unitX unitY:unitY] ;
//    [ioPointDictionary setObject:pointDef forKey:pointName HERE] ;
//  }
//  return ok ;
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//- (void) runProgramAction: (id) inSender {
////--- First, clear error signaling
//  [self clearProgramErrorAction:nil] ;
////--- Scan program
//  NSMutableSet * newGraphics = [NSMutableSet setWithCapacity:100] ;
//  NSScanner * scanner = [NSScanner scannerWithString:[mRootObject program]] ;
//  NSMutableDictionary * pointDictionary = [NSMutableDictionary new] ; // Dictionary of PMIntPoint
//  BOOL ok = YES ;
//  BOOL loop = YES ;
//  PMClassForMasterPadForPackageEntity * currentMasterPad = nil ;
//  while (ok && loop && ! [scanner isAtEnd]) {
//    if ([scanner scanString:@"point" intoString:NULL]) {
//      ok = [self scanPointDeclarationWithDictionary:pointDictionary withScanner:scanner] ;
//    }else if ([scanner scanString:@"line" intoString:NULL]) {
//      ok = [self scanLineDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"pad" intoString:NULL]) {
//      ok = [self
//        scanPadDefinition:newGraphics
//        withScanner:scanner
//        withPointDictionary:pointDictionary
//        currentMasterPad:& currentMasterPad
//      ] ;
//    }else if ([scanner scanString:@"slavepad" intoString:NULL]) {
//      ok = [self
//        scanSlavePadDefinition:newGraphics
//        withScanner:scanner
//        withPointDictionary:pointDictionary
//        withCurrentMasterPad:currentMasterPad
//      ] ;
//    }else if ([scanner scanString:@"guideline" intoString:NULL]) {
//      ok = [self scanGuideLineDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"oval" intoString:NULL]) {
//      ok = [self scanOvalDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"beziercurve" intoString:NULL]) {
//      ok = [self scanBezierCurveDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"arc" intoString:NULL]) {
//      ok = [self scanArcDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"dimension" intoString:NULL]) {
//      ok = [self scanDimensionDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"zone" intoString:NULL]) {
//      ok = [self scanZoneDefinition:newGraphics withScanner:scanner withPointDictionary:pointDictionary] ;
//    }else if ([scanner scanString:@"end" intoString:NULL]) {
//      loop = NO ;
//    }else{
//      ok = NO ;
//    }
//  }
//  // NSLog (@"pointDictionary %@", pointDictionary) ;
////--- If ok, set package graphics; if not color in red from error location
//  NSManagedObjectContext * moc = self.managedObjectContext ;
//  NSTextStorage * textStorage = [programTextView textStorage] ;
//  if (ok) {
//    NSSet * previousDrawings = [mRootObject packageGraphics] ;
//    [moc deleteObjectsFromSet:previousDrawings] ;
//    [mRootObject setPackageGraphics:newGraphics] ;
//    [mRootObject setSelectedTab:0] ;
//  //--- Remove color
//    const NSRange range = {0, [textStorage length]} ;
//    [textStorage removeAttribute:NSForegroundColorAttributeName range:range] ;
//  }else{
//    [moc deleteObjectsFromSet:newGraphics] ;
//    const NSUInteger scanLocation = [scanner scanLocation] ;
//    const NSRange errorRange = {scanLocation, [textStorage length] - scanLocation} ;
//    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//      [NSColor redColor], NSForegroundColorAttributeName,
//      nil
//    ] ;
//    [textStorage
//      addAttributes:attributes
//      range:errorRange
//    ] ;
//  }
//}


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
