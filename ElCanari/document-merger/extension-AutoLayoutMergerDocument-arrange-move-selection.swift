//
//  ElCanari
//
//  Created by Pierre Molinaro on 03/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MOVE
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutMergerDocument {

  //····················································································································

  func moveDown (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardHeight = self.rootObject.boardHeight!
    let boardLimitWidth = self.rootObject.boardLimitWidth
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //---
    var deltaY = -boardHeight
    for selectedInstance in inMoveObjectSet.values {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: boardLimitWidth - instanceLimit,
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

  //····················································································································

  func moveUp (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardHeight = self.rootObject.boardHeight!
//    let boardLimitWidth = self.rootObject.boardLimitWidth
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //---
    var deltaY = boardHeight
    for selectedInstance in inMoveObjectSet.values {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: instanceRect.bottom,
        width: instanceRect.width,
        height: boardHeight + instanceLimit - instanceRect.bottom
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
// §        deltaY = min (deltaY, acceptableNewRect.height)
        deltaY = min (deltaY, acceptableNewRect.top - instanceRect.top)
      }
    }
    if deltaY > 0 {
      for selectedInstance in inMoveObjectSet.values {
        selectedInstance.y += deltaY
      }
    }
  }

  //····················································································································

  func moveRight (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardWidth = self.rootObject.boardWidth!
//    let boardLimitWidth = self.rootObject.boardLimitWidth
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //---
    var deltaX = boardWidth
    for selectedInstance in inMoveObjectSet.values {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: instanceRect.left,
        bottom: instanceRect.bottom,
        width: boardWidth + instanceLimit - instanceRect.left,
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

  //····················································································································

  func moveLeft (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let boardWidth = self.rootObject.boardWidth!
    let boardLimitWidth = self.rootObject.boardLimitWidth
  //--- Non selected set
    let otherObjectSet = EBReferenceSet (self.rootObject.boardInstances_property.propval.values).subtracting (inMoveObjectSet)
  //---
   var deltaX = -boardWidth
 //   var deltaX = boardLimitWidth / 2 - boardWidth
    for selectedInstance in inMoveObjectSet.values {
      let instanceRect = selectedInstance.instanceRect!
      let instanceLimit = selectedInstance.boardLimitWidth!
      var acceptableNewRect = CanariRect (
        left: boardLimitWidth - instanceLimit,
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

  //····················································································································

  func stackDown (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let sortedArray = inMoveObjectSet.values.sorted (by: { return $0.y < $1.y })
    for object in sortedArray {
      moveDown (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  //····················································································································

  func stackLeft (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let sortedArray = inMoveObjectSet.values.sorted (by: { return $0.x < $1.x })
    for object in sortedArray {
      moveLeft (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  //····················································································································

  func stackUp (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let sortedArray = inMoveObjectSet.values.sorted (by: { return $0.y > $1.y })
    for object in sortedArray {
      moveUp (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  //····················································································································

  func stackRight (overlap inOverlap : Bool, objectSet inMoveObjectSet : EBReferenceSet <MergerBoardInstance>) {
    let sortedArray = inMoveObjectSet.values.sorted (by: { return $0.x > $1.x })
    for object in sortedArray {
      moveRight (overlap: inOverlap, objectSet: EBReferenceSet (object))
    }
  }

  //····················································································································

}

////——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
////   ARRANGE WITHOUT OVERLAPPING
////——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//extension MergerDocument {
//
//  //····················································································································
//
//  func arrangeVerticallyNoOverlap () {
//    let boards = self.rootObject.boardInstances_property.propval
//    let sortedBoards = boards.sorted (by: { $0.y < $1.y })
//    var idx = 0
//    while idx < sortedBoards.count {
//      let board = sortedBoards [idx]
//      var newY = 0
//      let boardRect = getInstanceRect (board)
//      let leftRect = CanariRect (left:board.x, bottom:0, width:boardRect.left, height:board.y)
//      var idy = idx + 1
//      while idy < sortedBoards.count {
//        let testedBoard = sortedBoards [idy]
//        let testedBoardRect = getInstanceRect (testedBoard)
//        let intersection = leftRect.intersection (testedBoardRect)
//        if !intersection.isEmpty {
//          newY = max (newY, intersection.top)
//        }
//        idy += 1
//      }
//      board.y = newY
//      idx += 1
//    }
//  //--- For boards that intersect, push them up
//    idx = 0
//    while idx < sortedBoards.count {
//      let board = sortedBoards [idx]
//      let boardRect = getInstanceRect (board)
//      var idy = idx + 1
//      while idy < sortedBoards.count {
//        let testedBoard = sortedBoards [idy]
//        let testedBoardRect = getInstanceRect (testedBoard)
//        let intersection = boardRect.intersection (testedBoardRect)
//        if !intersection.isEmpty {
//          pushBoardUp (sortedBoards, boardRect, idy, boardRect.top)
//        }
//        idy += 1
//      }
//      idx += 1
//    }
//  }
//
//  //····················································································································
//
//  func arrangeHorizontally () {
//  //--- Push boards on left
//    let boards = self.rootObject.boardInstances_property.propval
//    let sortedBoards = boards.sorted (by: { $0.x < $1.x })
//    var idx = 0
//    while idx < sortedBoards.count {
//      let board = sortedBoards [idx]
//      var newX = 0
//      let boardRect = getInstanceRect (board)
//      let leftRect = CanariRect (left:0, bottom:board.y, width:board.x, height:boardRect.height)
//      var idy = idx + 1
//      while idy < sortedBoards.count {
//        let testedBoard = sortedBoards [idy]
//        let testedBoardRect = getInstanceRect (testedBoard)
//        let intersection = leftRect.intersection (testedBoardRect)
//        if !intersection.isEmpty {
//          newX = max (newX, intersection.right)
//        }
//        idy += 1
//      }
//      board.x = newX
//      idx += 1
//    }
//  //--- For boards that intersect, push them on right
//    idx = 0
//    while idx < sortedBoards.count {
//      let board = sortedBoards [idx]
//      let boardRect = getInstanceRect (board)
//      var idy = idx + 1
//      while idy < sortedBoards.count {
//        let testedBoard = sortedBoards [idy]
//        let testedBoardRect = getInstanceRect (testedBoard)
//        let intersection = boardRect.intersection (testedBoardRect)
//        if !intersection.isEmpty {
//          pushBoardRight (sortedBoards, boardRect, idy, boardRect.right)
//        }
//        idy += 1
//      }
//      idx += 1
//    }
//  }
//
//  //····················································································································
//
//  fileprivate func pushBoardRight (_ sortedBoards : [MergerBoardInstance],
//                                   _ inBoardRect : CanariRect,
//                                   _ inIndex : Int,
//                                   _ inNewX : Int) {
//  //--- Push other boards ?
//    var idy = inIndex + 1
//    while idy < sortedBoards.count {
//      let testedBoard = sortedBoards [idy]
//      let testedBoardRect = getInstanceRect (testedBoard)
//      let intersection = inBoardRect.intersection (testedBoardRect)
//      if !intersection.isEmpty {
//        pushBoardRight (sortedBoards, testedBoardRect, idy, inBoardRect.right)
//      }
//      idy += 1
//    }
//  //--- Set new X
//    sortedBoards [inIndex].x = inNewX
//  }
//
//  //····················································································································
//
//  fileprivate func pushBoardUp (_ sortedBoards : [MergerBoardInstance],
//                                _ inBoardRect : CanariRect,
//                                _ inIndex : Int,
//                                _ inNewY : Int) {
//  //--- Push other boards ?
//    var idy = inIndex + 1
//    while idy < sortedBoards.count {
//      let testedBoard = sortedBoards [idy]
//      let testedBoardRect = getInstanceRect (testedBoard)
//      let intersection = inBoardRect.intersection (testedBoardRect)
//      if !intersection.isEmpty {
//        pushBoardUp (sortedBoards, testedBoardRect, idy, inBoardRect.top)
//      }
//      idy += 1
//    }
//  //--- Set new Y
//    sortedBoards [inIndex].y = inNewY
//  }
//
//  //····················································································································
//
//}
//
////——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
////   ARRANGE WITH OVERLAPPING
////——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//extension MergerDocument {
//
//  //····················································································································
//
//  func arrangeVerticallyWithOverlap () {
//    let boards = self.rootObject.boardInstances_property.propval
//    let sortedBoards = boards.sorted (by: { $0.y < $1.y })
//    for board in sortedBoards {
//      var newY = 0
//      let boardRect = getInstanceRect (board)
//      let boardLimit = getInstanceLimit (board)
//      let leftRect = CanariRect (left:board.x, bottom:0, width:boardRect.left, height:board.y)
//      for testedBoard in boards {
//        if testedBoard !== board {
//          let testedBoardLimit = getInstanceLimit (testedBoard)
//          let inset = min (boardLimit, testedBoardLimit)
//          let testedBoardRect = getInstanceRect (testedBoard).insetBy (dx:inset, dy: inset)
//          let intersection = leftRect.intersection (testedBoardRect)
//          if !intersection.isEmpty {
//            newY = max (newY, intersection.top - inset)
//          }
//        }
//      }
//      board.y = newY
//    }
//  //--- For boards that intersect, push them up
//    var idx = 0
//    while idx < sortedBoards.count {
//      let board = sortedBoards [idx]
//      let boardRect = getInstanceRect (board)
//      let boardLimit = getInstanceLimit (board)
//      var idy = idx + 1
//      while idy < sortedBoards.count {
//        let testedBoard = sortedBoards [idy]
//        let testedBoardLimit = getInstanceLimit (testedBoard)
//        let inset = min (boardLimit, testedBoardLimit)
//        let testedBoardRect = getInstanceRect (testedBoard).insetBy (dx:inset, dy: inset)
//        let intersection = boardRect.intersection (testedBoardRect)
//        if !intersection.isEmpty {
//          let newY = boardRect.top - inset
//          pushBoardUpWithOverlap (sortedBoards, boardRect, boardLimit, idy, newY)
//        }
//        idy += 1
//      }
//      idx += 1
//    }
//  }
//
//  //····················································································································
//
//  fileprivate func pushBoardUpWithOverlap (_ sortedBoards : [MergerBoardInstance],
//                                           _ inBoardRect : CanariRect,
//                                           _ inBoardLimit : Int,
//                                           _ inIndex : Int,
//                                           _ inNewY : Int) {
//  //--- Push other boards ?
//    var idy = inIndex + 1
//    while idy < sortedBoards.count {
//      let testedBoard = sortedBoards [idy]
//      let testedBoardLimit = getInstanceLimit (testedBoard)
//      let inset = min (inBoardLimit, testedBoardLimit)
//      let testedBoardRect = getInstanceRect (testedBoard).insetBy (dx:inset, dy: inset)
//      let intersection = inBoardRect.intersection (testedBoardRect)
//      if !intersection.isEmpty {
//        let newY = inBoardRect.top - inset
//        pushBoardUpWithOverlap (sortedBoards, testedBoardRect, testedBoardLimit, idy, newY)
//      }
//      idy += 1
//    }
//  //--- Set new X
//    sortedBoards [inIndex].y = inNewY
//  }
//
//  //····················································································································
//
//  func arrangeHorizontallyWithOverlap () {
//  //--- Push boards on left
//    let boards = self.rootObject.boardInstances_property.propval
//    let sortedBoards = boards.sorted (by: { $0.x < $1.x })
//    for board in sortedBoards {
//      var newX = 0
//      let boardRect = getInstanceRect (board)
//      let boardLimit = getInstanceLimit (board)
//      let leftRect = CanariRect (left:0, bottom:board.y, width:board.x, height:boardRect.height)
//      for testedBoard in boards {
//        if testedBoard !== board {
//          let testedBoardLimit = getInstanceLimit (testedBoard)
//          let inset = min (boardLimit, testedBoardLimit)
//          let testedBoardRect = getInstanceRect (testedBoard).insetBy (dx:inset, dy: inset)
//          let intersection = leftRect.intersection (testedBoardRect)
//          if !intersection.isEmpty {
//            newX = max (newX, intersection.right - inset)
//          }
//        }
//      }
//      board.x = newX
//    }
//  //--- For boards that intersect, push them on right
//    var idx = 0
//    while idx < sortedBoards.count {
//      let board = sortedBoards [idx]
//      let boardLimit = getInstanceLimit (board)
//      let boardRect = getInstanceRect (board)
//      var idy = idx + 1
//      while idy < sortedBoards.count {
//        let testedBoard = sortedBoards [idy]
//        let testedBoardLimit = getInstanceLimit (testedBoard)
//        let inset = min (boardLimit, testedBoardLimit)
//        let testedBoardRect = getInstanceRect (testedBoard).insetBy (dx:inset, dy: inset)
//        let intersection = boardRect.intersection (testedBoardRect)
//        if !intersection.isEmpty {
//          let newX = boardRect.right - inset
//          pushBoardRightWithOverlap (sortedBoards, boardRect, testedBoardLimit, idy, newX)
//        }
//        idy += 1
//      }
//      idx += 1
//    }
//  }
//
//  //····················································································································
//
//  fileprivate func pushBoardRightWithOverlap (_ sortedBoards : [MergerBoardInstance],
//                                              _ inBoardRect : CanariRect,
//                                              _ inBoardLimit : Int,
//                                              _ inIndex : Int,
//                                              _ inNewX : Int) {
//  //--- Push other boards ?
//    var idy = inIndex + 1
//    while idy < sortedBoards.count {
//      let testedBoard = sortedBoards [idy]
//      let testedBoardLimit = getInstanceLimit (testedBoard)
//      let inset = min (inBoardLimit, testedBoardLimit)
//      let testedBoardRect = getInstanceRect (testedBoard).insetBy (dx:inset, dy: inset)
//      let intersection = inBoardRect.intersection (testedBoardRect)
//      if !intersection.isEmpty {
//        let newX = inBoardRect.right - inset
//        pushBoardRightWithOverlap (sortedBoards, testedBoardRect, testedBoardLimit, idy, newX)
//      }
//      idy += 1
//    }
//  //--- Set new X
//    sortedBoards [inIndex].x = inNewX
//  }
//
//  //····················································································································
//
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
