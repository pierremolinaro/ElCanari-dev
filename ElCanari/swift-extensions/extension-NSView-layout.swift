//
//  extension-NSView-layout.swift
//  essai-contraintes
//
//  Created by Pierre Molinaro on 16/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSView {

  //····················································································································

  func layout (_ inViewAttribute : NSLayoutConstraint.Attribute,
               _ inRelation : NSLayoutConstraint.Relation,
               superview inSuperviewAttribute : NSLayoutConstraint.Attribute,
               plus inDistance : CGFloat = 0.0) {
    if let superview = self.superview {
      let c = NSLayoutConstraint (
        item: self,
        attribute: inViewAttribute,
        relatedBy: inRelation,
        toItem: superview,
        attribute: inSuperviewAttribute,
        multiplier: 1.0,
        constant: inDistance
      )
      superview.addConstraint (c)
    }
  }

  //····················································································································

  func layout (_ inViewAttribute : NSLayoutConstraint.Attribute,
               _ inRelation : NSLayoutConstraint.Relation,
               to inOtherView : NSView,
               _ inOtherAttribute : NSLayoutConstraint.Attribute,
               plus inDistance : CGFloat = 0.0,
               priority inPrority : Int = 1000) {
    let c = NSLayoutConstraint (
      item: self,
      attribute: inViewAttribute,
      relatedBy: inRelation,
      toItem: inOtherView,
      attribute: inOtherAttribute,
      multiplier: 1.0,
      constant: inDistance
    )
    c.priority = NSLayoutConstraint.Priority (rawValue: Float (inPrority))
    self.superview?.addConstraint (c)
  }

  //····················································································································

  func layout (_ inViewAttribute : NSLayoutConstraint.Attribute,
               _ inRelation : NSLayoutConstraint.Relation,
               _ inDistance : CGFloat) {
    let c = NSLayoutConstraint (
      item: self,
      attribute: inViewAttribute,
      relatedBy: inRelation,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 0.0,
      constant: inDistance
    )
    self.addConstraint (c)
  }

  //····················································································································

  func displayConstraints (_ inDisplayDictionary : [ObjectIdentifier : String]) {
    let name = self.objectString (self, inDisplayDictionary)
    Swift.print ("--- \(name) constraints \(self.hasAmbiguousLayout ? "(ambiguous)" : "(ok)")")
    for c in self.constraints {
      displayConstraint (c, inDisplayDictionary)
    }
  }

  //····················································································································

  private func displayConstraint (_ inConstraint : NSLayoutConstraint, _ inDisplayDictionary : [ObjectIdentifier : String]) {
    var s = "  " + objectString (inConstraint.firstItem!, inDisplayDictionary)
    s += inConstraint.firstAttribute.string
    switch inConstraint.relation {
    case .lessThanOrEqual:
      s += " <="
    case .equal:
      s += " =="
    case .greaterThanOrEqual:
      s += " >="
    @unknown default:
      s += " ?=?"
    }
    if let secondItem = inConstraint.secondItem {
      s += " " + self.objectString (secondItem, inDisplayDictionary)
      s += inConstraint.secondAttribute.string
      if inConstraint.multiplier != 1.0 {
        s += " * \(inConstraint.multiplier)"
      }
    }
    if inConstraint.constant > 0.0 {
      s += " + \(inConstraint.constant)"
    }else if inConstraint.constant < 0.0 {
      s += " - \(-inConstraint.constant)"
    }
//    s += ", Anchors: " + self.objectString (inConstraint.firstAnchor, inDisplayDictionary)
//    s += ", " + self.objectString (inConstraint.secondAnchor, inDisplayDictionary)
    Swift.print (s)
  }

  //····················································································································

  private func objectString (_ inPossibleObject : AnyObject?, _ inDisplayDictionary : [ObjectIdentifier : String]) -> String {
    if let object = inPossibleObject {
      if let displayName = inDisplayDictionary [ObjectIdentifier (object)] {
        return displayName
      }else{
        return "Ox" + String (UInt (bitPattern: ObjectIdentifier (object).hashValue), radix: 16)
      }
    }else{
      return "nil"
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSLayoutConstraint.Attribute {

  //····················································································································

  var string : String {
    switch self {
    case .left:
      return ".left"
    case .right:
      return ".right"
    case .top:
      return ".top"
    case .bottom:
      return ".bottom"
    case .leading:
      return ".leading"
    case .trailing:
      return ".trailing"
    case .width:
      return ".width"
    case .height:
      return ".height"
    case .centerX:
      return ".centerX"
    case .centerY:
      return ".centerY"
    case .lastBaseline:
      return ".lastBaseline"
    case .firstBaseline:
      return ".firstBaseline"
    case .notAnAttribute:
      return ".notAnAttribute"
    @unknown default:
      return ".unknown"
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

