//
//  phase2-get-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://developer.github.com/v3/git/trees/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

 func phase2_readOrDownloadLibraryFileDictionary (_ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor],
                                                  _ inLogTextView : NSTextView,
                                                  _ inProxy : [String],
                                                  _ inNeedsToDownloadRepositoryFileList : Bool,
                                                  _ ioPossibleAlert : inout NSAlert?) {
//--- Download library description file ?
  let fm = FileManager ()
  inLogTextView.appendWarningString ("  Needs to download description file: \(inNeedsToDownloadRepositoryFileList)\n")
  inLogTextView.appendWarningString ("  Local description file is valid: \(libraryDescriptionFileIsValid ())\n")
  if inNeedsToDownloadRepositoryFileList || !libraryDescriptionFileIsValid () {
    if let repositoryCommitSHA = getRepositoryCommitSHA () {
      inLogTextView.appendWarningString ("  Local repository image file is not valid: get it from repository\n")
      let arguments = [
        "-s", // Silent mode, do not show download progress
        "-L", // Follow redirections
        "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/git/trees/\(repositoryCommitSHA)?recursive=1"
      ] + inProxy
      let response = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
      switch response {
      case .error (let errorCode) :
        if errorCode != 6 { // Error #6 is 'no network connection'
          ioPossibleAlert = NSAlert ()
          ioPossibleAlert?.messageText = "Cannot connect to the server"
          ioPossibleAlert?.informativeText = "Error code: \(errorCode)"
        }
      case .ok (let responseData) :
        do{
          let jsonObject = try JSONSerialization.jsonObject (with: responseData) as! NSDictionary
          let treeEntry = get (jsonObject, "tree", #line)
          let extensions = Set <String> (["ElCanariFont", "ElCanariArtwork", "ElCanariSymbol", "ElCanariPackage", "ElCanariDevice"])
          if let fileDescriptionArray = treeEntry as? [[String : Any]] {
            Swift.print ("fileDescriptionArray \(fileDescriptionArray)")
            for fileDescriptionDictionay in fileDescriptionArray {
              let filePath = fileDescriptionDictionay ["path"] as! String
              if extensions.contains (filePath.pathExtension) {
                var localSHA = ""
                if fm.fileExists (atPath: filePath) {
                  let fileData = try! Data (contentsOf: URL (fileURLWithPath: filePath))
                  localSHA = sha1 (fileData)
                }
                let descriptor = CanariLibraryFileDescriptor (
                  relativePath: filePath,
                  repositorySHA: "?",
                  sizeInRepository: fileDescriptionDictionay ["size"] as! Int,
                  localSHA: localSHA
                )
                ioLibraryFileDictionary [filePath] = descriptor
              }
            }
          }else{
            inLogTextView.appendErrorString ("  Entry is not an [[String : String]] object: \(String (describing: treeEntry))\n")
            let alert = NSAlert ()
            alert.messageText = "Internal error"
            alert.informativeText = "Entry is not an [[String : String]] object: \(String (describing: treeEntry))."
            ioPossibleAlert = alert
          }
        }catch let error {
          ioPossibleAlert = NSAlert (error: error)
        }
      }
    }else{
      inLogTextView.appendErrorString ("  Repository commit SHA does not exist in preferences\n")
      let alert = NSAlert ()
      alert.messageText = "Internal error"
      alert.informativeText = "Repository commit SHA does not exist in preferences."
      ioPossibleAlert = alert
    }
  }
//--- Print
  inLogTextView.appendMessageString ("  Repository contents [size — path]:\n")
  for (path, value) in ioLibraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(value.mSizeInRepository) — \(path)]\n")
  }
//--- Now, use local library description file to get repository SHA
  if (ioPossibleAlert == nil) && libraryDescriptionFileIsValid () {
    let f = systemLibraryPath () + "/" + repositoryDescriptionFile
    let data = try! Data (contentsOf: URL (fileURLWithPath: f))
    let propertyList = try! PropertyListSerialization.propertyList (from: data, format: nil) as! [[String : String]]
    for entry in propertyList {
      let filePath = entry ["path"]!
      let repositorySHA = entry ["sha"]!
      if let descriptor = ioLibraryFileDictionary [filePath] {
        let newDescriptor = CanariLibraryFileDescriptor (
          relativePath: filePath,
          repositorySHA: repositorySHA,
          sizeInRepository: descriptor.mSizeInRepository,
          localSHA: descriptor.mLocalSHA
        )
        ioLibraryFileDictionary [filePath] = newDescriptor
      }else{
        let fullFilePath = systemLibraryPath () + "/" + filePath
        var localSHA = ""
        if fm.fileExists (atPath: fullFilePath) {
          let fileData = try! Data (contentsOf: URL (fileURLWithPath: fullFilePath))
          localSHA = sha1 (fileData)
        }
        let newDescriptor = CanariLibraryFileDescriptor (
          relativePath: filePath,
          repositorySHA: "?",
          sizeInRepository: Int (entry ["size"]!)!,
          localSHA: localSHA
        )
        ioLibraryFileDictionary [filePath] = newDescriptor
      }
    }
  }
//--- Print
  inLogTextView.appendMessageString ("  Repository contents, with repository SHA [repositorySHA — localSHA — size — path]:\n")
  for (path, value) in ioLibraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(value.mRepositorySHA) — \(value.mLocalSHA) — \(value.mSizeInRepository) — \(path)]\n")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   get fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func get (_ inObject: Any?, _ key : String, _ line : Int) -> Any? {
  if let dictionary = inObject as? NSDictionary {
    if let r = dictionary [key] {
      return r
    }else{
      print ("line \(line) : no \(key) key in dictionary")
      return nil
    }
  }else{
    print ("line \(line) : object is not a dictionary")
    return nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
