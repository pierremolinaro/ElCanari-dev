//
//  magnetization.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/07/2018.
//
//
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PMMergerDocument {

  //····················································································································

  func arrangeVerticaly () {
    let boards = self.rootObject.boardInstances_property.propval
    let sortedBoards = boards.sorted (by: { $0.y < $1.y })
    for board in sortedBoards {
      var newY = 0
      switch board.instanceRect {
      case .single (let boardRect) :
        let leftRect = CanariBoardRect (x:board.x, y:0, width:boardRect.x, height:board.y)
        for testedBoard in boards {
          if testedBoard !== board {
            switch testedBoard.instanceRect {
            case .single (let r) :
              let intersection = leftRect.intersection (r)
              if !intersection.isEmpty () {
                newY = max (newY, intersection.y + intersection.height)
              }
            default :
              break
            }
          }
        }
      default :
        break
      }
      board.y = newY
    }
  //--- For boards that intersect, push them up
    var idx = 0
    while idx < sortedBoards.count {
      let board = sortedBoards [idx]
      switch board.instanceRect {
      case .single (let boardRect) :
        var idy = idx + 1
        while idy < sortedBoards.count {
          let testedBoard = sortedBoards [idy]
          switch testedBoard.instanceRect {
          case .single (let testedBoardRect) :
            let intersection = boardRect.intersection (testedBoardRect)
            if !intersection.isEmpty () {
              pushBoardUp (sortedBoards, boardRect, idy, boardRect.y + boardRect.height)
            }
          default :
            break
          }
          idy += 1
        }
      default :
        break
      }
      idx += 1
    }
  }

  //····················································································································

  func arrangeHorizontally () {
  //--- Push boards on left
    let boards = self.rootObject.boardInstances_property.propval
    let sortedBoards = boards.sorted (by: { $0.x < $1.x })
    for board in sortedBoards {
      var newX = 0
      switch board.instanceRect {
      case .single (let boardRect) :
        let leftRect = CanariBoardRect (x:0, y:board.y, width:board.x, height:boardRect.height)
        for testedBoard in boards {
          if testedBoard !== board {
            switch testedBoard.instanceRect {
            case .single (let r) :
              let intersection = leftRect.intersection (r)
              if !intersection.isEmpty () {
                newX = max (newX, intersection.x + intersection.width)
              }
            default :
              break
            }
          }
        }
      default :
        break
      }
      board.x = newX
    }
  //--- For boards that intersect, push them on right
    var idx = 0
    while idx < sortedBoards.count {
      let board = sortedBoards [idx]
      switch board.instanceRect {
      case .single (let boardRect) :
        var idy = idx + 1
        while idy < sortedBoards.count {
          let testedBoard = sortedBoards [idy]
          switch testedBoard.instanceRect {
          case .single (let testedBoardRect) :
            let intersection = boardRect.intersection (testedBoardRect)
            if !intersection.isEmpty () {
              pushBoardRight (sortedBoards, boardRect, idy, boardRect.x + boardRect.width)
            }
          default :
            break
          }
          idy += 1
        }
      default :
        break
      }
      idx += 1
    }
  }

  //····················································································································

  func pushBoardRight (_ sortedBoards : [MergerBoardInstanceEntity],
                       _ inBoardRect : CanariBoardRect,
                       _ inIndex : Int,
                       _ inNewX : Int) {
  //--- Push other boards ?
    var idy = inIndex + 1
    while idy < sortedBoards.count {
      let testedBoard = sortedBoards [idy]
      switch testedBoard.instanceRect {
      case .single (let testedBoardRect) :
        let intersection = inBoardRect.intersection (testedBoardRect)
        if !intersection.isEmpty () {
          pushBoardRight (sortedBoards, testedBoardRect, idy, inBoardRect.x + inBoardRect.width)
        }
      default :
        break
      }
      idy += 1
    }
  //--- Set new X
    sortedBoards [inIndex].x = inNewX
  }

  //····················································································································

  func pushBoardUp (_ sortedBoards : [MergerBoardInstanceEntity],
                    _ inBoardRect : CanariBoardRect,
                    _ inIndex : Int,
                    _ inNewY : Int) {
  //--- Push other boards ?
    var idy = inIndex + 1
    while idy < sortedBoards.count {
      let testedBoard = sortedBoards [idy]
      switch testedBoard.instanceRect {
      case .single (let testedBoardRect) :
        let intersection = inBoardRect.intersection (testedBoardRect)
        if !intersection.isEmpty () {
          pushBoardUp (sortedBoards, testedBoardRect, idy, inBoardRect.y + inBoardRect.height)
        }
      default :
        break
      }
      idy += 1
    }
  //--- Set new X
    sortedBoards [inIndex].y = inNewY
  }

  //····················································································································

}

//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
