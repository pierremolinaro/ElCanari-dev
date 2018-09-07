
import Cocoa
import SystemConfiguration

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//---------------- ① Pour savoir si le repository a changé, on appelle :
//        curl -s -i -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse est :
//  ·······
//   Status: 200 OK
//  ·······
//   ETag: "22fc6b218e31128b7f802057f883393b"
//  ·······
//  [
//    {
//      "name": "master",
//      "commit": {
//        "sha": "20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//        "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/commits/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f"
//      }
//    }
//  ]
// Trois infos intéressantes dans la réponse :
//   - Status --> 200 : la requête s'est correctement déroulée
//   - commit / sha --> 20adfd48680e893e29a2e6bb94ebbbe88bb83e8f : valeur caractérisant le commit, utilisé dans les étapes suivantes
//   - Etag --> 22fc6b218e31128b7f802057f883393b : cette valeur permet d'interroger le serveur en lui indiquant 
// d'envoyer une réponse 304 si le repository n'a pas changé :
//        curl -s -i -L -H 'If-None-Match:"22fc6b218e31128b7f802057f883393b"' https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// On obtient alors la réponse suivante (sans donnée JSON)
//  ·······
//   Status: 304 Not Modified
//  ·······
// Si le contenu a changé, on obtient une réponse 200 comme précédemment, avec à la fin les données JSON.


//---------------- ② Pour obtenir la liste des fichiers du repository, on appelle :
// curl -s -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f?recursive=1
// La réponse est :
//{
//  "sha": "20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//  "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//  "tree": [
//  ·······
//    {
//      "path": "artworks",
//      "mode": "040000",
//      "type": "tree",
//      "sha": "aef45cfbb8a896426e0c49eda7ced76b5ce340c9",
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/aef45cfbb8a896426e0c49eda7ced76b5ce340c9"
//    },
//    {
//      "path": "artworks/electro_dragon.ElCanariArtwork",
//      "mode": "100644",
//      "type": "blob",
//      "sha": "e089e1c10538d15cda9de3e8a74b3bfd5ee1100a",
//      "size": 5850,
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/blobs/e089e1c10538d15cda9de3e8a74b3bfd5ee1100a"
//    },
//  ·······
// Le champ "tree" est un tableau, un élément par fichier ou répertoire. Pour chaque fichier "size" contient sa taille ;
// Attention "sha" n'est pas le SHA du fichier, mais de son blob.

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LOG_LIBRARY_UPDATES = false // When active, downloading is slowed down with sleep (1)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let repositoryDescriptionFile = "repository-description.plist"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

// https://stackoverflow.com/questions/13276195/mac-osx-how-can-i-grab-proxy-configuration-using-cocoa-or-even-pure-c-function

fileprivate func proxy () -> [String] {
  var proxyOption = [String] ()
  if let proxies : NSDictionary = SCDynamicStoreCopyProxies (nil) {
    // NSLog ("\(proxies)")
    let possibleHTTPSProxy = proxies ["HTTPSProxy"]
    let possibleHTTPSEnable = proxies ["HTTPSEnable"]
    let possibleHTTPSPort = proxies ["HTTPSPort"]
    if let HTTPSEnable : Int = possibleHTTPSEnable as? Int, HTTPSEnable == 1, let HTTPSProxy = possibleHTTPSProxy {
      var proxySetting : String = "\(HTTPSProxy)"
      if let HTTPSPort = possibleHTTPSPort {
        proxySetting += ":" + "\(HTTPSPort)"
      }
      // Swift.print ("proxy \(proxySetting)")
      proxyOption = ["--proxy", proxySetting]
    }
  }
  return proxyOption
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func performLibraryUpdate (_ inWindow : EBWindow?) {
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdate BEGIN (window \(String(describing:inWindow)))")
  }
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Show "Check for update" window
  inWindow?.makeKeyAndOrderFront (nil)
//-------- ① We start by checking if a repository did change using etag
  var possibleAlert : NSAlert? = nil
  if let etag = getRepositoryCurrentETag (), let _ = getRepositoryCommitSHA () {
    queryServerLastCommitUsingEtag (etag, &possibleAlert)
  }else{
    queryServerLastCommitWithNoEtag (&possibleAlert)
  }
//-------- ② Repository ETAG and commit SHA have been successfully retrieve,
//            now read of download the file list corresponding to this commit
  var repositoryFileDictionary = [String : CanariLibraryFileDescriptor] ()
  if possibleAlert == nil {
    readOrDownloadLibraryFileDictionary (&repositoryFileDictionary, &possibleAlert)
  }
//-------- ③ Repository has been successfully interrogated, then enumerate local system library
  var libraryFileDictionary = repositoryFileDictionary
  if possibleAlert == nil {
    try! appendLocalFilesToLibraryFileDictionary (&libraryFileDictionary)
  }
//-------- ④ Build library operations
  var libraryOperations = [LibraryOperationElement] ()
  if possibleAlert == nil {
    buildLibraryOperations (libraryFileDictionary, &libraryOperations)
  }
//-------- ⑤ Order out "Check for update" window
  let ok = possibleAlert == nil
  if let window = inWindow {
    if (possibleAlert == nil) && (libraryOperations.count == 0) {
      possibleAlert = NSAlert ()
      possibleAlert?.messageText = "The library is up to date"
      possibleAlert?.addButton (withTitle: "Ok")
    }
    if let alert = possibleAlert {
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : Int) in window.orderOut (nil) }
      )
    }else{
      window.orderOut (nil)
    }
  }
//-------- ⑥ If ok and there are update operations, perform library update
  if ok && (libraryOperations.count != 0) {
    performLibraryOperations (libraryOperations, repositoryFileDictionary)
  }else{
    enableItemsAfterCompletion ()
  }
//-------- Done
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdate DONE")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func enableItemsAfterCompletion () {
//--- Enable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitUsingEtag (_ etag : String, _ ioPossibleAlert : inout NSAlert?) {
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "-H", "If-None-Match:\"\(etag)\"",
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ] + proxy ())
  switch response {
  case .error (let errorCode) :
    ioPossibleAlert = NSAlert ()
    ioPossibleAlert?.messageText = "Cannot connect to the server"
    ioPossibleAlert?.addButton (withTitle: "Ok")
    ioPossibleAlert?.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
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
        }else if status == 200 { // Status 200 --> Ok, modified
          storeRepositoryETagAndLastCommitSHA (withResponse: response, &ioPossibleAlert)
        }
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitWithNoEtag (_ ioPossibleAlert : inout NSAlert?) {
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ] + proxy ())
  switch response {
  case .error (let errorCode) :
    let alert = NSAlert ()
    alert.messageText = "Cannot connect to the server"
    alert.addButton (withTitle: "Ok")
    alert.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    if let response = String (data: responseData, encoding: .utf8) {
      storeRepositoryETagAndLastCommitSHA (withResponse: response, &ioPossibleAlert)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryETagAndLastCommitSHA (withResponse inResponse : String, _ ioPossibleAlert : inout NSAlert?) {
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
      storeRepositoryCommitSHA (commitSHA)
    //--- Get ETag
      let c1 = components [0].components (separatedBy:"ETag: \"")
      let c2 = c1 [1].components (separatedBy:"\"")
      let etag = c2 [0]
      if LOG_LIBRARY_UPDATES {
        print ("-->  ETag \(etag)")
      }
      storeRepositoryCurrentETag (etag)
    }catch let error {
      ioPossibleAlert = NSAlert (error: error)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func readOrDownloadLibraryFileDictionary (
        _ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor],
        _ ioPossibleAlert : inout NSAlert?) {
  if LOG_LIBRARY_UPDATES {
    print ("---- readOrDownloadLibraryFileDictionary BEGIN")
  }
  if libraryDescriptionFileIsValid () {
    let f = systemLibraryPath () + "/" + repositoryDescriptionFile
    let data = try! Data (contentsOf: URL (fileURLWithPath: f))
    let propertyList = try! PropertyListSerialization.propertyList (from: data, format: nil) as! [[String : String]]
    for entry in propertyList {
      let filePath = entry ["path"]!
      let descriptor = CanariLibraryFileDescriptor (
        relativePath: filePath,
        repositorySHA: entry ["sha"]!,
        sizeInRepository: Int (entry ["size"]!)!,
        localSHA: ""
      )
      ioLibraryFileDictionary [filePath] = descriptor
    }
  }else{
    let repositoryCommitSHA = getRepositoryCommitSHA ()!
    let response = runShellCommandAndGetDataOutput ([
      "/usr/bin/curl",
      "-s", // Silent mode, do not show download progress
      "-L", // Follow redirections
      "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/\(repositoryCommitSHA)?recursive=1"
    ] + proxy ())
    switch response {
    case .error (let errorCode) :
      if errorCode != 6 { // Error #6 is 'no network connection'
        ioPossibleAlert = NSAlert ()
        ioPossibleAlert?.messageText = "Cannot connect to the server"
        ioPossibleAlert?.addButton (withTitle: "Ok")
        ioPossibleAlert?.informativeText = "Error code: \(errorCode)"
      }
    case .ok (let responseData) :
      do{
        let jsonObject = try JSONSerialization.jsonObject (with: responseData) as! NSDictionary
        let treeEntry = get (jsonObject, "tree", #line)
        if let fileDescriptionArray = treeEntry as? [[String : Any]] {
          for fileDescriptionDictionay in fileDescriptionArray {
            let filePath = fileDescriptionDictionay ["path"] as! String
            let ext = filePath.pathExtension
            if (ext == "ElCanariFont") || (ext == "ElCanariArtwork") {
              let descriptor = CanariLibraryFileDescriptor (
                relativePath: filePath,
                repositorySHA: "?", // fileDescriptionDictionay ["sha"] as! String,
                sizeInRepository: fileDescriptionDictionay ["size"] as! Int,
                localSHA: "?"
              )
              ioLibraryFileDictionary [filePath] = descriptor
            }
          }
        }else{
          print ("Entry is not an [[String : String]] object: \(String (describing: treeEntry))")
        }
      }catch let error {
        ioPossibleAlert = NSAlert (error: error)
      }
    }
  }
//--- Print ?
  if LOG_LIBRARY_UPDATES && (ioPossibleAlert == nil) {
    print ("*********** Repository contents (repositorySHA:size:path)")
    for (path, value) in ioLibraryFileDictionary {
      print ("  \(value.mRepositorySHA):\(value.mSizeInRepository):\(path)")
    }
  }
//------------------
  if LOG_LIBRARY_UPDATES {
    print ("---- readOrDownloadLibraryFileDictionary END")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func appendLocalFilesToLibraryFileDictionary (_ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor]) throws {
  if LOG_LIBRARY_UPDATES {
    print ("---- appendLocalFilesToLibraryFileDictionary")
  }
//--- Get library files
  let fm = FileManager ()
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
        if let descriptor = ioLibraryFileDictionary [filePath] {
          let localSHA = try computeFileSHA (filePath)
          let newDescriptor = CanariLibraryFileDescriptor (
            relativePath: descriptor.mRelativePath,
            repositorySHA: descriptor.mRepositorySHA,
            sizeInRepository: descriptor.mSizeInRepository,
            localSHA: localSHA
          )
          ioLibraryFileDictionary [filePath] = newDescriptor
        }else{
          let descriptor = CanariLibraryFileDescriptor (
            relativePath: filePath,
            repositorySHA: "",
            sizeInRepository: 0,
            localSHA: "?"
          )
          ioLibraryFileDictionary [filePath] = descriptor
        }
      }
    }
  }
  if LOG_LIBRARY_UPDATES {
    print ("*********** Library descriptor contents (local SHA:repository SHA:SHA:repository size:file path)")
    for descriptor in ioLibraryFileDictionary.values {
      print ("  \(descriptor.mLocalSHA):\(descriptor.mRepositorySHA):\(descriptor.mSizeInRepository):\(descriptor.mRelativePath)")
    }
    print ("---- appendLocalFilesToLibraryFileDictionary END")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func buildLibraryOperations (
        _ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor],
        _ outLibraryOperations : inout [LibraryOperationElement]) {
  for descriptor in inLibraryFileDictionary.values {
    if descriptor.mRepositorySHA == "" {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: 0, operation: .delete)
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "") {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: descriptor.mSizeInRepository, operation: .download)
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: descriptor.mSizeInRepository, operation: .update)
      outLibraryOperations.append (element)
    }
  }
  if LOG_LIBRARY_UPDATES {
    print ("*********** Library operations (operation:file path:size in repository)")
    for op in outLibraryOperations {
      print ("  \(op.mOperation):\(op.mRelativePath):\(op.mSizeInRepository)")
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryOperations (
   _ inLibraryOperations : [LibraryOperationElement],
   _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]) {
//--- Perform library update in main thread
  DispatchQueue.main.async  {
  //--- Configure informative text in library update window
    if inLibraryOperations.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(inLibraryOperations.count) elements to update"
    }
    var progressMaxValue = 0.0
    for action in inLibraryOperations {
      progressMaxValue += action.maxIndicatorValue
    }
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = progressMaxValue
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = CanariLibraryUpdateController (inLibraryOperations, inRepositoryFileDictionary)
    gCanariLibraryUpdateController.bind ()
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum LibraryOperation {
  case download
  case update
  case delete
  case deleteRegistered
  case downloadError (Int32)
  case downloading (Int)
  case downloaded (Data)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryOperationElement : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  let mSizeInRepository : Int

  var mOperation : LibraryOperation {
    willSet {
      self.willChangeValue (forKey: "actionName")
    }
    didSet {
      self.didChangeValue (forKey: "actionName")
    }
  }

  //····················································································································

  init (relativePath inRelativePath : String,
        sizeInRepository inSizeInRepository : Int,
        operation inOperation : LibraryOperation) {
    mRelativePath = inRelativePath
    mOperation = inOperation
    mSizeInRepository = inSizeInRepository
    super.init ()
  }


  //····················································································································
  // Values for progress indicator
  //····················································································································

  var maxIndicatorValue : Double { return Double (self.mSizeInRepository + 10_000) }

  var currentIndicatorValue : Double {
    switch self.mOperation {
    case .download, .update, .delete, .downloadError :
      return 0.0
    case .downloading (let progress) :
      return Double (progress) * self.maxIndicatorValue / 100.0
    case .downloaded (_), .deleteRegistered :
      return self.maxIndicatorValue
    }
  }

  //····················································································································
  // Dynamic properties for Cocoa bindings
  //····················································································································

  @objc dynamic var relativePath : String { return self.mRelativePath }

  @objc dynamic var actionName : String {
    switch self.mOperation {
    case .download :
      return "Download (\(mSizeInRepository) bytes)"
    case .update :
      return "Update (\(mSizeInRepository) bytes)"
    case .delete :
      return "Delete"
    case .deleteRegistered :
      return "Delete registered"
    case .downloadError (let errorCode) :
      return "Error \(errorCode)"
    case .downloaded (_) :
      return "Downloaded"
    case .downloading (let progress) :
      return "Downloading… (\(progress)%)"
    }
  }

  //····················································································································

  func beginAction (_ inController : CanariLibraryUpdateController) {
    if inController.shouldCancel {
      inController.elementActionDidEnd (self, 0)
    }else{
      switch mOperation {
      case .download, .update :
        let repositoryCommitSHA = getRepositoryCommitSHA ()!
        self.mOperation = .downloading (0)
        let task = Process ()
        let concurrentQueue = DispatchQueue (label: "Queue \(relativePath)", attributes: .concurrent)
        concurrentQueue.async {
        //--- Define task
          task.launchPath = "/usr/bin/curl"
          task.arguments = [
            "-s", // Silent mode, do not show download progress
            "-L", // Follow redirections
            "https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/\(repositoryCommitSHA)/\(self.mRelativePath)",
          ] + proxy ()
          let pipe = Pipe ()
          task.standardOutput = pipe
          task.standardError = pipe
          let fileHandle = pipe.fileHandleForReading
        //--- Launch
          task.launch ()
          var data = Data ()
          var hasData = true
        //--- Loop until all data is got, or download is cancelled
          while hasData && !inController.shouldCancel {
            let newData = fileHandle.availableData
            hasData = newData.count > 0
            data.append (newData)
            DispatchQueue.main.async {
              self.mOperation = .downloading (data.count * 100 / self.mSizeInRepository)
              inController.updateProgressIndicator ()
            }
            if LOG_LIBRARY_UPDATES {
              sleep (1)
            }
          }
          if inController.shouldCancel {
            task.terminate ()
          }
        //--- Task completed
          task.waitUntilExit ()
          fileHandle.closeFile ()
          let status = task.terminationStatus
          if inController.shouldCancel || (status != 0) {
            self.mOperation = .downloadError (status)
          }else{
            self.mOperation = .downloaded (data)
          }
          DispatchQueue.main.async { inController.elementActionDidEnd (self, status) }
        }
      case .delete :
        self.mOperation = .deleteRegistered
        inController.elementActionDidEnd (self, 0)
      case .downloadError, .downloaded, .downloading, .deleteRegistered :
        inController.elementActionDidEnd (self, 0)
      }
    }
  }

  //····················································································································

  func commit () throws {
    switch self.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      ()
    case .deleteRegistered :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
      try fm.removeItem (atPath: fullFilePath)
    case .downloaded (let data) :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
    //--- Create directory
      let destinationDirectory = fullFilePath.deletingLastPathComponent
      if !fm.fileExists(atPath: destinationDirectory) { // If directory does not exist, creta it
        if LOG_LIBRARY_UPDATES {
          NSLog ("Create dir '\(destinationDirectory)'")
        }
        try fm.createDirectory (atPath:destinationDirectory, withIntermediateDirectories:true, attributes:nil)
      }else if fm.fileExists (atPath: fullFilePath) { // If file exists, delete it
        try fm.removeItem (atPath:fullFilePath)
      }
    //--- Write file
      try data.write(to: URL (fileURLWithPath: fullFilePath))
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = CanariLibraryUpdateController ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariLibraryUpdateController : EBObject {

  let mArrayController = NSArrayController ()

  var mCurrentActionArray : [LibraryOperationElement]
  var mCurrentParallelActionCount = 0
  var mNextActionIndex = 0 // Index of mActionArray

  let mActionArray : [LibraryOperationElement]
  let mRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]

  //····················································································································
  //   Init
  //····················································································································

  init (_ inActionArray : [LibraryOperationElement],
        _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]) {
    mCurrentActionArray = inActionArray
    mActionArray = inActionArray
    mRepositoryFileDictionary = inRepositoryFileDictionary
    super.init ()
  }

  //····················································································································

  override init () {
    mCurrentActionArray = []
    mActionArray = []
    mRepositoryFileDictionary = [:]
    super.init ()
  }
  
  //····················································································································
  //   Handling error or cancel
  //····················································································································

  private var mErrorCode : Int32 = 0 // No error

  //····················································································································

  var shouldCancel : Bool { return mErrorCode != 0 }

  //····················································································································

  func cancel () {
    self.mErrorCode = -1
  }

  //····················································································································
  //  Cocoa bindings
  //····················································································································

  func bind () {
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn (withIdentifier: "name")?.bind (
        "value",
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.relativePath",
        options:nil
      )
      tableView.tableColumn (withIdentifier: "action")?.bind (
        "value",
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.actionName",
        options:nil
      )
      self.mArrayController.content = self.mCurrentActionArray
    }
  }
  
  //····················································································································

  func unbind () { //--- Remove bindings
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "action")?.unbind ("value")
      mArrayController.content = nil
    }
  }

  //····················································································································
  //   launchElementDownload
  //····················································································································

  fileprivate func launchElementDownload () {
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }
  }

  //····················································································································
  //   elementActionDidEnd
  //····················································································································

  fileprivate func elementActionDidEnd (_ inElement : LibraryOperationElement, _ inErrorCode : Int32) {
    if (self.mErrorCode == 0) && (inErrorCode != 0) {
       mErrorCode = inErrorCode
    }
  //--- Decrement parallel action count
    self.mCurrentParallelActionCount -= 1
  //--- Remove corresponding entry in table view
    if let idx = self.mCurrentActionArray.index (of: inElement) {
      self.mCurrentActionArray.remove (at: idx)
      self.mArrayController.content = self.mCurrentActionArray
    }
  //--- Update progress indicator
    self.updateProgressIndicator ()
  //--- Update remaining operation count
    if self.mCurrentActionArray.count == 0 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "Commiting changes…"
    }else if self.mCurrentActionArray.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(self.mCurrentActionArray.count) elements to update"
    }
  //--- Launch next action, if any
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }else if self.mCurrentParallelActionCount == 0 { // Last download did end
      DispatchQueue.main.async { commitAllActions (self.mActionArray, self.mRepositoryFileDictionary) }
    }
  }

  //····················································································································

  fileprivate func updateProgressIndicator () {
    var progressCurrentValue = 0.0
    for action in self.mActionArray {
      progressCurrentValue += action.currentIndicatorValue
    }
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = progressCurrentValue
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Launch parallel downloads
  for _ in 1...parallelDownloadCount {
    gCanariLibraryUpdateController.launchElementDownload ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Cancel current downloadings
  gCanariLibraryUpdateController.cancel ()
  startLibraryUpdate ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func commitAllActions (_ inActionArray : [LibraryOperationElement],
                               _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]) {
//--- Update UI
  gCanariLibraryUpdateController.unbind ()
  gCanariLibraryUpdateController = CanariLibraryUpdateController ()
//--- Commit change only if all actions has been successdully completed
  var repositoryFileDictionary = inRepositoryFileDictionary
  var performCommit = true
  for action in inActionArray {
    switch action.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      performCommit = false
    case .deleteRegistered :
      ()
    case .downloaded (let data) :
      var descriptor = repositoryFileDictionary [action.mRelativePath]!
      descriptor.mRepositorySHA = sha1 (data)
      repositoryFileDictionary [action.mRelativePath] = descriptor
    }
  }
//--- Perform commit
  if !performCommit {
    g_Preferences?.mLibraryUpdateWindow?.orderOut (nil)
    enableItemsAfterCompletion ()
  }else{
    if let window = g_Preferences?.mLibraryUpdateWindow {
      do{
        for action in inActionArray {
          try action.commit ()
        }
      //--- Delete orphean directories
        try deleteOrphanDirectories ()
      //--- Write library description plist file
        try writeLibraryDescriptionPlistFile (repositoryFileDictionary)
      //--- Completed!
        let alert = NSAlert ()
        alert.messageText = "Update completed, the library is up to date"
        alert.addButton (withTitle: "Ok")
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : Int) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }catch let error {
        let alert = NSAlert ()
        alert.messageText = "Cannot commit changes"
        alert.addButton (withTitle: "Ok")
        alert.informativeText = "A file system operation returns \(error) error"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : Int) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    deleteOrphanDirectories
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func deleteOrphanDirectories () throws {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  let fm = FileManager ()
  let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
  var directoryArray = [String] ()
  for relativePath in currentLibraryContents {
    let fullPath = systemLibraryPath () + "/" + relativePath
    var isDirectory : ObjCBool = false
    fm.fileExists (atPath: fullPath, isDirectory: &isDirectory)
    if (isDirectory.boolValue) {
      directoryArray.append (fullPath)
    }
  }
  directoryArray.sort ()
  if LOG_LIBRARY_UPDATES {
    NSLog ("directories to delete '\(directoryArray.description)")
  }
  var i=directoryArray.count-1
  while i>=0 {
    let fullPath = directoryArray [i]
    var currentDirectoryContents = try fm.contentsOfDirectory (atPath: fullPath)
  //--- Remove .DS_Store files
    var j=0
    while j<currentDirectoryContents.count {
      let s = currentDirectoryContents [j]
      if s == ".DS_Store" {
        currentDirectoryContents.remove (at: j)
        j -= 1
      }
      j += 1
    }
    if (currentDirectoryContents.count == 0) {
      if LOG_LIBRARY_UPDATES {
        NSLog ("delete orphean at '\(fullPath)")
      }
      try fm.removeItem (atPath: fullPath)
    }
    i -= 1
  }
  enableItemsAfterCompletion ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func writeLibraryDescriptionPlistFile (_ inRepositoryFileDictionary: [String : CanariLibraryFileDescriptor]) throws {
  if LOG_LIBRARY_UPDATES {
    print ("--- writeLibraryDescriptionPlistFile")
    print ("*********** Repository contents (repositorySHA:size:path)")
    for (path, value) in inRepositoryFileDictionary {
      print ("  \(value.mRepositorySHA):\(value.mSizeInRepository):\(path)")
    }
  }
//--- Write plist file
  var dictionaryArray = [[String : String]] ()
  for descriptor in inRepositoryFileDictionary.values {
    var dictionary = [String : String] ()
    dictionary ["path"] = descriptor.mRelativePath
    dictionary ["size"] = "\(descriptor.mSizeInRepository)"
    dictionary ["sha"] = descriptor.mRepositorySHA
    dictionaryArray.append (dictionary)
  }
  let data : Data = try PropertyListSerialization.data (fromPropertyList: dictionaryArray, format: .binary, options: 0)
  let f = systemLibraryPath () + "/" + repositoryDescriptionFile
  try data.write (to: URL (fileURLWithPath: f))
  storeRepositoryFileSHA (sha1 (data))
//---
  if LOG_LIBRARY_UPDATES {
    print ("--- writeLibraryDescriptionPlistFile DONE")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  var mRepositorySHA : String
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

private func sha1 (_ inData : Data) -> String {
  let transform = SecDigestTransformCreate (kSecDigestSHA1, 0, nil)
  SecTransformSetAttribute (transform, kSecTransformInputAttributeName, inData as CFTypeRef, nil)
  let shaValue = SecTransformExecute (transform, nil) as! Data
  var s = ""
  for byte in shaValue {
    s += "\(String (byte, radix:16, uppercase: false))"
  }
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of a library file
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func computeFileSHA (_ filePath : String) throws -> String {
  let absoluteFilePath = systemLibraryPath () + "/" + filePath
  let data = try Data (contentsOf: URL (fileURLWithPath: absoluteFilePath))
  return sha1 (data)
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
  return UserDefaults ().string (forKey: "library-repository-etag")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryCurrentETag (_ inETag : String) {
  UserDefaults ().set (inETag, forKey: "library-repository-etag")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCommitSHA () -> String? { // Returns nil if no current commit
  return UserDefaults ().string (forKey: "library-repository-commit-sha")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryCommitSHA(_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: "library-repository-commit-sha")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryFileSHA(_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: "library-repository-file-sha")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func libraryDescriptionFileIsValid () -> Bool {
  let possibleLibraryDescriptionFileSHA = UserDefaults ().string (forKey: "library-repository-file-sha")
  if let libraryDescriptionFileSHA = possibleLibraryDescriptionFileSHA {
    do{
      let actualSHA = try computeFileSHA (repositoryDescriptionFile)
      return actualSHA == libraryDescriptionFileSHA
    }catch _ {
    }
  }
  return false
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   get fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func get (_ inObject: Any?, _ key : String, _ line : Int) -> Any? {
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
