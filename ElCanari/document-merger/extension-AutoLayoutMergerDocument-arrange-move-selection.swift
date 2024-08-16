//
//  ElCanari
//
//  Created by Pierre Molinaro on 03/07/2018.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   MOVE
//--------------------------------------------------------------------------------------------------

extension AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveDown (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardHeight = self.rootObject.boardHeight!
    let boardLimitWidth = self.rootObject.boardLimitWidth
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let ySortedArray = inMoveObjectSet.values.sorted { $0.y < $1.y }
  //---
    var deltaY = -boardHeight
    for selectedInstance in ySortedArray {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: max (boardLimitWidth - instanceLimit, 0),
        width: instanceRect.width,
        height: instanceRect.bottom
      )
      for otherInstance in otherObjectSet.values {
        let inset = inOverlap ? min (instanceLimit, otherInstance.boardLimitWidth!) : 0
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dx: inset, dy: inset))
        if !intersection.isEmpty {
          acceptableNewRect = CanariRect (
            left: instanceRect.left,
            bottom: intersection.top,
            width: instanceRect.width,
            height: instanceRect.bottom - intersection.top
          )
        }
      }
      if acceptableNewRect.isEmpty {
        deltaY = 0
      }else{
        deltaY = max (deltaY, acceptableNewRect.bottom - instanceRect.bottom)
      }
    }
    if deltaY < 0 {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.y += deltaY
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveUp (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardHeight = self.rootObject.boardHeight!
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let ySortedArray = inMoveObjectSet.values.sorted { $0.y > $1.y }
  //---
    var deltaY = boardHeight
    for selectedInstance in ySortedArray {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: instanceRect.bottom,
        width: instanceRect.width,
        height: boardHeight - instanceRect.bottom
      )
      for otherInstance in otherObjectSet.values {
        let inset = inOverlap ? min (instanceLimit, otherInstance.boardLimitWidth!) : 0
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dx: inset, dy: inset))
        if !intersection.isEmpty {
          acceptableNewRect = CanariRect (
            left: acceptableNewRect.left,
            bottom: acceptableNewRect.bottom,
            width: acceptableNewRect.width,
            height: intersection.bottom - acceptableNewRect.bottom
          )
        }
      }
      if acceptableNewRect.isEmpty {
        deltaY = 0
      }else{
        deltaY = min (deltaY, acceptableNewRect.top - instanceRect.top)
      }
    }
    if deltaY > 0 {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.y += deltaY
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveRight (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardWidth = self.rootObject.boardWidth!
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let xSortedArray = inMoveObjectSet.values.sorted { $0.x > $1.x }
  //---
    var deltaX = boardWidth
    for selectedInstance in xSortedArray {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: instanceRect.bottom,
        width: boardWidth - instanceRect.left,
        height: instanceRect.height
      )
      for otherInstance in otherObjectSet.values {
        let inset = inOverlap ? min (instanceLimit, otherInstance.boardLimitWidth!) : 0
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dx: inset, dy: inset))
        if !intersection.isEmpty {
          acceptableNewRect = CanariRect (
            left: acceptableNewRect.left,
            bottom: acceptableNewRect.bottom,
            width: intersection.left - acceptableNewRect.left,
            height: acceptableNewRect.height
          )
        }
      }
      if acceptableNewRect.isEmpty {
        deltaX = 0
      }else{
        deltaX = min (deltaX, acceptableNewRect.right - instanceRect.right)
      }
    }
    if deltaX > 0 {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.x += deltaX
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveLeft (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardWidth = self.rootObject.boardWidth!
    let boardLimitWidth = self.rootObject.boardLimitWidth
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let xSortedArray = inMoveObjectSet.values.sorted { $0.x < $1.x }
  //---
    var deltaX = -boardWidth
    for selectedInstance in xSortedArray {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: max (boardLimitWidth - instanceLimit, 0),
        bottom: instanceRect.bottom,
        width: instanceRect.left,
        height: instanceRect.height
      )
      for otherInstance in otherObjectSet.values {
        let inset = inOverlap ? min (instanceLimit, otherInstance.boardLimitWidth!) : 0
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dx:inset, dy: inset))
        if !intersection.isEmpty {
          acceptableNewRect = CanariRect (
            left: intersection.right,
            bottom: instanceRect.bottom,
            width: instanceRect.left - intersection.right,
            height: instanceRect.height
          )
        }
      }
      if acceptableNewRect.isEmpty {
        deltaX = 0
      }else{
        deltaX = max (deltaX, acceptableNewRect.left - instanceRect.left)
      }
    }
    if deltaX < 0 {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.x += deltaX
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackDown (overlap inOverlap : Bool, objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.y < $1.y }
    for object in sortedArray {
      moveDown (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackLeft (overlap inOverlap : Bool, objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.x < $1.x }
    for object in sortedArray {
      moveLeft (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackUp (overlap inOverlap : Bool, objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.y > $1.y }
    for object in sortedArray {
      moveUp (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackRight (overlap inOverlap : Bool, objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.x > $1.x }
    for object in sortedArray {
      moveRight (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func explodeSelection (objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let translation = self.rootObject.boardLimitWidth * (self.rootObject.overlapingArrangment ? 2 : 1)
    let xSortedArray = inObjectArray.values.sorted {
      ($0.x < $1.x) || (($0.x == $1.x) && ($0.y < $1.y))
    }
    var idx = 1
    for object in xSortedArray {
      object.x += idx * translation
      idx += 1
    }
    let ySortedArray = inObjectArray.values.sorted {
      ($0.y < $1.y) || (($0.y == $1.y) && ($0.x < $1.x))
    }
    idx = 1
    for object in ySortedArray {
      object.y += idx * translation
      idx += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
