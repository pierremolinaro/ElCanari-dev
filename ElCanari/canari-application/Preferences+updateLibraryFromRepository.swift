
import Cocoa
import Foundation
import SystemConfiguration
import ServiceManagement

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Comment est effectuée la mise à jour de la librairie des composants ElCanari
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
// Cette librairie est contenue dans le repository https://github.com/pierremolinaro/ElCanari-Library
//
//--------------- ① Savoir si une mise à jour est disponible
// On cherche les infos de la branche master :
//   curl -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse est du style :
//[
//  {
//    "name": "master",
//    "commit": {
//      "sha": "910e061c5202ce9904f1ee2e464ee5354869bb2a",
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/commits/910e061c5202ce9904f1ee2e464ee5354869bb2a"
//    }
//  }
//]
// Le champ sha donne l'identité du dernier commit.
//
// On peut faire mieux (https://developer.github.com/v3/?#conditional-requests) : d'abord récupérer l'Etag du dernier
// commit (l'option -i affiche le header HTTP) :
//   curl -i -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse :
//   HTTP/1.1 200 OK
// ·····
//   Status: 200 OK
// ·····
//   ETag: "e00f8fbc5829aa5e29c64688276e9f4f"
// ·····
//   après une ligne vide, la réponse au format json
//
// Ensuite, si on relance la commande :
//   curl -i -H 'If-None-Match:"e00f8fbc5829aa5e29c64688276e9f4f"' https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse :
//   HTTP/1.1 304 Not Modified
// ·····
//   Status: 304 Not Modified
// ·····
//   ETag: "e00f8fbc5829aa5e29c64688276e9f4f"
// ·····
//   et pas de réponse au format json
// L'intérêt de cette méthode est que l'appel n'est pas comptabilisé dans le décompte des appels (max : 60 / h) si la réponse est 304.
//
//--------------- ② Connaître les fichiers à remettre à jour
// On télécharge la liste des fichiers correspondant au commit
//   curl -i -H "Accept:application/vnd.github.v3+json" https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/910e061c5202ce9904f1ee2e464ee5354869bb2a?recursive=1
// La réponse est la liste des fichiers au format JSON
//{
//  "sha": "910e061c5202ce9904f1ee2e464ee5354869bb2a",
//  "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/910e061c5202ce9904f1ee2e464ee5354869bb2a",
//  "tree": [
//    ················
//    {
//      "path": "artworks/electro_dragon.ElCanariArtwork",
//      "mode": "100644",
//      "type": "blob",
//      "sha": "038e85b12174cbcaca0c5c7f1b5885903446fb73",
//      "size": 5854,
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/blobs/038e85b12174cbcaca0c5c7f1b5885903446fb73"
//    },
//    ················
// Le champ intéressant est "path", qui contient le chemin relatif des fichiers. Attention, "sha" n'est pas le sha du
// fichier, mais celle de son blog ; idem pour "url". Mais on peut utiliser la valeur de "sha" pour savoir si le fichier
// a changé.
//
//--------------- ③ Récupérer le contenu d'un fichier
// Pour chaque fichier à récupérer
//   curl -H "Accept:application/vnd.github.v3+json" https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/910e061c5202ce9904f1ee2e464ee5354869bb2a/artworks/electro_dragon.ElCanariArtwork
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LOG_LIBRARY_UPDATES = true

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    extension Preferences
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {

  //····················································································································

  func beginDownloadRepositoryList () {
    gLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
    mCheckForLibraryUpdatesButton?.isEnabled = false
    mUpDateLibraryMenuItemInCanariMenu?.action = nil
  }

  //····················································································································

  func cancelDownloadRepositoryList () {
    mCheckForLibraryUpdatesButton?.isEnabled = true
    mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
  }

  //····················································································································

  func cancelDownloadElementFromRepository () {
    mLibraryUpdateWindow?.orderOut (nil)
    mCheckForLibraryUpdatesButton?.isEnabled = true
    mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gLibraryUpdateWindow : EBWindow? = nil // nil if background search
private let repositoryDescriptionFile = "repository-description.plist"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func performLibraryUpdate (_ inWindow : EBWindow?) {
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdate BEGIN")
  }
  gLibraryUpdateWindow = inWindow
//-------- We start by checking if a repository did change using etag
  if let etag = getRepositoryCurrentETag () {
    performLibraryUpdateUsingEtag (etag)
  }else{
    performLibraryUpdateNoEtag ()
  }
//  g_Preferences?.beginDownloadRepositoryList ()
////--- Download repository list
//  let session = URLSession.shared 
//  if let url = URL (string:"http://canarilibrary.rts-software.org/repositoryListV2.php") {
//    let sessionTask = session.dataTask (with: url, completionHandler:downloadRepositoryListDidEnd)
//    sessionTask.resume ()
//  }
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdate DONE")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryUpdateUsingEtag (_ etag : String) {
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "-H", "If-None-Match:\"\(etag)\"",
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ])
  switch response {
  case .error (let errorCode) :
    if errorCode != 6 { // Error #6 is 'no network connection'


    }
  case .ok (let responseData) :
    if let response = String (data: responseData, encoding: .utf8) {
      //print ("\(response)")
      let c0 = response.components (separatedBy: "Status: ")
      let c1 = c0 [1].components (separatedBy: " ")
      //print ("C1 \(c1 [0])")
      if let status = Int (c1 [0]) {
        if LOG_LIBRARY_UPDATES {
          print ("HTTP status \(status)")
        }
        if status == 304 { // Status 304 --> not modified, use current repository description file
          performLibraryUpdateWithCurrentRepositoryDescriptionFile ()
        }else if status == 200 { // Status 200 --> Ok, modified
          writeRepositoryDescriptionFile (withResponse: response)
        }
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryUpdateNoEtag () {
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ])
  switch response {
  case .error (let errorCode) :
    if errorCode != 6 { // Error #6 is 'no network connection'


    }
  case .ok (let responseData) :
    if let response = String (data: responseData, encoding: .utf8) {
      writeRepositoryDescriptionFile (withResponse: response)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func writeRepositoryDescriptionFile (withResponse inResponse : String) {
  let components = inResponse.components (separatedBy:"\r\n\r\n")
  if components.count == 2 {
    let jsonData = components [1].data (using: .utf8)!
    do{
    //--- Get commit sha
      let jsonArray = try JSONSerialization.jsonObject (with: jsonData) as! NSArray
      let jsonDictionary = jsonArray [0] as! NSDictionary
      if LOG_LIBRARY_UPDATES {
        print ("-->  jsonDictionary \(jsonDictionary)")
      }
      let commitDict = jsonDictionary ["commit"]  as! NSDictionary
      let commitSHA = commitDict ["sha"]  as! String
    //--- Get ETag
      let c1 = components [0].components (separatedBy:"ETag: \"")
      let c2 = c1 [1].components (separatedBy:"\"")
      let etag = c2 [0]
      if LOG_LIBRARY_UPDATES {
        print ("-->  ETag \(etag)")
      }
    //--- Write result in repository description file
      let repositoryDescriptionDictionary = NSMutableDictionary ()
      repositoryDescriptionDictionary ["etag"] = etag
      repositoryDescriptionDictionary ["commitSHA"] = commitSHA
      let f = systemLibraryPath () + "/" + repositoryDescriptionFile
      repositoryDescriptionDictionary.write (toFile: f, atomically: true)
      performLibraryUpdateWithCurrentRepositoryDescriptionFile ()
    }catch let error {
      print ("Error, error \(error)")
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryUpdateWithCurrentRepositoryDescriptionFile () {
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdateWithCurrentRepositoryDescriptionFile BEGIN")
  }
//------------------ Step ② : download from repository the library.plist file
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-H", "Accept: application/vnd.github.v3+json", // Add response header in output
    "-L", // Follow redirections
    "https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/\(getRepositoryCurrentCommitSHA ())/library.plist"
  ])
  switch response {
  case .error (let errorCode) :
    if errorCode != 6 { // Error #6 is 'no network connection'

    }
  case .ok (let responseData) :
    do{
      let repositoryFilePLIST = try PropertyListSerialization.propertyList (from: responseData, format: nil)
      let repositoryFileArray = repositoryFilePLIST as! [[String : String]]
      var libraryFileDictionary = [String : CanariLibraryFileDescriptor] ()
      if LOG_LIBRARY_UPDATES {
        print ("*********** Repository contents (SHA:size:path)")
      }
      for d in repositoryFileArray {
        let path = d ["name"]!
        let repositorySHA = d ["fileSHA"]!
        let sizeInRepository = d ["fileSize"]!
        if LOG_LIBRARY_UPDATES {
          print ("  \(repositorySHA):\(sizeInRepository):\(path)")
        }
        let descriptor = CanariLibraryFileDescriptor (
          relativePath: path,
          repositorySHA: repositorySHA,
          sizeInRepository: Int (sizeInRepository)!,
          localSHA: ""
        )
        libraryFileDictionary [path] = descriptor
      }
      try performUpdateWithCurrentRepositoryContents (libraryFileDictionary)
      // print ("libraryFileDictionary \(libraryFileDictionary)")
    }catch let error {
       print ("Error \(error)")
    }
  }
//------------------
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdateWithCurrentRepositoryDescriptionFile END")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performUpdateWithCurrentRepositoryContents (_ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor]) throws {
//------------------ Step ③ : enumerate current file in library
  let fm = FileManager ()
  var libraryFileDictionary = inLibraryFileDictionary
//--- Get library files
  if fm.fileExists (atPath: systemLibraryPath ()) {
    let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
    for filePath in currentLibraryContents {
    //--- Eliminate ".DS_store" and description plist file
      var enter = (filePath.lastPathComponent != ".DS_Store") && (filePath != repositoryDescriptionFile)
    //--- Eliminate directories
      if enter {
        let fullPath = systemLibraryPath () + "/" + filePath
        var isDirectory : ObjCBool = false
        _ = fm.fileExists (atPath:fullPath, isDirectory: &isDirectory)
        enter = !isDirectory.boolValue
      }
      if enter {
        if let descriptor = libraryFileDictionary [filePath] {
          let localSHA = try computeFileSHA (filePath)
          let newDescriptor = CanariLibraryFileDescriptor (
            relativePath: descriptor.mRelativePath,
            repositorySHA: descriptor.mRepositorySHA,
            sizeInRepository: descriptor.mSizeInRepository,
            localSHA: localSHA
          )
          libraryFileDictionary [filePath] = newDescriptor
        }else{
          let descriptor = CanariLibraryFileDescriptor (
            relativePath: filePath,
            repositorySHA: "",
            sizeInRepository: 0,
            localSHA: "?"
          )
          libraryFileDictionary [filePath] = descriptor
        }
      }
    }
  }
  if LOG_LIBRARY_UPDATES {
    print ("*********** Library descriptor contents (local SHA:repository SHA:SHA:repository size:file path)")
    for descriptor in libraryFileDictionary.values {
      print ("  \(descriptor.mLocalSHA):\(descriptor.mRepositorySHA):\(descriptor.mSizeInRepository):\(descriptor.mRelativePath)")
    }
  }
  try performUpdateWithLocalAndRepositoryContents (libraryFileDictionary)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performUpdateWithLocalAndRepositoryContents (_ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor]) throws {
  var libraryOperations = [LibraryOperationElement] ()
  for descriptor in inLibraryFileDictionary.values {
    if descriptor.mRepositorySHA == "" {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: 0, operation: .delete)
      libraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "") {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: descriptor.mSizeInRepository, operation: .download)
      libraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: descriptor.mSizeInRepository, operation: .update)
      libraryOperations.append (element)
    }
  }
  if LOG_LIBRARY_UPDATES {
    print ("*********** Library operations (operation:file path:size in repository)")
    for op in libraryOperations {
      print ("  \(op.mOperation):\(op.mRelativePath):\(op.mSizeInRepository)")
    }
  }
  if libraryOperations.count != 0 {
    performLibraryOperations (libraryOperations)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryOperations (_ inLibraryOperations : [LibraryOperationElement]) {
//--- Perform library update in main thread
  DispatchQueue.main.async  {
  //--- Hide library checking window
    gLibraryUpdateWindow?.orderOut (nil)
  //--- Configure informative text in library update window
    if inLibraryOperations.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(inLibraryOperations.count) elements to update"
    }
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = Double (0)
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
      actionArray:inLibraryOperations //,
  //    libraryPLIST:libraryPLIST
    )
    gCanariLibraryUpdateController.bind ()
  //--- Enable update button
    g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum LibraryOperation {
  case download
  case update
  case delete
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct LibraryOperationElement {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  let mSizeInRepository : Int
  let mOperation : LibraryOperation

  //····················································································································

  init (relativePath inRelativePath : String,
        sizeInRepository inSizeInRepository : Int,
        operation inOperation : LibraryOperation) {
    mRelativePath = inRelativePath
    mOperation = inOperation
    mSizeInRepository = inSizeInRepository
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
  actionArray : [LibraryOperationElement] ()
//  libraryPLIST : NSMutableDictionary ()
)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class PMCanariLibraryUpdateController : NSObject, EBUserClassNameProtocol {
//   let mPersistentActionArray : [PMCanariLibraryFileDescriptor]
//   let mLibraryPLIST : NSMutableDictionary
   let mArrayController = NSArrayController ()
//
   var mCurrentActionArray : [LibraryOperationElement]
//   var mParallelActionCount = 0
//   var mPossibleError : Error? = nil
//  
//  //····················································································································
//
  init (actionArray : [LibraryOperationElement]) { //, libraryPLIST : NSMutableDictionary) {
    mCurrentActionArray = actionArray
//    mLibraryPLIST = libraryPLIST
    super.init ()
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func bind () {
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.mRelativePath",
        options:nil
      )
      tableView.tableColumn(withIdentifier: "action")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.mActionName",
        options:nil
      )
      tableView.tableColumn(withIdentifier: "repository")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.repository",
        options:nil
      )
      tableView.tableColumn(withIdentifier: "local")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.local",
        options:nil
      )
      mArrayController.content = gCanariLibraryUpdateController.mCurrentActionArray
    }
  }
  
  //····················································································································

  func unbind () { //--- Remove bindings
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "action")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "repository")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "local")?.unbind ("value")
      mArrayController.content = nil
    }
  }

//  //····················································································································
//  // http://stackoverflow.com/questions/26291005/replacement-of-protocolprotocol-name-in-swift
//
//  //····················································································································
//
//  func interruptionHandler () {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    sendTerminateToHelperTool ()
//  }
//
//  //····················································································································
//
//  func invalidationHandler () {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    sendTerminateToHelperTool ()
//  }
//
//  //····················································································································
//
//  fileprivate func writeFile (sha1 inSHA1 : Data,
//                              revisionInRepository inRevisionInRepository : Int,
//                              fromTemporaryPath inTemporaryPath : String,
//                              atRelativePath inRelativePath : String) {
//     if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    if mPossibleError == nil {
//      do{
//        let fm = FileManager ()
//        let destinationURL = URL (fileURLWithPath:systemLibraryPath () + "/" + inRelativePath)
//        let destinationDirectoryURL = destinationURL.deletingLastPathComponent ()
//        if !fm.fileExists(atPath: destinationDirectoryURL.path) {
//          if LOG_LIBRARY_UPDATES {
//            NSLog ("Create dir '\(destinationDirectoryURL.path)'")
//          }
//          try fm.createDirectory (atPath:destinationDirectoryURL.path, withIntermediateDirectories:true, attributes:nil)
//        }else if fm.fileExists (atPath: destinationURL.path) {
//          try fm.removeItem (atPath:destinationURL.path)
//        }
//        let sourceURL = URL (fileURLWithPath:inTemporaryPath)
//        try fm.moveItem (atPath:sourceURL.path, toPath:destinationURL.path)
//        let descriptorForLocalPlist : [String : AnyObject] = [
//          "revision" : NSNumber (value:inRevisionInRepository),
//          "sha1" : inSHA1 as AnyObject
//        ]
//        mLibraryPLIST.setObject (descriptorForLocalPlist, forKey:inRelativePath as NSCopying)
//      }catch let error {
//        mPossibleError = error
//        if LOG_LIBRARY_UPDATES {
//          NSLog ("ERROR")
//        }
//      }
//    }
//  }
//  
//  //····················································································································
//
//  fileprivate func deleteFileAtRelativePath (_ inRelativePath : String) {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    let destinationPath = systemLibraryPath () + "/" + inRelativePath
//    let fm = FileManager ()
//    do{
//      try fm.removeItem (atPath: destinationPath)
//      mLibraryPLIST.removeObject (forKey: inRelativePath)
//    }catch let error {
//      mPossibleError = error
//    }
//  }
//
//  //····················································································································
//
//  fileprivate func writePLISTFile () {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    let plistFilePath = systemLibraryPath () + "/" + libraryDescriptionPLISTfilename ()
//    let ok = mLibraryPLIST.write (toFile: plistFilePath, atomically: true)
//    if (ok) {
//      let possibleError = deleteOrphanDirectories ()
//      if let error = possibleError {
//        mPossibleError = error
//      }
//    }else{
//      let dictionary = [
//        NSLocalizedDescriptionKey : "Cannot write '\(libraryDescriptionPLISTfilename ())' file"
//      ]
//      let error = NSError (
//        domain:"PMError",
//        code:1,
//        userInfo:dictionary
//      )
//      mPossibleError = error
//    }
//  }
//
//  //····················································································································
//
//  private func deleteOrphanDirectories () -> Error? {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    let fm = FileManager ()
//    var possibleError : Error? = nil
//    do{
//      let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
//      var directoryArray = [String] ()
//      for relativePath in currentLibraryContents {
//        let fullPath = systemLibraryPath () + "/" + relativePath
//        var isDirectory : ObjCBool = false ;
//        fm.fileExists (atPath: fullPath, isDirectory:&isDirectory)
//        if (isDirectory.boolValue) {
//          directoryArray.append (fullPath)
//        }
//      }
//      directoryArray.sort ()
//      if LOG_LIBRARY_UPDATES {
//        NSLog ("directories to delete '\(directoryArray.description)")
//      }
//      var i=directoryArray.count-1
//      while i>=0 {
//        let fullPath = directoryArray [i]
//        var currentDirectoryContents = try fm.contentsOfDirectory (atPath: fullPath)
//      //--- Remove .DS_Store files
//        var j=0
//        while j<currentDirectoryContents.count {
//          let s = currentDirectoryContents [j]
//          if s == ".DS_Store" {
//            currentDirectoryContents.remove (at: j)
//            j -= 1
//          }
//          j += 1
//        }
//        if (currentDirectoryContents.count == 0) {
//          if LOG_LIBRARY_UPDATES {
//            NSLog ("delete orphean at '\(fullPath)")
//          }
//          try fm.removeItem (atPath: fullPath)
//        }
//        i -= 1
//      }
//    }catch let error {
//      possibleError = error
//    }
//    return possibleError
//  }
//
//  //····················································································································
//
//  func helperToolSendsError (_ inError : Error) {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    mPossibleError = inError
//    sendTerminateToHelperTool ()
//  }
//
//  //····················································································································
//
//  func helperToolSendsJobCompleted () {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//    sendTerminateToHelperTool ()
//  }
//
//  //····················································································································
//
//  func sendTerminateToHelperTool () {
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function)")
//    }
//  }
//  
//  //····················································································································
//
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func cleanLibraryUpdate () {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
////--- Hide library update window
//  g_Preferences?.cancelDownloadElementFromRepository ()
////---
//  gCanariLibraryUpdateController.unbind ()
//  gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
//    actionArray : [PMCanariLibraryFileDescriptor] (),
//    libraryPLIST : NSMutableDictionary ()
//  )
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//let parallelDownloadCount = 8

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
////--- Update UI
//  g_Preferences?.mUpDateButtonInLibraryUpdateWindow?.isEnabled = false
////--- Launch parallel downloads
//  gCanariLibraryUpdateController.mParallelActionCount = parallelDownloadCount
//  for _ in 1...parallelDownloadCount { // For Making downloads in parallel
//    launchElementDownload (nil)
//  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func launchElementDownload (_ possibleError : Error?) {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
////--- Error ?
//  if let error = possibleError, gCanariLibraryUpdateController.mPossibleError == nil {
//    gCanariLibraryUpdateController.mPossibleError = error
//    cancelLibraryUpdate ()
//  }
//  
//  var nothingToDo = true
//  var i = 0
//  while (i<gCanariLibraryUpdateController.mCurrentActionArray.count) && nothingToDo && (gCanariLibraryUpdateController.mPossibleError == nil) {
//    let descriptor = gCanariLibraryUpdateController.mCurrentActionArray [i]
//    // NSLog ("\(i) isDownloading \(descriptor.isDownloading ())")
//    switch descriptor.mEnumLibraryDownloadAction {
//    case .kLibraryDownloadActionUpdate :
//      descriptor.launchDownload ()
//      nothingToDo = false
//    case .kLibraryDownloadError, .kLibraryDownloadActionDownloaded :
//      gCanariLibraryUpdateController.mCurrentActionArray.remove (at: i)
//      i -= 1
//      gCanariLibraryUpdateController.mArrayController.content = gCanariLibraryUpdateController.mCurrentActionArray
//      g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue += Double (descriptor.mSizeInRepository + ACCESS_EQ_SIZE_FOR_PROGRESS_INDICATOR)
//      if gCanariLibraryUpdateController.mCurrentActionArray.count == 1 {
//        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
//      }else{
//        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(gCanariLibraryUpdateController.mCurrentActionArray.count) elements to update"
//      }
//    default :
//      break
//    }
//    i += 1
//  }
//  if nothingToDo {
//    gCanariLibraryUpdateController.mParallelActionCount -= 1
//  }
//  if gCanariLibraryUpdateController.mParallelActionCount == 0 {
//  //--- Error or ok ?
//    if let error = gCanariLibraryUpdateController.mPossibleError {
//      NSApp.presentError (error)
//      cleanLibraryUpdate ()
//    }else{
//      commitUpdatesInFileSystem ()
//    }
//  }
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
////--- The button is inactived during download
//  if let button = g_Preferences?.mUpDateButtonInLibraryUpdateWindow, !button.isEnabled {
//  //--- Cancel current downloadings
//    for descriptor in gCanariLibraryUpdateController.mCurrentActionArray {
//      descriptor.cancelDownloading ()
//    }
//  //--- Stop helper tool
//    gCanariLibraryUpdateController.sendTerminateToHelperTool ()
//  }else{ // Download is not started
//    cleanLibraryUpdate ()
//  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  let mRepositorySHA : String
  let mSizeInRepository : Int
  let mLocalSHA : String

  //····················································································································

  init (relativePath inRelativePath : String,
        repositorySHA inRepositorySHA : String,
        sizeInRepository inSizeInRepository : Int,
        localSHA inLocalSHA : String) {
    mRelativePath = inRelativePath
    mRepositorySHA = inRepositorySHA
    mLocalSHA = inLocalSHA
    mSizeInRepository = inSizeInRepository
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of Data
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func sha1 (_ inData : Data) -> Data {
  let transform = SecDigestTransformCreate (kSecDigestSHA1, 0, nil)
  SecTransformSetAttribute (transform, kSecTransformInputAttributeName, inData as CFTypeRef, nil)
  return SecTransformExecute (transform, nil) as! Data
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of a library file
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func computeFileSHA (_ filePath : String) throws -> String {
  let absoluteFilePath = systemLibraryPath () + "/" + filePath
  let data = try Data (contentsOf: URL (fileURLWithPath: absoluteFilePath))
  var s = ""
  for byte in sha1 (data) {
    s += "\(String (byte, radix:16, uppercase: false))"
  }
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   runShellCommandAndGetDataOutput
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private enum ShellCommandStatus {
  case ok (Data)
  case error (Int32)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func runShellCommandAndGetDataOutput (_ command : [String]) -> ShellCommandStatus {
  if LOG_LIBRARY_UPDATES {
    print ("Command \(command)")
  }
//--- Separate command and arguments
  let cmd = command [0]
  let args = [String] (command.dropFirst ())
//--- Define task
  let task = Process ()
  task.launchPath = cmd
  task.arguments = args
  let pipe = Pipe ()
  task.standardOutput = pipe
  task.standardError = pipe
  let fileHandle = pipe.fileHandleForReading
//--- Launch
  task.launch ()
  var data = Data ()
  var hasData = true
  while hasData {
    let newData = fileHandle.availableData
    // print ("  \(newData.count)")
    hasData = newData.count > 0
    data.append (newData)
  }
  task.waitUntilExit ()
//--- Task completed
  fileHandle.closeFile ()
  let status = task.terminationStatus
  if status != 0 {
    if LOG_LIBRARY_UPDATES {
      print ("Error \(status)")
    }
    return .error (status)
  }else{
    if LOG_LIBRARY_UPDATES {
      print ("Ok \(data.count) bytes")
    }
    return .ok (data)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCurrentETag () -> String? { // Returns nil if no current description file
  var result : String? = nil
//--- Get library file
  let currentLibraryContents = systemLibraryPath () + "/" + repositoryDescriptionFile
  if let dict = NSDictionary (contentsOfFile:currentLibraryContents), let etag = dict ["etag"] as? String {
    result = etag
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCurrentCommitSHA() -> String {
  var result = ""
//--- Get library file
  let currentLibraryContents = systemLibraryPath () + "/" + repositoryDescriptionFile
  if let dict = NSDictionary (contentsOfFile:currentLibraryContents), let sha = dict ["commitSHA"] as? String {
    result = sha
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M                                                       *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func commitUpdatesInFileSystem () {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function), gCanariLibraryUpdateController.mPersistentActionArray \(gCanariLibraryUpdateController.mPersistentActionArray.count)")
//  }
//  g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "Commit updates…"
//  
//  let fm = FileManager ()
//  for descriptor in gCanariLibraryUpdateController.mPersistentActionArray {
//    switch descriptor.mEnumLibraryDownloadAction {
//    case .kLibraryDownloadActionDelete :
//      if LOG_LIBRARY_UPDATES {
//        NSLog ("\(#function), deleteFileAtRelativePath '\(descriptor.mRelativePath)'")
//      }
//      gCanariLibraryUpdateController.deleteFileAtRelativePath (descriptor.mRelativePath)
//    case .kLibraryDownloadActionUpdate, .kLibraryDownloadActionDownloaded :
//      let temporaryPath = temporaryDownloadDirectory () + "/" + descriptor.mRelativePath
//      let possibleContents : Data? = fm.contents (atPath: temporaryPath)
//      if let contents = possibleContents {
//        gCanariLibraryUpdateController.writeFile (
//          sha1: sha1 (contents),
//          revisionInRepository:descriptor.mRevisionInRepository!,
//          fromTemporaryPath:temporaryPath,
//          atRelativePath:descriptor.mRelativePath
//        )
//      }else{
//        let error = canariError ("Cannot read file", informativeText: "File is " + temporaryPath)
//        gCanariLibraryUpdateController.mPossibleError = error
//      }
//    default :
//      break
//    }
//  }
////--- Error ?
//  if let error = gCanariLibraryUpdateController.mPossibleError {
//    NSApp.presentError (error)
//    cleanLibraryUpdate ()
//  }else{
//    if LOG_LIBRARY_UPDATES {
//      NSLog ("\(#function), copy PLIST '\(libraryDescriptionPLISTfilename ())'")
//    }
//    gCanariLibraryUpdateController.writePLISTFile ()
//    if let window = g_Preferences?.mLibraryUpdateWindow {
//      let alert = NSAlert ()
//      alert.messageText = "Library has been updated."
//      alert.beginSheetModal (for: window, completionHandler: { (NSModalResponse) in
//        cleanLibraryUpdate ()
//      })
//    }else{
//      cleanLibraryUpdate ()
//    }
//  }
////---
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// http://stackoverflow.com/questions/25761344/how-to-crypt-string-to-sha1-with-swift

//private func sha1 (_ data : Data) -> Data {
//  var digest = [UInt8] (repeating: 0, count:Int (CC_SHA1_DIGEST_LENGTH))
//  data.withUnsafeBytes { _ = CC_SHA1 ($0, CC_LONG (data.count), &digest) }
//  return Data (digest)
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func downloadRepositoryListDidEnd (_ possibleData : Data?,
//                                           response : URLResponse?,
//                                           possibleError: Error?) {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
//  if let error = possibleError {
//    libraryDownloadDidEndWithError (error)
//  }else if let data = possibleData { // ok
//    var ok = true
//    var localLibraryDictionary = [String : PMCanariLibraryFileDescriptor] ()
//    var libraryPLIST = NSMutableDictionary ()
//    do {
//      let xmlDoc = try XMLDocument (data: data, options:0)
//      (localLibraryDictionary, libraryPLIST) = try analyzeLocalLibrary ()
//      try analyzeRepositoryXMLDocument (xmlDoc, localLibraryDictionary:&localLibraryDictionary)
//      
//    }catch let error {
//      libraryDownloadDidEndWithError (error)
//      ok = false
//    }
//    if ok {
//      let (cumulativeSize, actionsToPerformArray) = evaluateUpdateActions (localLibraryDictionary)
//      if actionsToPerformArray.count > 0 { // There are actions to perform for updating
//        presentLibraryUpdateDialog (cumulativeSize, actionArray:actionsToPerformArray, libraryPLIST:libraryPLIST)
//      }else if let window = gLibraryUpdateWindow { // Library is up to date
//        let alert = NSAlert ()
//        alert.messageText = "The library is up to date."
//        alert.addButton (withTitle: "Ok")
//        DispatchQueue.main.async  {
//          alert.beginSheetModal (for: window, completionHandler: {(inReturnCode : NSModalResponse) in
//            DispatchQueue.main.async  {
//              window.orderOut (nil)
//              g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
//              g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
//            }
//          })
//        }
//      }else{
//        g_Preferences?.cancelDownloadRepositoryList ()
//      }
//    }
//  }else{
//    g_Preferences?.cancelDownloadRepositoryList ()
//  }
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func libraryDownloadDidEndWithError (_ error : Error) {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
//  DispatchQueue.main.async  {
//    if let window = gLibraryUpdateWindow {
//      let alert = NSAlert (error:error)
//      alert.beginSheetModal (for: window, completionHandler: {(inReturnCode : NSModalResponse) in
//        DispatchQueue.main.async  {
//          window.orderOut (nil)
//          g_Preferences?.cancelDownloadRepositoryList ()
//        }
//      })
//    }
//  }
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//private func throwError (_ message : String) throws {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
//  throw NSError (
//    domain:"CanariError",
//    code:1,
//    userInfo:[NSLocalizedDescriptionKey:message]
//  )
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func analyzeLocalLibrary () throws -> ([String : PMCanariLibraryFileDescriptor], NSMutableDictionary) {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
//  let fm = FileManager ()
////--- Get library files
//  var currentLibraryContents = [String] ()
//  if fm.fileExists (atPath: systemLibraryPath ()) {
//    currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
//  //--- Remove library-description.plist from list
//    let possibleIndex = currentLibraryContents.index (of: libraryDescriptionPLISTfilename ())
//    if let index = possibleIndex {
//      currentLibraryContents.remove (at: index)
//    }
//  //--- Remove .DS_Store files
//    var i = 0
//    while i<currentLibraryContents.count {
//      let s = currentLibraryContents [i]
//      if (s as NSString).lastPathComponent == ".DS_Store" {
//        currentLibraryContents.remove (at: i)
//        i -= 1
//      }
//      i += 1
//    }
//  }
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("currentLibraryContents %@", currentLibraryContents)
//  }
////--- Get plist path
//  let plistFilePath = systemLibraryPath () + "/" + libraryDescriptionPLISTfilename ()
//  // NSLog ("plistFilePath %@", plistFilePath)
//  var libraryPLIST : NSMutableDictionary
//  if let dict = NSMutableDictionary (contentsOfFile:plistFilePath) {
//    libraryPLIST = dict
//  }else{
//    libraryPLIST = NSMutableDictionary ()
//  }
////--- Enumerate library files
//  var localLibraryDictionary = [String : PMCanariLibraryFileDescriptor] ()
//  for relativePath in currentLibraryContents {
//    let fullPath = systemLibraryPath () + "/" + relativePath
//    // NSLog ("fullPath in directory %@", fullPath)
//    if let contents = fm.contents (atPath: fullPath) {  // Returns nil for a directory
//      // NSLog ("read file %@", fullPath)
//      let fileDescriptor : PMCanariLibraryFileDescriptor
//      if let fd = localLibraryDictionary [relativePath] {
//        fileDescriptor = fd
//      }else{
//        fileDescriptor = PMCanariLibraryFileDescriptor (relativePath:relativePath)
//        localLibraryDictionary [relativePath] = fileDescriptor
//      }
//      let possibleElement : Any? = libraryPLIST.object (forKey: relativePath)
//      if let element = possibleElement as? NSDictionary {
//        if let rev = element.object (forKey: "revision") as? NSNumber {
//          fileDescriptor.mLocalRevision = rev.intValue
//        }else{
//          try throwError ("invalid local revision")
//        }
//        if let localSHA1 = element.object (forKey: "sha1") as? Data {
//          fileDescriptor.mLocalSHA1 = localSHA1
//        }else{
//          try throwError ("invalid local sha1")
//        }
//      }
//      fileDescriptor.mActualSHA1 = sha1 (contents)
//    }
//  }
//  // NSLog ("localLibraryDictionary %@", localLibraryDictionary)
//  return (localLibraryDictionary, libraryPLIST)
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func analyzeRepositoryXMLDocument (_ xmlDoc : XMLDocument,
//                                           localLibraryDictionary ioLocalLibraryDictionary : inout [String : PMCanariLibraryFileDescriptor]) throws {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
//  let rootElement : XMLElement? = xmlDoc.rootElement ()
//  // NSLog ("rootElement \(rootElement)")
//  let possibleEntries = try rootElement?.nodes (forXPath: "/lists/list/entry")
//  if let entries = possibleEntries {
//    for node in entries {
//      let possibleKindValues : [XMLNode]? = try node.nodes (forXPath: "./@kind")
//      let possibleNameValues : [XMLNode]? = try node.nodes (forXPath: "./name")
//      let possibleSizeValues : [XMLNode]? = try node.nodes (forXPath: "./size")
//      let possibleRevisionValues : [XMLNode]? = try node.nodes (forXPath: "./commit/@revision")
//      if let kindValues = possibleKindValues,
//        let nameValues = possibleNameValues,
//        let sizeValues = possibleSizeValues,
//        let revisionValues = possibleRevisionValues,
//        let kind = kindValues [0].stringValue, kind == "file",
//        let name = nameValues [0].stringValue,
//        let fileSizeString = sizeValues [0].stringValue,
//        let fileSize = Int64 (fileSizeString),
//        let revisionInRepositoryString = revisionValues [0].stringValue,
//        let revisionInRepository = Int (revisionInRepositoryString)
//      {
//        let fileDescriptor : PMCanariLibraryFileDescriptor
//        if let fd = ioLocalLibraryDictionary [name] {
//          fileDescriptor = fd
//        }else{
//          fileDescriptor = PMCanariLibraryFileDescriptor (relativePath:name)
//          ioLocalLibraryDictionary [name] = fileDescriptor
//        }
//        fileDescriptor.mSizeInRepository = fileSize
//        fileDescriptor.mRevisionInRepository = revisionInRepository
//      }
//    }
//  }
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private let ACCESS_EQ_SIZE_FOR_PROGRESS_INDICATOR : Int64 = 100_000

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func evaluateUpdateActions (_ inLocalLibraryDictionary : [String : PMCanariLibraryFileDescriptor]) -> (Int64, [PMCanariLibraryFileDescriptor]) {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
////--- Evaluate actions to perform
//  for descriptor in inLocalLibraryDictionary.values {
//    descriptor.defineUpdateAction ()
//  }
////--- Compute array of element with actions to perform
//  var actionsToPerformArray = [PMCanariLibraryFileDescriptor] ()
//  var cumulativeSize : Int64 = 0
//  for descriptor in inLocalLibraryDictionary.values {
//    switch descriptor.mEnumLibraryDownloadAction {
//    case .kLibraryDownloadActionNone :
//      break ;
//    default :
//      actionsToPerformArray.append (descriptor)
//      cumulativeSize += descriptor.mSizeInRepository + ACCESS_EQ_SIZE_FOR_PROGRESS_INDICATOR
//    }
//  }
////--- Sort in decreasing size of file in repository
//  actionsToPerformArray.sort (by: {$0.mSizeInRepository > $1.mSizeInRepository})
//  // NSLog ("%@", actionsToPerformArray) ;
//  return (cumulativeSize, actionsToPerformArray)
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//enum EnumLibraryDownloadAction {
//  case kLibraryDownloadActionNone
//  case kLibraryDownloadActionUpdate
//  case kLibraryDownloading
//  case kLibraryDownloadActionDownloaded
//  case kLibraryDownloadError
//  case kLibraryDownloadActionDelete
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private let kNoInfo = "—"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//@objc(PMCanariLibraryFileDescriptor)
//class PMCanariLibraryFileDescriptor : NSObject, EBUserClassNameProtocol, URLSessionTaskDelegate {
//
//  let mRelativePath : String
//  var mLocalRevision : Int? = nil
//  var mLocalSHA1 = Data ()
//  var mActualSHA1 = Data ()
//  var mSizeInRepository : Int64 = 0
//  var mRevisionInRepository : Int? = nil
//  var mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionNone
//  dynamic var mActionName = kNoInfo
//  var mSession : Foundation.URLSession? = nil
//
//  //····················································································································
//
//  init (relativePath : String) {
//    mRelativePath = relativePath
//    super.init ()
//    noteObjectAllocation (self)
//  }
//  
//  //····················································································································
//
//  deinit {
//    noteObjectDeallocation (self)
//  }
//
//  //····················································································································
//
//  func defineUpdateAction () {
//    if let revisionInRepository = mRevisionInRepository {
//      if (revisionInRepository != mLocalRevision) || (mLocalSHA1 != mActualSHA1) {
//        mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionUpdate
//        let fm = FileManager ()
//        let destinationPath = temporaryDownloadDirectory () + "/" + mRelativePath
//        if fm.fileExists (atPath: destinationPath) {
//          mEnumLibraryDownloadAction = .kLibraryDownloadActionDownloaded
//        }
//      }else{
//        mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionNone
//      }
//    }else{
//      mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionDelete
//    }
//  //---
//    switch mEnumLibraryDownloadAction {
//    case .kLibraryDownloadActionNone : mActionName = "None"
//    case .kLibraryDownloadActionUpdate : mActionName = "Download, update"
//    case .kLibraryDownloadActionDelete : mActionName = "Delete"
//    case .kLibraryDownloadActionDownloaded : mActionName = "Downloaded, update"
//    case .kLibraryDownloading : mActionName = "Downloading…"
//    case .kLibraryDownloadError : mActionName = "Error"
//    }
//  }
//
//  //····················································································································
//
//  func repository () -> String {
//    var s = kNoInfo
//    if let revisionInRepository = mRevisionInRepository {
//      if mSizeInRepository >= (1 << 10) {
//        s = "\(mSizeInRepository / (1 << 10)) KiB"
//      }else{
//        s = "\(mSizeInRepository) B"
//      }
//      s = "Rev. \(revisionInRepository) — " + s
//    }
//    return s
//  }
//  
//  //····················································································································
//
//  func local () -> String {
//    var s = kNoInfo
//    if let localRevision = mLocalRevision {
//      s = "Rev. \(localRevision)"
//      if mLocalSHA1 != mActualSHA1 {
//        s += " — modified"
//      }
//    }
//    return s
//  }
//  
//  //····················································································································
//
////  func launchDownload () {
////    if LOG_LIBRARY_UPDATES {
////      NSLog ("\(#function)")
////    }
////    let remotePath = "http://canarilibrary.rts-software.org/svn/v2/" + mRelativePath
////    // NSLog ("remotePath '%@'", remotePath)
////    if let url = URL (string:remotePath) {
////      let request = URLRequest (
////        url: url,
////        cachePolicy:.reloadIgnoringLocalCacheData,
////        timeoutInterval:60.0
////      )
////      let sessionConfiguration = URLSessionConfiguration.default 
////      let session = Foundation.URLSession (
////        configuration:sessionConfiguration,
////        delegate:self,
////        delegateQueue:nil
////      )
////      mSession = session
////      mEnumLibraryDownloadAction = .kLibraryDownloading
////      let sessionTask = session.downloadTask (with: request)
////      sessionTask.resume ()
////    }
////  }
//
//  //····················································································································
//
////  func urlSession (_ session: Foundation.URLSession, // NSURLSessionTaskDelegate method
////                   task : URLSessionTask,
////                   didReceive challenge: URLAuthenticationChallenge,
////                   completionHandler: @escaping (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
////    if LOG_LIBRARY_UPDATES {
////      NSLog ("\(#function)")
////    }
////    if challenge.previousFailureCount == 0 {
////      let newCredential = URLCredential (
////        user:"anonymous",
////        password:"",
////        persistence:URLCredential.Persistence.none
////      )
////      completionHandler (.useCredential, newCredential)
////    }else{
////      completionHandler (.cancelAuthenticationChallenge, nil)
////    }
////  }
//
//  //····················································································································
//
////  func urlSession (_ session: Foundation.URLSession,
////                   task: URLSessionTask,
////                   didCompleteWithError possibleError: Error?) {
////    if LOG_LIBRARY_UPDATES {
////      NSLog ("\(#function)")
////    }
////    if let error = possibleError {
////      DispatchQueue.main.async  {
////        self.mEnumLibraryDownloadAction = .kLibraryDownloadError
////        launchElementDownload (error)
////      }
////    }
////  }
//
//  //····················································································································
//
////  func urlSession (_ session: Foundation.URLSession,
////                   didBecomeInvalidWithError possibleError: Error?) {
////    if LOG_LIBRARY_UPDATES {
////      NSLog ("\(#function)")
////    }
////    if let error = possibleError {
////      DispatchQueue.main.async  {
////        self.mEnumLibraryDownloadAction = .kLibraryDownloadError
////        launchElementDownload (error)
////      }
////    }
////  }
//
//  //····················································································································
//
////  func URLSession(_ session: Foundation.URLSession, // NSURLSessionConfiguration method
////                  downloadTask: URLSessionDownloadTask,
////                  didWriteData bytesWritten: Int64,
////                  totalBytesWritten: Int64,
////                  totalBytesExpectedToWrite: Int64) {
////    if LOG_LIBRARY_UPDATES {
////      NSLog ("totalBytesWritten \(totalBytesWritten) for \(mRelativePath)")
////    }
////    DispatchQueue.main.async  {
////      self.mActionName = "Downloading — \((totalBytesWritten * 100) / self.mSizeInRepository)%"
////    }
////  }
//
//  //····················································································································
//
////  func URLSession (_ session: Foundation.URLSession,  // NSURLSessionConfiguration method
////                   downloadTask: URLSessionDownloadTask,
////                   didFinishDownloadingToURL location: URL) {
////    if LOG_LIBRARY_UPDATES {
////      NSLog ("\(#function)")
////    }
////    mSession?.finishTasksAndInvalidate ()
////    mSession = nil
////    switch mEnumLibraryDownloadAction {
////    case .kLibraryDownloading :
////      let fm = FileManager ()
////      do{
////        let temporaryURL = URL (fileURLWithPath:temporaryDownloadDirectory () + "/" + mRelativePath)
////        let temporaryDirectoryURL = temporaryURL.deletingLastPathComponent ()
////        if !fm.fileExists (atPath: temporaryDirectoryURL.path) {
////          try fm.createDirectory (atPath: temporaryDirectoryURL.path, withIntermediateDirectories:true, attributes:nil)
////        }
////        try fm.moveItem (atPath:location.path, toPath:temporaryURL.path)
////        DispatchQueue.main.async  {
////          self.mEnumLibraryDownloadAction = .kLibraryDownloadActionDownloaded
////          launchElementDownload (nil)
////        }
////      }catch let error {
////        DispatchQueue.main.async  {
////          self.mEnumLibraryDownloadAction = .kLibraryDownloadError
////          launchElementDownload (error)
////        }
////      }
////    default :
////      break
////    }
////  }
//
//  //····················································································································
//
////  func cancelDownloading () {
////    if let session = mSession {
////      session.invalidateAndCancel ()
////      mSession = nil
////    }
////  }
//
//  //····················································································································
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   P E R F O R M    L I B R A R Y    U P D A T E                                                                     *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func presentLibraryUpdateDialog (_ cumulativeSize : Int64,
//                                         actionArray : [PMCanariLibraryFileDescriptor],
//                                         libraryPLIST : NSMutableDictionary) {
//  if LOG_LIBRARY_UPDATES {
//    NSLog ("\(#function)")
//  }
//  // NSLog ("%d actions", actionArray.count)
////--- Perform library update in main thread
//  DispatchQueue.main.async  {
//  //--- Hide library checking window
//    gLibraryUpdateWindow?.orderOut (nil)
//  //--- Configure informative text in library update window
//    if actionArray.count == 1 {
//      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
//   }else{
//      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(actionArray.count) elements to update"
//    }
//  //--- Configure progress indicator in library update window
//    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
//    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = Double (cumulativeSize)
//    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
//    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
//  //--- Configure table view in library update window
//    gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
//      actionArray:actionArray,
//      libraryPLIST:libraryPLIST
//    )
//    gCanariLibraryUpdateController.bind ()
//  //--- Enable update button
//    g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
//  //--- Show library update window
//    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
//  }
//}

