//
//  library-repository-status.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension CanariLibraryEntry {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func status (_ inLogTextView : AutoLayoutStaticTextView) -> (Int?, [LibraryOperationDescriptor]) {
    inLogTextView.string = ""
  //--- Get current commit
    inLogTextView.appendMessageString ("Last commit: ")
    let possibleCurrentCommit = self.loadRepositorCurrentCommit ()
    if let currentCommit = possibleCurrentCommit {
      inLogTextView.appendSuccessString ("\(currentCommit)\n")
    }else{
      inLogTextView.appendErrorString (" error\n")
    }
  //--- Get repository contents file
    let possibleRemoteFileDescriptorDict = getCurrentCommitDescription (possibleCurrentCommit, inLogTextView)
  //--- Enumerate local files
    let possibleLocalFilesDescriptors = getLocalFilesDescription (inLogTextView)
  //--- Build operation array
    var operations = [LibraryOperationDescriptor] ()
    if let currentCommit = possibleCurrentCommit,
       let remoteFileDescriptorDict = possibleRemoteFileDescriptorDict,
       let localFilesDescriptors = possibleLocalFilesDescriptors {
      var handledFiles = Set <String> ()
      for localEntry in localFilesDescriptors {
        handledFiles.insert (localEntry.mRelativePath)
        if let remoteEntry = remoteFileDescriptorDict [localEntry.mRelativePath] {
          let fileChanged = (localEntry.mSize != remoteEntry.mSize) || (localEntry.mSHA != remoteEntry.mSHA)
          if fileChanged {
            let operation = LibraryOperationDescriptor (
              relativePath: localEntry.mRelativePath,
              commit: currentCommit + 1,
              length: localEntry.mSize,
              sha: localEntry.mSHA,
              operation: .upgrade
            )
            operations.append (operation)
          }else{
            let operation = LibraryOperationDescriptor (
              relativePath: localEntry.mRelativePath,
              commit: remoteEntry.mCommit,
              length: localEntry.mSize,
              sha: localEntry.mSHA,
              operation: .nop
            )
            operations.append (operation)
          }
        }else{ // new file: add it
          let operation = LibraryOperationDescriptor (
            relativePath: localEntry.mRelativePath,
            commit: currentCommit + 1,
            length: localEntry.mSize,
            sha: localEntry.mSHA,
            operation: .upload
          )
          operations.append (operation)
        }
      }
    //--- Add files to remove
      for removedPath in Set (remoteFileDescriptorDict.keys).subtracting (handledFiles) {
       let operation = LibraryOperationDescriptor (
          relativePath: removedPath,
          commit: 0,
          length: 0,
          sha: "",
          operation: .remove
        )
        operations.append (operation)
      }
    //---
      inLogTextView.appendMessageString ("Operations:\n")
      var operationCount : UInt = 0
      for entry in operations {
        switch entry.operation {
        case .nop :
          ()
          // inLogTextView.appendMessageString ("  No change for \(entry.mRelativePath)\n")
        case .remove :
          operationCount += 1
          inLogTextView.appendMessageString ("  Remove \(entry.relativePath)\n")
        case .upload :
          operationCount += 1
          inLogTextView.appendMessageString ("  Upload \(entry.relativePath)\n")
        case .upgrade :
          operationCount += 1
          inLogTextView.appendMessageString ("  UpGrade \(entry.relativePath)\n")
        }
      }
      if operationCount == 0 {
        inLogTextView.appendSuccessString ("No operation\n")
      }else if operationCount == 1 {
        inLogTextView.appendSuccessString ("1 operation\n")
      }else{
        inLogTextView.appendSuccessString ("\(operationCount) operations\n")
      }
    }
  //---
    return (possibleCurrentCommit, operations)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func getCurrentCommitDescription (_ possibleCurrentCommit : Int?, _ inLogTextView : AutoLayoutStaticTextView) -> [String : LibraryContentsDescriptor]? {
    var possibleCurrentRepositoryContents : [String : LibraryContentsDescriptor]? = nil
    if let currentCommit = possibleCurrentCommit {
      possibleCurrentRepositoryContents = [String : LibraryContentsDescriptor] ()
      if currentCommit > 0 {
        inLogTextView.appendMessageString ("Get current commit description file...")
        let commitRemoteRelativePath = "contents/contents-\(currentCommit).plist"
        let r = readRemoteFile (commitRemoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag)
        switch r {
        case .error (let errorCode) :
          inLogTextView.appendErrorString ("error\(errorCode)\n")
          possibleCurrentRepositoryContents = nil
        case .ok (let data) :
          inLogTextView.appendSuccessString ("ok\n")
          let possibleDictArray = unsafe try? PropertyListSerialization.propertyList (from: data, format: nil)
          if let dictArray = possibleDictArray as? [[String : Any]] {
            for dictionary : [String : Any] in dictArray {
              if let entry = LibraryContentsDescriptor (withDictionary: dictionary) {
                possibleCurrentRepositoryContents? [entry.mRelativePath] = entry
              }
            }
          }
        }
      }
    }
    return possibleCurrentRepositoryContents
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func getLocalFilesDescription (_ inLogTextView : AutoLayoutStaticTextView) -> [LibraryContentsDescriptor]? {
    var possibleLocalFileDescriptors : [LibraryContentsDescriptor]? = nil
    let fm = FileManager ()
    if fm.fileExists (atPath: self.mPath) {
      possibleLocalFileDescriptors = [LibraryContentsDescriptor] ()
      if let currentLibraryContents = try? fm.subpathsOfDirectory (atPath: self.mPath) {
        for relativePath in currentLibraryContents {
        //--- Eliminate hidden files
          var enter = true
          var p = relativePath
          while enter && (p != "") {
            enter = p.lastPathComponent.first! != "."
            p = p.deletingLastPathComponent
          }
        //--- Eliminate directories
          let fullPath = self.mPath + "/" + relativePath
          if enter {
            var isDirectory : ObjCBool = false
            _ = unsafe fm.fileExists (atPath: fullPath, isDirectory: &isDirectory)
            enter = !isDirectory.boolValue
          }
          if enter {
            if let data = fm.contents(atPath: fullPath) {
              let entry = LibraryContentsDescriptor (relativePath: relativePath, commit: 0, contents: data)
              possibleLocalFileDescriptors?.append (entry)
            }else{
              inLogTextView.appendErrorString ("Error: cannot read \(relativePath)\n")
              possibleLocalFileDescriptors = nil
            }
          }
        }
      }
    }
    return possibleLocalFileDescriptors
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

struct LibraryContentsDescriptor {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mRelativePath : String
  let mCommit : Int
  let mSize : Int
  let mSHA : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (relativePath inRelativePath : String,
        commit inCommit : Int,
        contents inContents : Data) {
    self.mRelativePath = inRelativePath
    self.mCommit = inCommit
    self.mSize = inContents.count
    self.mSHA = sha1 (data: inContents)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init? (withDictionary inDictionary : [String : Any]) {
    if let relativePath = inDictionary ["path"] as? String,
       let commit = inDictionary ["commit"] as? Int,
       let length = inDictionary ["length"] as? Int,
       let sha = inDictionary ["sha"] as? String {
      self.mRelativePath = relativePath
      self.mCommit = commit
      self.mSize = length
      self.mSHA = sha
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func dictionary () -> [String : Any] {
//    let dict : [String : Any] = [
//      "path" : self.mRelativePath,
//      "commit" : self.mCommit,
//      "length" : self.mSize,
//      "sha" : self.mSHA
//    ]
//    return dict
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

struct LibraryOperationDescriptor {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum Operation {
    case nop
    case upload
    case upgrade
    case remove
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let relativePath : String
  let commit : Int
  let length : Int
  let sha : String
  let operation : LibraryOperationDescriptor.Operation

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func dictionary () -> [String : Any] {
    let dict : [String : Any] = [
      "path" : self.relativePath,
      "commit" : self.commit,
      "length" : self.length,
      "sha" : self.sha
    ]
    return dict
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
