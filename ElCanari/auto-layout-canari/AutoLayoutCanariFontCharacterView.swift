//
//  AutoLayoutCanariFontCharacterView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 28/11/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Placement
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let PLACEMENT_GRID : CGFloat = 11.0
private let GERBER_FLOW_ARROW_SIZE : CGFloat = 6.0
private let SELECTION_KNOB_SIZE : CGFloat = 8.0
private let MAX_X : Int = 32
private let MIN_Y : Int = -8
private let MAX_Y : Int = 26

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func xForX (_ inX : Int) -> CGFloat {
  return CGFloat (inX + 2) * PLACEMENT_GRID
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func yForY (_ inY : Int) -> CGFloat {
  return CGFloat (inY + 9) * PLACEMENT_GRID
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func knobRect (_ inX : Int, _ inY : Int) -> NSRect {
  return NSRect (
    x: xForX (inX) - SELECTION_KNOB_SIZE / 2.0,
    y: yForY (inY) - SELECTION_KNOB_SIZE / 2.0,
    width: SELECTION_KNOB_SIZE,
    height: SELECTION_KNOB_SIZE
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariFontCharacterView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariFontCharacterView : NSView, EBUserClassNameProtocol {

  //····················································································································

  private weak var mFontDocument : AutoLayoutFontDocument? =  nil
  private var mSelectionRectangle : NSRect? = nil

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.setPasteboardPrivateObjectType ()
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func set (document inDocument : AutoLayoutFontDocument) {
    self.mFontDocument = inDocument
  }

  //····················································································································
  //  First responder
  //····················································································································

  override var acceptsFirstResponder : Bool { return true }

  //····················································································································
  //  Focus ring (https://developer.apple.com/library/content/qa/qa1785/_index.html)
  //····················································································································

  override var focusRingMaskBounds : NSRect { return self.bounds }

  //····················································································································

  override func drawFocusRingMask () {
    NSBezierPath.fill (self.bounds)
  }

  //····················································································································
  //  isOpaque
  //····················································································································

  override var isOpaque : Bool { return true }

  //····················································································································
  //  drawRect
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
  //--- Background
    NSColor.white.setFill ()
    NSBezierPath.fill (inDirtyRect)
  //--- Border
    let r = self.bounds.insetBy (dx: 0.5, dy: 0.5)
    var bp = NSBezierPath (rect: r)
    bp.lineWidth = 1.0
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Draw grid
    bp = NSBezierPath ()
    for y in MIN_Y / 2 ... -1 {
      let yy = yForY (y * 2)
      bp.move (to: NSPoint (x: 20.0, y: yy))
      bp.line (to: NSPoint (x: NSMaxX (self.bounds), y: yy))
    }
    for y in 1 ... MAX_Y / 2 {
      let yy = yForY (y * 2)
      bp.move (to: NSPoint (x: 20.0, y: yy))
      bp.line (to: NSPoint (x: NSMaxX (self.bounds), y: yy))
    }
    for x in 1 ... MAX_X / 2 {
      let xx = xForX (x * 2)
      bp.move (to: NSPoint (x: xx, y: 0.0))
      bp.line (to: NSPoint (x: xx, y: yForY (MAX_Y) + 10.0))
    }
    bp.lineWidth = 1.0
    NSColor.lightGray.setStroke ()
    bp.stroke ()
  //--- Main X and Y axis
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: xForX (0), y: 0.0))
    bp.line (to: NSPoint (x: xForX (0), y: yForY (MAX_Y) + 10.0))
    bp.move (to: NSPoint (x: 20.0, y: yForY (0)))
    bp.line (to: NSPoint (x: NSMaxX (self.bounds), y: yForY (0)))
    bp.lineWidth = 1.0
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Add X axis values
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.userFixedPitchFont (ofSize: 11.0)!
    ]
    for x in 0 ... MAX_X / 2 {
      let xx = xForX (x * 2)
      let s = "\(x*2)"
      let size = s.size (withAttributes: textAttributes)
      s.draw (at: NSPoint (x: xx - size.width * 0.5, y: yForY (MAX_Y) + 10.0), withAttributes: textAttributes)
    }
  //--- Add Y axis values
    for y in MIN_Y / 2 ... MAX_Y / 2 {
      let yy = yForY (y * 2)
      let s = "\(y*2)"
      let size = s.size (withAttributes: textAttributes)
      s.draw (at: NSPoint (x: 18.0 - size.width, y: yy - size.height * 0.5), withAttributes: textAttributes)
    }
  //--- Selection rectangle
    if let selectionRectangle = self.mSelectionRectangle {
      bp = NSBezierPath (rect: selectionRectangle)
      NSColor.gray.withAlphaComponent (0.1).setFill ()
      bp.fill ()
      bp.lineWidth = 1.0
      NSColor.black.setStroke ()
      bp.stroke ()
    }
  //--- Character segments
    bp = NSBezierPath ()
    for segment in self.mSegmentList {
      bp.move (to: NSPoint (x: xForX (segment.x1), y: yForY (segment.y1)))
      bp.line (to: NSPoint (x: xForX (segment.x2), y: yForY (segment.y2)))
    }
    bp.lineWidth = PLACEMENT_GRID * 2.0
    bp.lineCapStyle = .round
    NSColor.black.withAlphaComponent (self.mSegmentTransparency).setStroke ()
    bp.stroke ()
  //--- Character advancement
    let advanceRect = NSRect (
      origin: NSPoint (x:xForX (self.mAdvancement) - PLACEMENT_GRID / 2.0, y: yForY (0) - PLACEMENT_GRID / 2.0),
      size: NSSize (width: PLACEMENT_GRID, height: PLACEMENT_GRID)
    )
    bp = NSBezierPath (ovalIn: advanceRect)
    NSColor.brown.setFill ()
    bp.fill ()
  //--- Draw display flow
    if self.mDisplaySegmentFlow {
      let strokePath = NSBezierPath ()
      let fillPath = NSBezierPath ()
      var currentX = 0
      var currentY = 0
      strokePath.move (to: NSPoint (x: xForX (0), y: yForY (0)))
      for segment in self.mSegmentList {
        if (segment.x1 != currentX) || (segment.y1 != currentY) {
          currentX = segment.x1
          currentY = segment.y1
          strokePath.addArrow (fillPath: fillPath, to: NSPoint (x: xForX (currentX), y: yForY (currentY)), arrowSize: GERBER_FLOW_ARROW_SIZE)
        }
        if (segment.x2 != currentX) || (segment.y2 != currentY) {
          currentX = segment.x2
          currentY = segment.y2
          strokePath.addArrow (fillPath: fillPath, to: NSPoint (x: xForX (currentX), y: yForY (currentY)), arrowSize: GERBER_FLOW_ARROW_SIZE)
        }
      }
      NSColor.orange.setFill ()
      NSColor.orange.setStroke ()
      strokePath.lineWidth = 1.0
      strokePath.lineCapStyle = .round
      strokePath.stroke ()
      fillPath.fill ()
    }
  //--- Draw index flow
    if self.mDrawGerberFlowIndex {
      var idx = 1
      for segment in self.mSegmentList {
        let x = (xForX (segment.x1) + xForX (segment.x2)) / 2.0
        let y = (yForY (segment.y1) + yForY (segment.y2)) / 2.0
        let textAttributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : NSFont.userFixedPitchFont (ofSize: 18.0)!,
          NSAttributedString.Key.foregroundColor : NSColor.yellow
        ]
        let s = "\(idx)"
        let size = s.size (withAttributes: textAttributes)
        s.draw (at: NSPoint (x: x - size.width * 0.5, y: y - size.height * 0.5), withAttributes: textAttributes)
        idx += 1
      }
    }
  //--- Draw selection knobs
    NSColor.white.setFill ()
    NSColor.black.setStroke ()
    for segment in self.mSelection {
      let bp1 = NSBezierPath (rect:knobRect (segment.x1, segment.y1))
      bp1.fill ()
      bp1.lineWidth = 1.0
      bp1.stroke ()
      let bp2 = NSBezierPath (rect:knobRect (segment.x2, segment.y2))
      bp2.fill ()
      bp2.lineWidth = 1.0
      bp2.stroke ()
    }
  }

  //····················································································································
  //  advance binding
  //····················································································································

  final private func updateAdvance (_ object : EBReadOnlyProperty_Int) {
    switch object.selection {
    case .empty, .multiple :
      break ;
    case .single (let value) :
      self.setAdvance (value)
    }
  }

  //····················································································································

  private var mAdvanceController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_advance (_ object : EBReadOnlyProperty_Int) -> Self {
    self.mAdvanceController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateAdvance (object) }
    )
    return self
  }

  //····················································································································

  final func unbind_advance () {
    self.mAdvanceController?.unregister ()
    self.mAdvanceController = nil
  }

  //····················································································································

  fileprivate var mAdvancement = 0

  //····················································································································

  final func setAdvance (_ inAdvance : Int) {
    self.mAdvancement = inAdvance
    self.needsDisplay = true
  }

  //····················································································································
  //  characterSegmentList binding
  //····················································································································

  private var mCharacterSegmentListController : EBObservablePropertyController? = nil

  final func bind_characterSegmentList (_ object : EBReadOnlyProperty_CharacterSegmentList) -> Self {
    self.mCharacterSegmentListController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateSegmentDrawingsFromCharacterSegmentListController (object) }
    )
    return self
  }

  //····················································································································

  final func unbind_characterSegmentList () {
    self.mCharacterSegmentListController?.unregister ()
    self.mCharacterSegmentListController = nil
  }

  //····················································································································

  private func updateSegmentDrawingsFromCharacterSegmentListController (_ inSegments : EBReadOnlyProperty_CharacterSegmentList) {
    switch inSegments.selection {
    case .empty, .multiple :
      ()
    case .single (let segments) :
      self.mSegmentList = segments.code
      let oldSelection = self.mSelection
      self.mSelection = Set ()
      for oldSegment in oldSelection {
        for newSegment in self.mSegmentList {
          if oldSegment.x1 == newSegment.x1, oldSegment.y1 == newSegment.y1,
             oldSegment.x2 == newSegment.x2, oldSegment.y2 == newSegment.y2 {
            self.mSelection.insert (newSegment)
            break
          }
        }
      }
//      Swift.print ("Update \(oldSelection.count) -> \(self.mSelection.count)")
      self.needsDisplay = true
    }
  }

  //····················································································································
  //  transparency binding
  //····················································································································

  final private func updateTransparency (_ object : EBReadOnlyProperty_Double) {
    switch object.selection {
    case .empty, .multiple :
      break
    case .single(let t) :
      self.updateSegmentDrawingsFromTransparencyController (CGFloat (t))
    }
  }

  //····················································································································

  private var mTransparencyController : EBObservablePropertyController? = nil

  final func bind_transparency (_ object : EBReadOnlyProperty_Double) -> Self {
    self.mTransparencyController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateTransparency (object) }
    )
    return self
  }

  //····················································································································

  final func unbind_transparency () {
    self.mTransparencyController?.unregister ()
    self.mTransparencyController = nil
  }

  //····················································································································

  fileprivate var mSegmentTransparency : CGFloat = 0.5

  //····················································································································

  final func updateSegmentDrawingsFromTransparencyController (_ inSegmentTransparency : CGFloat) {
    self.mSegmentTransparency = inSegmentTransparency
    self.needsDisplay = true
  }

  //····················································································································
  //  display flow binding
  //····················································································································

  final private func updateDisplayFlow (_ object : EBReadOnlyProperty_Bool) {
    switch object.selection {
    case .empty, .multiple :
      break
    case .single (let b) :
      self.updateSegmentDrawingsFromDisplayFlowController (b)
    }
  }

  //····················································································································

  private var mDisplayFlowController : EBObservablePropertyController? = nil

  final func bind_displayFlow (_ object : EBReadOnlyProperty_Bool) -> Self {
    self.mDisplayFlowController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateDisplayFlow (object) }
    )
    return self
  }

  //····················································································································

  final func unbind_displayFlow () {
    self.mDisplayFlowController?.unregister ()
    self.mDisplayFlowController = nil
  }

  //····················································································································

  fileprivate var mDisplaySegmentFlow = true

  //····················································································································

  final func updateSegmentDrawingsFromDisplayFlowController (_ inDisplaySegmentFlow : Bool) {
    self.mDisplaySegmentFlow = inDisplaySegmentFlow
    self.needsDisplay = true
  }

  //····················································································································
  //  index drawing binding
  //····················································································································

  final private func updateIndexDrawing (_ object : EBReadOnlyProperty_Bool) {
    switch object.selection {
    case .empty, .multiple :
      break
    case .single (let b) :
      self.updateSegmentDrawingsFromDisplayDrawingIndexesController (b)
    }
  }

  //····················································································································

  private var mDisplayDrawingIndexesController : EBObservablePropertyController? = nil

  final func bind_displayDrawingIndexes (_ object : EBReadOnlyProperty_Bool) -> Self {
    self.mDisplayDrawingIndexesController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateIndexDrawing (object) }
    )
    return self
  }

  //····················································································································

  final func unbind_displayDrawingIndexes () {
    self.mDisplayDrawingIndexesController?.unregister ()
    self.mDisplayDrawingIndexesController = nil
  }

  //····················································································································

  fileprivate var mDrawGerberFlowIndex = true

  //····················································································································

  final func updateSegmentDrawingsFromDisplayDrawingIndexesController (_ inDrawGerberFlowIndex : Bool) {
    self.mDrawGerberFlowIndex = inDrawGerberFlowIndex
    self.needsDisplay = true
  }

  //····················································································································
  //  selection
  //····················································································································

  func appendSegment () {
    var newSegmentArray = self.mSegmentList
    let newSegment = FontCharacterSegment (x1: 2, y1: 1, x2: 9, y2: 8)
    newSegmentArray.append (newSegment)
    self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
  }

  //····················································································································
  //  selection
  //····················································································································

  private var mSelection = Set <FontCharacterSegment> ()

  //····················································································································
  //  Model
  //····················································································································

  fileprivate var mSegmentList = [FontCharacterSegment] ()

  //····················································································································
  //  Menu actions
  //····················································································································

  final func validateMenuItem (_ menuItem: NSMenuItem) -> Bool {
    let action = menuItem.action
    if action == #selector (Self.delete(_:)) {
      return self.mSelection.count > 0
    }else if action == #selector (Self.selectAll(_:)) {
      return self.mSegmentList.count > 0
    }else if action == #selector (Self.bringForward(_:)) {
      return (self.mSelection.count > 0) && (self.mSegmentList.count > 0) && !self.mSelection.contains (self.mSegmentList.last!)
    }else if action == #selector (Self.bringToFront(_:)) {
      return (self.mSelection.count > 0) && (self.mSegmentList.count > 0) && !self.mSelection.contains (self.mSegmentList.last!)
    }else if action == #selector (Self.sendBackward(_:)) {
      return (self.mSelection.count > 0) && (self.mSegmentList.count > 0) && !self.mSelection.contains (self.mSegmentList.first!)
    }else if action == #selector (Self.sendToBack(_:)) {
      return (self.mSelection.count > 0) && (self.mSegmentList.count > 0) && !self.mSelection.contains (self.mSegmentList.first!)
    }else if action == #selector (Self.copy(_:)) {
      return (self.mSelection.count > 0) && (self.mSegmentList.count > 0)
    }else if action == #selector (Self.cut(_:)) {
      return (self.mSelection.count > 0) && (self.mSegmentList.count > 0)
    }else if action == #selector (Self.paste(_:)) {
      return NSPasteboard.general.data (forType: FONT_SEGMENTS_PASTEBOARD_TYPE) != nil
    }else{
      return false // super.validateMenuItem (menuItem)
    }
  }

  //····················································································································

  @objc final func delete (_ sender : Any?) {
    deleteSelection ()
  }

  //····················································································································

  final override func selectAll (_ sender : Any?) {
    self.mSelection = Set (self.mSegmentList)
    self.needsDisplay = true
  }

  //····················································································································

  @objc func bringForward (_ sender : Any?) {
    if self.mSelection.count == 0 {
      NSSound.beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = newSegmentArray.count
      for segment in self.mSegmentList.reversed () {
        idx -= 1
        if self.mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.insert (segment, at:idx + 1)
        }
      }
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································

  @objc func bringToFront (_ sender : Any?) {
    if self.mSelection.count == 0 {
      NSSound.beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = -1
      for segment in self.mSegmentList {
        idx += 1
        if self.mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.append (segment)
        }
      }
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································

  @objc func sendBackward (_ sender : Any?) {
    if self.mSelection.count == 0 {
      NSSound.beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = -1
      for segment in self.mSegmentList {
        idx += 1
        if self.mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.insert (segment, at:idx - 1)
        }
      }
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································

  @objc func sendToBack (_ sender : Any?) {
    if self.mSelection.count == 0 {
      NSSound.beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = newSegmentArray.count
      for segment in self.mSegmentList.reversed () {
        idx -= 1
        if self.mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.insert (segment, at: 0)
        }
      }
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································
  //  Delete Selection
  //····················································································································

  final func deleteSelection () {
    if self.mSelection.count == 0 {
      NSSound.beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      for segment in self.mSelection {
        let possibleIdx = self.mSegmentList.firstIndex (of: segment)
        if let idx = possibleIdx {
          newSegmentArray.remove (at: idx)
        }
      }
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································
  //  Can move selection
  //····················································································································

  final func canMoveSelectionFrom (knob : Int, byX : Int, byY : Int) -> Bool {
    var canMove = self.mSelection.count > 0
    if knob == 0 {
      for object in self.mSelection {
        let newX = object.x1 + byX
        canMove = (newX >= 0) && (newX <= MAX_X)
        if canMove {
          let newY = object.y1 + byY
          canMove = (newY >= MIN_Y) && (newY <= MAX_Y)
        }
        if !canMove {
          break
        }
      }
    }else{
      for object in self.mSelection {
        let newX = object.x2 + byX
        canMove = (newX >= 0) && (newX <= MAX_X)
        if canMove {
          let newY = object.y2 + byY
          canMove = (newY >= MIN_Y) && (newY <= MAX_Y)
        }
        if !canMove {
          break
        }
      }
    }
//    Swift.print ("canMoveSelectionFrom \(self.mSelection) -> \(canMove)")
    return canMove
  }

  //····················································································································

  final func canMoveSelection (byX : Int, byY : Int) -> Bool {
    return self.canMoveSelectionFrom (knob: 0, byX: byX, byY: byY) && self.canMoveSelectionFrom (knob: 1, byX: byX, byY: byY)
  }

  //····················································································································
  //  Move selection
  //····················································································································

  final func moveSelectionFrom (knob : Int, byX : Int, byY : Int) {
    if self.canMoveSelectionFrom (knob: knob, byX: byX, byY: byY) {
      var newSegmentArray = [FontCharacterSegment] ()
      let oldSelection = self.mSelection
      self.mSelection = Set ()
      for segment in self.mSegmentList {
        if oldSelection.contains (segment) {
          var x1 = segment.x1
          var y1 = segment.y1
          var x2 = segment.x2
          var y2 = segment.y2
          if knob == 0 {
            x1 += byX
            y1 += byY
          }else{
            x2 += byX
            y2 += byY
          }
          let newSegment = FontCharacterSegment (x1: x1, y1: y1, x2: x2, y2: y2)
          newSegmentArray.append (newSegment)
          self.mSelection.insert (newSegment)
        }else{
          newSegmentArray.append (segment)
        }
      }
//      Swift.print ("moveSelectionFrom \(newSegmentArray.count) selection \(oldSelection.count) -> \(self.mSelection.count)")
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }else{
      NSSound.beep ()
    }
  }

  //····················································································································

  final func moveSelection (byX : Int, byY : Int) {
    if self.canMoveSelection (byX: byX, byY: byY) {
      var newSegmentArray = [FontCharacterSegment] ()
      let oldSelection = self.mSelection
      self.mSelection = Set ()
      for segment in self.mSegmentList {
        if oldSelection.contains (segment) {
          let newSegment = FontCharacterSegment (
            x1: segment.x1 + byX,
            y1: segment.y1 + byY,
            x2: segment.x2 + byX,
            y2: segment.y2 + byY
          )
          newSegmentArray.append (newSegment)
          self.mSelection.insert (newSegment)
        }else{
          newSegmentArray.append (segment)
        }
      }
//      Swift.print ("moveSelection \(newSegmentArray.count) selection \(oldSelection.count) -> \(self.mSelection.count)")
      self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }else{
      NSSound.beep ()
    }
  }

  //····················································································································
  //   PASTEBOARD
  //····················································································································

  private let FONT_SEGMENTS_PASTEBOARD_TYPE = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pierre.ElCanari.font.segments")

  //····················································································································

  private final func setPasteboardPrivateObjectType () {
    registerForDraggedTypes ([FONT_SEGMENTS_PASTEBOARD_TYPE])
  }

  //····················································································································

  @objc func paste (_ sender : Any?) {
  //--- Get General Pasteboard
    let pb = NSPasteboard.general
  //--- Find a matching type name
    if let matchingType : NSPasteboard.PasteboardType = pb.availableType (from: [FONT_SEGMENTS_PASTEBOARD_TYPE]) {
    //--- Get data from pasteboard
      let possibleArchive : Data? = pb.data (forType: matchingType)
      if let archive = possibleArchive {
      //--- Unarchive to get array of archived objects
      //    let unarchivedObject = NSUnarchiver.unarchiveObject (with: archive)
      //    let unarchivedObject = NSKeyedUnarchiver.unarchiveObject (with: archive)
      //    if let segmentListObject = unarchivedObject as? [[NSNumber]] {
        if let object = try? NSKeyedUnarchiver.unarchivedObject (ofClass: NSArray.self, from: archive), let segmentListObject = object as? [[NSNumber]] {
          var newSegmentArray = self.mSegmentList
          self.mSelection.removeAll ()
          for archivedSegment : [NSNumber] in segmentListObject {
            let newSegment = FontCharacterSegment (
              x1: archivedSegment [0].intValue,
              y1: archivedSegment [1].intValue,
              x2: archivedSegment [2].intValue,
              y2: archivedSegment [3].intValue
            )
            newSegmentArray.append (newSegment)
            self.mSelection.insert (newSegment)
          }
          self.mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
        }
      }
    }
  }

  //····················································································································

  @objc func copy (_ sender : Any?) {
  //--- Declare pasteboard types
    let pb = NSPasteboard.general
    pb.declareTypes ([FONT_SEGMENTS_PASTEBOARD_TYPE], owner:self)
  //--- Copy private representation
    var segmentArray = [[NSNumber]] ()
    for segment in self.mSegmentList {
      if self.mSelection.contains (segment) {
        let s : [NSNumber] = [
          NSNumber (value: segment.x1),
          NSNumber (value: segment.y1),
          NSNumber (value: segment.x2),
          NSNumber (value: segment.y2)
        ]
        segmentArray.append (s)
      }
    }
    let data = try! NSKeyedArchiver.archivedData (withRootObject: segmentArray, requiringSecureCoding: true)
 //   let data = NSKeyedArchiver.archivedData (withRootObject: segmentArray) // Deprecated 10.14
//    let data = NSArchiver.archivedData (withRootObject: segmentArray) // § Deprecated 10.13
    pb.setData (data, forType: FONT_SEGMENTS_PASTEBOARD_TYPE)
  }

  //····················································································································

  @objc func cut (_ sender : Any?) {
    self.copy (sender)
    deleteSelection ()
  }

  //····················································································································
  //  Key down
  //····················································································································

  final override func keyDown (with event: NSEvent) {
    let shiftKeyOn = event.modifierFlags.contains (.shift)
    let amount = shiftKeyOn ? 4 : 1
    let unicodeScalars = event.charactersIgnoringModifiers!.unicodeScalars
    let unicodeChar = unicodeScalars [unicodeScalars.startIndex].value
    // Swift.print ("\(Int (unicodeChar))")
    switch Int (unicodeChar) {
    case NSEvent.SpecialKey.upArrow.rawValue :
      moveSelection (byX : 0, byY: amount)
    case NSEvent.SpecialKey.downArrow.rawValue :
      moveSelection (byX : 0, byY: -amount)
    case NSEvent.SpecialKey.leftArrow.rawValue :
      moveSelection (byX : -amount, byY: 0)
    case NSEvent.SpecialKey.rightArrow.rawValue :
      moveSelection (byX : amount, byY: 0)
    case NSEvent.SpecialKey.deleteForward.rawValue, 127 /* Back */ :
      deleteSelection ()
    default :
      super.keyDown (with: event)
    }
  }

  //····················································································································
  //  Mouse down
  //····················································································································

  private var mMouseLocation : NSPoint?

  //····················································································································

  final override func mouseDown (with mouseDownEvent: NSEvent) {
    let mouseDownLocation = self.convert (mouseDownEvent.locationInWindow, from: nil)
    self.mMouseLocation = mouseDownLocation
    var possibleKnobIndex : Int? = nil
  //--- First check if mouse down occurs on a knob of a selected object
    for segment in self.mSegmentList.reversed () {
      if self.mSelection.contains (segment) {
        possibleKnobIndex = segment.knobIndexFor (point: mouseDownLocation)
        if possibleKnobIndex != nil {
          self.mSelection.removeAll ()
          self.mSelection.insert (segment)
//          Swift.print ("mouseDown on knob \(self.mSelection)")
          break
        }
      }
    }
    let shiftKeyOn = mouseDownEvent.modifierFlags.contains (.shift)
    let commandKeyOn = mouseDownEvent.modifierFlags.contains (.command)
  //--- Second, mouse down in segment ?
    var mouseDownInsideSegment = false
    if possibleKnobIndex == nil {
      for segment in self.mSegmentList.reversed () {
        if segment.contains (point: mouseDownLocation) {
          if shiftKeyOn {
            self.mSelection.insert (segment)
          }else if commandKeyOn {
            if self.mSelection.contains (segment) {
              self.mSelection.remove (segment)
            }else{
              self.mSelection.insert (segment)
            }
          }else if !self.mSelection.contains (segment) {
            self.mSelection.removeAll ()
            self.mSelection.insert (segment)
//            Swift.print ("mouseDown on segment \(self.mSelection)")
          }
          mouseDownInsideSegment = true
          break // Exit from loop
        }
      }
      if !mouseDownInsideSegment && !shiftKeyOn {
        self.mSelection.removeAll ()
      }
    }
  //--- Handle mouse dragged and mouse up
    if let knobIndex = possibleKnobIndex {
      self.waitUntilMouseUpOnMouseDownAt (mouseDownLocation: mouseDownLocation, for: knobIndex)
    }else if mouseDownInsideSegment {
      self.waitUntilMouseUpOnMouseDownOnSegment (mouseDownLocation: mouseDownLocation)
    }else if shiftKeyOn {
      self.waitUntilMouseUpOnDraggingSelectionRectangleWithShiftKey (mouseDownLocation: mouseDownLocation)
    }else{
      self.waitUntilMouseUpOnDraggingSelectionRectangleNoShiftKey (mouseDownLocation: mouseDownLocation)
    }
  //--- Mouse up
    self.mMouseLocation = nil
    self.mSelectionRectangle = nil
    self.needsDisplay = true
  }

  //····················································································································

  private final func waitUntilMouseUpOnMouseDownOnSegment (mouseDownLocation : NSPoint) {
//    Swift.print ("waitUntilMouseUpOnMouseDownOnSegment \(self.mSelection)")
    var mouseLocation = mouseDownLocation
    var loop = true
    while loop {
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from: nil)
        let dx = Int ((mouseDraggedLocation.x - mouseLocation.x) / PLACEMENT_GRID)
        let dy = Int ((mouseDraggedLocation.y - mouseLocation.y) / PLACEMENT_GRID)
//        Swift.print ("dx \(dx), dy \(dy)")
        if (dx != 0) || (dy != 0), self.canMoveSelection (byX : dx, byY : dy) {
          mouseLocation.x += CGFloat (dx) * PLACEMENT_GRID
          mouseLocation.y += CGFloat (dy) * PLACEMENT_GRID
          self.moveSelection (byX : dx, byY : dy)
        }
        self.mMouseLocation = mouseLocation
      }
    }
  }

  //····················································································································

  private final func waitUntilMouseUpOnMouseDownAt (mouseDownLocation : NSPoint, for knob : Int) {
    var mouseLocation = mouseDownLocation
    var loop = true
    while loop {
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        let dx = Int ((mouseDraggedLocation.x - mouseLocation.x) / PLACEMENT_GRID)
        let dy = Int ((mouseDraggedLocation.y - mouseLocation.y) / PLACEMENT_GRID)
        if (dx != 0) || (dy != 0), self.canMoveSelectionFrom (knob: knob, byX: dx, byY: dy) {
          mouseLocation.x += CGFloat (dx) * PLACEMENT_GRID
          mouseLocation.y += CGFloat (dy) * PLACEMENT_GRID
          moveSelectionFrom (knob: knob, byX : dx, byY : dy)
        }
        self.mMouseLocation = mouseLocation
      }
    }
  }

  //····················································································································

  private final func waitUntilMouseUpOnDraggingSelectionRectangleNoShiftKey (mouseDownLocation : NSPoint) {
    var loop = true
    while loop {
      self.display ()
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        self.mSelection.removeAll ()
        let r = NSRect (point: mouseDownLocation, point: mouseDraggedLocation)
        self.mSelectionRectangle = r
        let cr = GeometricRect (rect: r)
        for segment in self.mSegmentList {
          if segment.intersects (rect: cr) {
            self.mSelection.insert (segment)
          }
        }
      }
    }
  }

  //····················································································································

  private final func waitUntilMouseUpOnDraggingSelectionRectangleWithShiftKey (mouseDownLocation : NSPoint) {
    let selectionOnMouseDown = self.mSelection
    var loop = true
    while loop {
      self.display ()
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged
      if loop {
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        let r = NSRect (point: mouseDownLocation, point: mouseDraggedLocation)
        self.mSelectionRectangle = r
        let cr = GeometricRect (rect: r)
        var selection = Set <FontCharacterSegment> ()
        for segment in self.mSegmentList {
          if segment.intersects (rect: cr) {
            selection.insert (segment)
          }
        }
        self.mSelection = selection.symmetricDifference (selectionOnMouseDown)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION FontCharacterSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension FontCharacterSegment {

  //····················································································································

  func knobIndexFor (point p : NSPoint) -> Int? { // Return nil if point is outside a knob
    var result : Int? = nil
    do{
      let r = knobRect (self.x1, self.y1)
      if r.contains (p) {
        result = 0
      }
    }
    if result == nil {
      let r = knobRect (self.x2, self.y2)
      if r.contains (p) {
        result = 1
      }
    }
    return result
  }

  //····················································································································

  func contains (point p : NSPoint) -> Bool {
    let oblong = GeometricOblong (
      p1: NSPoint (x: xForX (self.x1), y: yForY (self.y1)),
      p2: NSPoint (x: xForX (self.x2), y: yForY (self.y2)),
      width: PLACEMENT_GRID * 2.0
    )
    return oblong.contains (point: p)
  }

  //····················································································································

  func intersects (rect r : GeometricRect) -> Bool {
    let oblong = GeometricOblong (
      p1: NSPoint (x: xForX (self.x1), y: yForY (self.y1)),
      p2: NSPoint (x: xForX (self.x2), y: yForY (self.y2)),
      width: PLACEMENT_GRID * 2.0
    )
    return oblong.intersects (rect: r)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
