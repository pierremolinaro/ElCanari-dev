//
//  PMLayoutCompressionConstraintPriority.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  NSLayoutConstraint.priority
//   required:                  1000.0
//   defaultHigh:                750.0
//   dragThatCanResizeWindow:    510.0
//   windowSizeStayPut:          500.0
//   dragThatCannotResizeWindow: 490.0
//   defaultLow:                 250.0
//   fittingSizeCompression:      50.0
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
// Quand on instancie une NSView ou une héritière, la méthode pmConfigureForAutolayout doit être appelée :
//   - elle fixe translatesAutoresizingMaskIntoConstraints à false
//   - fixe la résistance à la compression à la valeur la plus forte (1000.0)
//   - fixe la résistance à l'étirement à la valeur la plus faible (1.0)
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum PMLayoutCompressionConstraintPriority : Comparable {

  //--------------------------------------------------------------------------------------------------------------------

  case lowest
  case lower
  case low
  case cannotResizeWindow
  case canResizeWindow
  case high
  case higher
  case highest

  //--------------------------------------------------------------------------------------------------------------------

  var cocoaPriority : NSLayoutConstraint.Priority {
    switch self {
    case .lowest : NSLayoutConstraint.Priority (100.0)
    case .lower : .defaultLow // 250.0
    case .low : NSLayoutConstraint.Priority (400.0)
    case .cannotResizeWindow : .dragThatCannotResizeWindow // 490.0
    case .canResizeWindow : .dragThatCanResizeWindow // 510.0
    case .high : NSLayoutConstraint.Priority (600.0)
    case .higher : .defaultHigh // 750.0
    case .highest : NSLayoutConstraint.Priority (900.0)
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum PMLayoutStrechingConstraintPriority : Comparable {

  //--------------------------------------------------------------------------------------------------------------------

  case lowest
  case lower
  case low
  case cannotResizeWindow
  case canResizeWindow
  case high
  case higher
  case highest

  //--------------------------------------------------------------------------------------------------------------------

  var cocoaPriority : NSLayoutConstraint.Priority {
    switch self {
    case .lowest : NSLayoutConstraint.Priority (99.0)
    case .lower : NSLayoutConstraint.Priority (249.0)
    case .low : NSLayoutConstraint.Priority (399.0)
    case .cannotResizeWindow : NSLayoutConstraint.Priority (489.0)
    case .canResizeWindow : NSLayoutConstraint.Priority (509.0)
    case .high : NSLayoutConstraint.Priority (599.0)
    case .higher : NSLayoutConstraint.Priority (749.0)
    case .highest : NSLayoutConstraint.Priority (899.0)
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
