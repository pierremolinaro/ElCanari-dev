//
//  ElCanari
//
//  Created by Pierre Molinaro on 03/07/2018.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//   MOVE
//--------------------------------------------------------------------------------------------------

extension AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveDown (objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardHeight = self.rootObject.boardHeight!
    let verticalSeparator = self.rootObject.verticalSeparator
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let ySortedArray = inMoveObjectSet.values.sorted { $0.y < $1.y }
  //---
    var deltaY = -boardHeight
    for selectedInstance in ySortedArray {
      let instanceRect = selectedInstance.instanceRect!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: .zero,
        width: instanceRect.width,
        height: instanceRect.bottom
      )
      for otherInstance in otherObjectSet.values {
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dy: -verticalSeparator))
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
        deltaY = .zero
      }else{
        deltaY = max (deltaY, acceptableNewRect.bottom - instanceRect.bottom)
      }
    }
    if deltaY < .zero {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.y += deltaY
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveUp (objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardHeight = self.rootObject.boardHeight!
    let verticalSeparator = self.rootObject.verticalSeparator
 //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let ySortedArray = inMoveObjectSet.values.sorted { $0.y > $1.y }
  //---
    var deltaY = boardHeight
    for selectedInstance in ySortedArray {
      let instanceRect = selectedInstance.instanceRect!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: instanceRect.bottom,
        width: instanceRect.width,
        height: boardHeight - instanceRect.bottom
      )
      for otherInstance in otherObjectSet.values {
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dy: -verticalSeparator))
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
        deltaY = .zero
      }else{
        deltaY = min (deltaY, acceptableNewRect.top - instanceRect.top)
      }
    }
    if deltaY.isPositive {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.y += deltaY
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveRight (objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardWidth = self.rootObject.boardWidth!
    let horizontalSeparator = self.rootObject.horizontalSeparator
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let xSortedArray = inMoveObjectSet.values.sorted { $0.x > $1.x }
  //---
    var deltaX = boardWidth
    for selectedInstance in xSortedArray {
      let instanceRect = selectedInstance.instanceRect!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: instanceRect.bottom,
        width: boardWidth - instanceRect.left,
        height: instanceRect.height
      )
      for otherInstance in otherObjectSet.values {
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dx: -horizontalSeparator))
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
        deltaX = .zero
      }else{
        deltaX = min (deltaX, acceptableNewRect.right - instanceRect.right)
      }
    }
    if deltaX.isPositive {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.x += deltaX
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func moveLeft (objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardWidth = self.rootObject.boardWidth!
    let horizontalSeparator = self.rootObject.horizontalSeparator
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //--- Sort objects
    let xSortedArray = inMoveObjectSet.values.sorted { $0.x < $1.x }
  //---
    var deltaX = -boardWidth
    for selectedInstance in xSortedArray {
      let instanceRect = selectedInstance.instanceRect!
      var acceptableNewRect = CanariRect (
        left: .zero,
        bottom: instanceRect.bottom,
        width: instanceRect.left,
        height: instanceRect.height
      )
      for otherInstance in otherObjectSet.values {
        let intersection = acceptableNewRect.intersection (otherInstance.instanceRect!.insetBy (dx: -horizontalSeparator))
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
        deltaX = .zero
      }else{
        deltaX = max (deltaX, acceptableNewRect.left - instanceRect.left)
      }
    }
    if deltaX < .zero {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.x += deltaX
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackDown (objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.y < $1.y }
    for object in sortedArray {
      moveDown (objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackLeft (objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.x < $1.x }
    for object in sortedArray {
      moveLeft (objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackUp (objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.y > $1.y }
    for object in sortedArray {
      moveUp (objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stackRight (objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let sortedArray = inObjectArray.values.sorted { $0.x > $1.x }
    for object in sortedArray {
      moveRight (objectSet: EBReferenceSet (object))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func explodeSelection (objectArray inObjectArray : EBReferenceArray <MergerBoardInstance>) {
    let hTranslation = self.rootObject.horizontalSeparator + .mm (1.0)
    let vTranslation = self.rootObject.verticalSeparator + .mm (1.0)
    let xSortedArray = inObjectArray.values.sorted {
      ($0.x < $1.x) || (($0.x == $1.x) && ($0.y < $1.y))
    }
    var idx = 1
    for object in xSortedArray {
      object.x += idx * hTranslation
      idx += 1
    }
    let ySortedArray = inObjectArray.values.sorted {
      ($0.y < $1.y) || (($0.y == $1.y) && ($0.x < $1.x))
    }
    idx = 1
    for object in ySortedArray {
      object.y += idx * vTranslation
      idx += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
