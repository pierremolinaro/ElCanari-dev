//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_BoardModel_imageForModel (
       _ prefs_mergerColorBackground : NSColor,     
       _ prefs_mergerShowModelBackground : Bool,    
       _ self_modelWidth : Int,                     
       _ self_modelHeight : Int,                    
       _ self_boardLimitsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayModelBoardLimits : Bool,
       _ prefs_mergerColorInternalBoardsLimits : NSColor,
       _ self_internalBoardsLimitsBezierPaths : BezierPathArray,
       _ self_frontTracksBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontTracks : Bool,
       _ prefs_mergerColorFrontTracks : NSColor,    
       _ self_inner1TracksBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayInner1Tracks : Bool,
       _ prefs_mergerColorInner1Tracks : NSColor,   
       _ self_inner2TracksBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayInner2Tracks : Bool,
       _ prefs_mergerColorInner2Tracks : NSColor,   
       _ self_inner3TracksBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayInner3Tracks : Bool,
       _ prefs_mergerColorInner3Tracks : NSColor,   
       _ self_inner4TracksBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayInner4Tracks : Bool,
       _ prefs_mergerColorInner4Tracks : NSColor,   
       _ self_backTracksBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackTracks : Bool,
       _ prefs_mergerColorBackTracks : NSColor,     
       _ self_frontPadsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontPads : Bool,
       _ prefs_mergerColorFrontPads : NSColor,      
       _ self_backPadsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackPads : Bool,
       _ prefs_mergerColorBackPads : NSColor,       
       _ self_traversingPadsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayTraversingPads : Bool,
       _ prefs_mergerColorTraversingPads : NSColor, 
       _ self_viasBezierPaths : BezierPathArray,    
       _ prefs_mergerModelViewDisplayVias : Bool,   
       _ prefs_mergerColorVias : NSColor,           
       _ self_holesBezierPaths : BezierPathArray,   
       _ prefs_mergerModelViewDisplayHoles : Bool,  
       _ prefs_mergerColorHoles : NSColor,          
       _ self_frontLegendBoardImageRectangles : MergerRectangleArray,
       _ self_frontLegendQRCodeRectangles : MergerRectangleArray,
       _ self_frontLegendLinesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontLegendLines : Bool,
       _ prefs_mergerColorFrontLegendLines : NSColor,
       _ self_backLegendBoardImageRectangles : MergerRectangleArray,
       _ self_backLegendQRCodeRectangles : MergerRectangleArray,
       _ self_backLegendLinesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackLegendLines : Bool,
       _ prefs_mergerColorBackLegendLines : NSColor,
       _ self_frontLegendTextsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontLegendTexts : Bool,
       _ prefs_mergerColorFrontLegendTexts : NSColor,
       _ self_frontLayoutTextsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontLayoutTexts : Bool,
       _ prefs_mergerColorFrontLayoutTexts : NSColor,
       _ self_backLegendTextsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackLegendTexts : Bool,
       _ prefs_mergerColorBackLegendTexts : NSColor,
       _ self_backLayoutTextsBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackLayoutTexts : Bool,
       _ prefs_mergerColorBackLayoutTexts : NSColor,
       _ self_backComponentNamesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackComponentNames : Bool,
       _ prefs_mergerColorBackComponentNames : NSColor,
       _ self_frontComponentNamesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontComponentNames : Bool,
       _ prefs_mergerColorFrontComponentNames : NSColor,
       _ self_frontComponentValuesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontComponentValues : Bool,
       _ prefs_mergerColorFrontComponentValues : NSColor,
       _ self_backComponentValuesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackComponentValues : Bool,
       _ prefs_mergerColorBackComponentValues : NSColor,
       _ self_frontPackagesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayFrontPackages : Bool,
       _ prefs_mergerColorFrontPackages : NSColor,  
       _ self_backPackagesBezierPaths : BezierPathArray,
       _ prefs_mergerModelViewDisplayBackPackages : Bool,
       _ prefs_mergerColorBackPackages : NSColor
) -> EBShape {
//--- START OF USER ZONE 2
  var shapes = EBShape ()
//--- Background
  if prefs_mergerShowModelBackground {
    let backRect = NSRect (x: 0.0, y: 0.0, width: canariUnitToCocoa (self_modelWidth), height: canariUnitToCocoa(self_modelHeight))
    shapes.add (filled: [BézierPath (rect: backRect)], prefs_mergerColorBackground)
  }
//--- Back Legend Lines, images and QR Codes
  if (prefs_mergerModelViewDisplayBackLegendLines) {
    shapes.add (stroke: self_backLegendLinesBezierPaths.array, prefs_mergerColorBackLegendLines)
    shapes.add (filled: self_backLegendQRCodeRectangles.bezierPathArray, prefs_mergerColorBackLegendLines)
    shapes.add (filled: self_backLegendBoardImageRectangles.bezierPathArray, prefs_mergerColorBackLegendLines)
  }
//--- Back Component Values
  if (prefs_mergerModelViewDisplayBackComponentValues) {
    shapes.add (stroke: self_backComponentValuesBezierPaths.array, prefs_mergerColorBackComponentValues)
  }
//--- Back Component Names
  if (prefs_mergerModelViewDisplayBackComponentNames) {
    shapes.add (stroke: self_backComponentNamesBezierPaths.array, prefs_mergerColorBackComponentNames)
  }
//--- Back Legend Texts
  if (prefs_mergerModelViewDisplayBackLegendTexts) {
    shapes.add (stroke: self_backLegendTextsBezierPaths.array, prefs_mergerColorBackLegendTexts)
  }
//--- Back Packages
  if (prefs_mergerModelViewDisplayBackPackages) {
    shapes.add (stroke: self_backPackagesBezierPaths.array, prefs_mergerColorBackPackages)
  }
//--- Back Layout Texts
  if (prefs_mergerModelViewDisplayBackLayoutTexts) {
    shapes.add (stroke: self_backLayoutTextsBezierPaths.array, prefs_mergerColorBackLayoutTexts)
  }
//--- Back tracks
  if prefs_mergerModelViewDisplayBackTracks {
    shapes.add (stroke: self_backTracksBezierPaths.array, prefs_mergerColorBackTracks)
  }
//--- Back pads
  if (prefs_mergerModelViewDisplayBackPads) {
    shapes.add (filled: self_backPadsBezierPaths.array, prefs_mergerColorBackPads)
//    shapes.add (stroke: self_backTracksNoSilkScreenBezierPaths.array, prefs_mergerColorBackPads)
  }
//--- Inner 4 tracks
  if (prefs_mergerModelViewDisplayInner4Tracks) {
    shapes.add (stroke: self_inner4TracksBezierPaths.array, prefs_mergerColorInner4Tracks)
  }
//--- Inner 3 tracks
  if (prefs_mergerModelViewDisplayInner3Tracks) {
    shapes.add (stroke: self_inner3TracksBezierPaths.array, prefs_mergerColorInner3Tracks)
  }
//--- Inner 2 tracks
  if (prefs_mergerModelViewDisplayInner2Tracks) {
    shapes.add (stroke: self_inner2TracksBezierPaths.array, prefs_mergerColorInner2Tracks)
  }
//--- Inner 1 tracks
  if (prefs_mergerModelViewDisplayInner1Tracks) {
    shapes.add (stroke: self_inner1TracksBezierPaths.array, prefs_mergerColorInner1Tracks)
  }
//--- Traversing pads
  if (prefs_mergerModelViewDisplayTraversingPads) {
    shapes.add (filled: self_traversingPadsBezierPaths.array, prefs_mergerColorTraversingPads)
  }
//--- Front tracks
  if prefs_mergerModelViewDisplayFrontTracks {
    shapes.add (stroke: self_frontTracksBezierPaths.array, prefs_mergerColorFrontTracks)
  }
//--- Front layout texts
  if (prefs_mergerModelViewDisplayFrontLayoutTexts) {
    shapes.add (stroke: self_frontLayoutTextsBezierPaths.array, prefs_mergerColorFrontLayoutTexts)
  }
//--- Front Legend Lines
  if (prefs_mergerModelViewDisplayFrontLegendLines) {
    shapes.add (stroke: self_frontLegendLinesBezierPaths.array, prefs_mergerColorFrontLegendLines)
  }
//--- Front Legend texts
  if (prefs_mergerModelViewDisplayFrontLegendTexts) {
    shapes.add (stroke: self_frontLegendTextsBezierPaths.array, prefs_mergerColorFrontLegendTexts)
    shapes.add (filled: self_frontLegendQRCodeRectangles.bezierPathArray, prefs_mergerColorFrontLegendTexts)
    shapes.add (filled: self_frontLegendBoardImageRectangles.bezierPathArray, prefs_mergerColorFrontLegendTexts)
  }
//--- Front Packages
  if (prefs_mergerModelViewDisplayFrontPackages) {
    shapes.add (stroke: self_frontPackagesBezierPaths.array, prefs_mergerColorFrontPackages)
  }
//--- Front Component Names
  if (prefs_mergerModelViewDisplayFrontComponentNames) {
    shapes.add (stroke: self_frontComponentNamesBezierPaths.array, prefs_mergerColorFrontComponentNames)
  }
//--- Front Component Values
  if (prefs_mergerModelViewDisplayFrontComponentValues) {
    shapes.add (stroke: self_frontComponentValuesBezierPaths.array, prefs_mergerColorFrontComponentValues)
  }
//--- Front pads
  if (prefs_mergerModelViewDisplayFrontPads) {
    shapes.add (filled: self_frontPadsBezierPaths.array, prefs_mergerColorFrontPads)
//    shapes.add (stroke: self_frontTracksNoSilkScreenBezierPaths.array, prefs_mergerColorFrontPads)
  }
//--- Model Board limits
  do{
    let color = prefs_mergerModelViewDisplayModelBoardLimits ? prefs_mergerColorInternalBoardsLimits : .clear
    shapes.add (stroke: self_internalBoardsLimitsBezierPaths.array, color)
    shapes.add (stroke: self_boardLimitsBezierPaths.array, color)
  }
//--- Vias
  if (prefs_mergerModelViewDisplayVias) {
    shapes.add (filled: self_viasBezierPaths.array, prefs_mergerColorVias)
  }
//--- Holes
  if (prefs_mergerModelViewDisplayHoles) {
    shapes.add (stroke: self_holesBezierPaths.array, prefs_mergerColorHoles)
  }
//---
  return shapes
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
