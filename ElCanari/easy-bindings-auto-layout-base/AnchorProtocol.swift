//
//  AnchorProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol AnchorProtocol : AnyObject {

  var leftAnchor : NSLayoutXAxisAnchor { get }

  var rightAnchor : NSLayoutXAxisAnchor { get }

  var topAnchor : NSLayoutYAxisAnchor { get }

  var bottomAnchor : NSLayoutYAxisAnchor { get }

  var widthAnchor : NSLayoutDimension { get }

  var heightAnchor : NSLayoutDimension { get }

  var centerXAnchor : NSLayoutXAxisAnchor { get }

  var centerYAnchor : NSLayoutYAxisAnchor { get }

}

//--------------------------------------------------------------------------------------------------

extension NSView : AnchorProtocol {}

extension NSLayoutGuide : AnchorProtocol {}

//--------------------------------------------------------------------------------------------------
