//
//  check-el-canari-file-path.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/07/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

func libraryDocumentFileNameIssue (_ inDocumentFilePath : String) -> CanariIssue? {
  if inDocumentFilePath.isEmpty {
    return CanariIssue (kind: .warning, message: "File name is empty")
  }else{
    let baseName = inDocumentFilePath.lastPathComponent.deletingPathExtension
    for char in baseName.unicodeScalars {
      var ok = (char >= "a") && (char <= "z")
      if !ok {
        ok = (char >= "0") && (char <= "9")
      }
      if !ok {
        ok = (char == "-") || (char == "_")
      }
      if !ok {
        return CanariIssue (kind: .error, message: "File name should be a sequence of lowercase ASCII letters, digits, '-' or '_'")
      }
    }
  }
  return nil
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
