//
//  CharacterGerberCode.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum CharacterGerberCodeElement : Hashable {
  case moveTo (x : Int, y : Int)
  case lineTo (x : Int, y : Int)
  
  func codeString () -> String {
    switch self {
    case .moveTo (let x, let y) : return "X\(x)Y\(y)D02"
    case .lineTo (let x, let y) : return "X\(x)Y\(y)D01"
    }
  }
  
  func comment () -> String {
    switch self {
    case .moveTo (let x, let y) : return "Move to (\(x), \(y))"
    case .lineTo (let x, let y) : return "Line to (\(x), \(y))"
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CharacterGerberCode : Hashable {
  let code : [CharacterGerberCodeElement]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
