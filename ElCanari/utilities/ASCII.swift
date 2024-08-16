//
//  ASCII.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/09/2023.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

enum ASCII : UInt8 {
  case lineFeed = 0x0A

  case space = 0x20
  case exclamation = 0x21 // !
  case quotation = 0x22 // "
  case pound = 0x23 // #
  case dollar = 0x24 // $
  case perCent = 0x25 // %
  case ampersand = 0x26 // &
  case apostrophe = 0x27 // '
  case leftParenthesis = 0x28 // (
  case rightParenthesis = 0x29 // )
  case asterisk = 0x2A // *
  case plus = 0x2B // +
  case comma = 0x2C // ,
  case minus = 0x2D // -
  case period = 0x2E // ;
  case slash = 0x2F // /

  case zero = 0x30
  case one = 0x31
  case two = 0x32
  case three = 0x33
  case four = 0x34
  case five = 0x35
  case six = 0x36
  case seven = 0x37
  case eight = 0x38
  case nine = 0x39

  case colon = 0x3A // :
  case semicolon = 0x3B // ;
  case lessThan = 0x3C // <
  case equal = 0x3D // =
  case greaterThan = 0x3E // >
  case question = 0x3F // ?
  case at = 0x40 // @

  case A = 0x41
  case B = 0x42
  case C = 0x43
  case D = 0x44
  case E = 0x45
  case F = 0x46
  case G = 0x47
  case H = 0x48
  case I = 0x49
  case J = 0x4A
  case K = 0x4B
  case L = 0x4C
  case M = 0x4D
  case N = 0x4E
  case O = 0x4F
  case P = 0x50
  case Q = 0x51
  case R = 0x52
  case S = 0x53
  case T = 0x54
  case U = 0x55
  case V = 0x56
  case W = 0x57
  case X = 0x58
  case Y = 0x59
  case Z = 0x5A

  case leftBracket = 0x5B // [
  case baskSlah = 0x5E // \
  case rightBracket = 0x5F // ]
  case baskApostrophe = 0x60 // `

  case a = 0x61
  case b = 0x62
  case c = 0x63
  case d = 0x64
  case e = 0x65
  case f = 0x66
  case g = 0x67
  case h = 0x68
  case i = 0x69
  case j = 0x6A
  case k = 0x6B
  case l = 0x6C
  case m = 0x6D
  case n = 0x6E
  case o = 0x6F
  case p = 0x70
  case q = 0x71
  case r = 0x72
  case s = 0x73
  case t = 0x74
  case u = 0x75
  case v = 0x76
  case w = 0x77
  case x = 0x78
  case y = 0x79
  case z = 0x7A

  case leftBrace = 0x7B // {
  case verticalBar = 0x7C // |
  case rightBrace = 0x7D // }
  case tilde = 0x7E // ~
}

//--------------------------------------------------------------------------------------------------
