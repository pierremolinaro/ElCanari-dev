#! /usr/bin/swift

//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
// Product Kind
//--------------------------------------------------------------------------------------------------

enum ProductKind {
  case release
  case debug

  var string : String {
    switch self {
      case .release : return "Release"
      case .debug   : return "Debug"
    }
  }
}

//--------------------------------------------------------------------------------------------------

let BUILD_KIND = ProductKind.release

//--------------------------------------------------------------------------------------------------
// Version ElCanari
//--------------------------------------------------------------------------------------------------

let VERSION_CANARI = "1.6.2"
let MAC_OS_MINIMUM_VERSION = "10.15"
let NOTES : [String] = [
]
let BUGFIXES : [String] = [
  "Correction de la vérification de l'isolation des pads esclaves sans net",
  "Schéma : essayer d'établir une piste à partir d'un point de connexion marqué nc d'un symbol est maintenant correctement inhibé"
]
let CHANGES : [String] = [
  "Le manuel d'utilisation est maintenant dans la librairie système",
  "Sparkle 2.3.0"
]
let NEWS : [String] = [
]

//--------------------------------------------------------------------------------------------------
//   FOR PRINTING IN COLOR
//--------------------------------------------------------------------------------------------------

let BLACK   = "\u{1B}[0;30m"
let RED     = "\u{1B}[0;31m"
let GREEN   = "\u{1B}[0;32m"
let YELLOW  = "\u{1B}[0;33m"
let BLUE    = "\u{1B}[0;34m"
let MAGENTA = "\u{1B}[0;35m"
let CYAN    = "\u{1B}[0;36m"
let ENDC    = "\u{1B}[0;0m"
let BOLD    = "\u{1B}[0;1m"
let UNDERLINE = "\u{1B}[4m"
let BOLD_MAGENTA = BOLD + MAGENTA
let BOLD_BLUE = BOLD + BLUE
let BOLD_GREEN = BOLD + GREEN
let BOLD_RED = BOLD + RED

//--------------------------------------------------------------------------------------------------
//   runCommand
//--------------------------------------------------------------------------------------------------

func runCommand (_ cmd : String, _ args : [String]) {
  var str = "+ " + cmd
  for s in args {
    str += " " + s
  }
  print (BOLD_MAGENTA + str + ENDC)
  let task = Process.launchedProcess (launchPath: cmd, arguments: args)
  task.waitUntilExit ()
  let status = task.terminationStatus
  if status != 0 {
    print (BOLD_RED + "Command line tool '\(cmd)' returns error \(status)" + ENDC)
    exit (status)
  }
}

//--------------------------------------------------------------------------------------------------
//   runHiddenCommand
//--------------------------------------------------------------------------------------------------

func runHiddenCommand (_ cmd : String, _ args : [String]) -> String {
  var str = "+ " + cmd
  for s in args {
    str += " " + s
  }
  print (BOLD_MAGENTA + str + ENDC)
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
    hasData = newData.count > 0
    data.append (newData)
  }
  task.waitUntilExit ()
  let status = task.terminationStatus
  if status != 0 {
    print (BOLD_RED + "Error \(status)" + ENDC)
    exit (status)
  }
  return String (data: data, encoding: .ascii)!
}

//--------------------------------------------------------------------------------------------------
//   dictionaryFromJsonFile
//--------------------------------------------------------------------------------------------------

struct VersionDescriptor : Codable {
  var bugfixes = [String] ()
  var notes = [String] ()
  var length = ""
  var edSignature = ""
  var news = [String] ()
  var changes = [String] ()
  var date = ""
  var osmin = ""
}

//--------------------------------------------------------------------------------------------------

let fm = FileManager ()
//-------------------- Get script absolute path
let scriptDir = URL (fileURLWithPath: CommandLine.arguments [0]).deletingLastPathComponent ().path
print ("scriptDir \(scriptDir)")
//-------------------- Supprimer une distribution existante
let DISTRIBUTION_DIR = scriptDir + "/../EL_CANARI_DISTRIBUTION_" + VERSION_CANARI
while fm.fileExists (atPath: DISTRIBUTION_DIR) {
  runCommand ("/bin/rm", ["-fr", DISTRIBUTION_DIR])
}
//-------------------- Créer le répertoire contenant la distribution
runCommand ("/bin/mkdir", [DISTRIBUTION_DIR])
fm.changeCurrentDirectoryPath (DISTRIBUTION_DIR)
//-------------------- Importer ElCanari
let CANARI_DIR = "ElCanari-dev"
//runCommand ("/bin/rm", ["-f", "archive.zip"])
runCommand ("/bin/rm", ["-fr", CANARI_DIR])
runCommand ("/usr/local/bin/git", ["clone", "https://github.com/pierremolinaro/ElCanari-dev.git"])
//runCommand ("/usr/bin/curl", ["--fail", "-L", "https://github.com/pierremolinaro/ElCanari-dev/archive/master.tar.gz", "-o", "archive.tar.gz"])
//runCommand ("/usr/bin/tar", ["xvfz", "archive.tar.gz"])
//runCommand ("/bin/rm", ["archive.tar.gz"])
fm.changeCurrentDirectoryPath (DISTRIBUTION_DIR + "/" + CANARI_DIR)
//-------------------- Obtenir l'année
let ANNEE = Calendar.current.component (.year, from: Date ())
print ("ANNÉE : \(ANNEE)")
do{
//-------------------- Obtenir le SHA du dernier commit
  var sha = runHiddenCommand ("/usr/local/bin/git", ["rev-parse", "--short", "HEAD"])
  _ = sha.removeLast () // Remove trailing LF
//  let sha = runHiddenCommand ("/usr/local/bin/git", ["log", "-n1", "--format=format:\"%H\""])
//  Swift.print ("sha \(sha)")
//-------------------- Écrire le SHA
  let fileRelativePath = "ElCanari/resources/Credits.rtf"
  let str : String = try! String (contentsOf: URL (fileURLWithPath: fileRelativePath), encoding: .utf8)
  let components = str.components (separatedBy: "$SHA_GITHUB$")
  let str2 = components.joined (separator: sha)
  try! str2.write (to: URL (fileURLWithPath: fileRelativePath), atomically: true, encoding: .utf8)
//-------------------- Obtenir le numéro de build
  let plistFileFullPath = DISTRIBUTION_DIR + "/" + CANARI_DIR + "/ElCanari/application/Info-" + BUILD_KIND.string + ".plist"
  let data : Data = try Data (contentsOf: URL (fileURLWithPath: plistFileFullPath))
  var plistDictionary : [String : Any]
  if let d = try PropertyListSerialization.propertyList (from: data, format: nil) as? [String : Any] {
    plistDictionary = d
  }else{
    print (RED + "line \(#line) : object is not a dictionary" + ENDC)
    exit (1)
  }
//--- Date de construction
  let dateConstruction = Date ()
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "en_US")
  dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdYYYY") // set template after setting locale
//--- Mettre à jour les numéros de version dans la plist
  plistDictionary ["CFBundleVersion"] = VERSION_CANARI + ", " + dateFormatter.string (from: dateConstruction)// + ", build " + buildString
  plistDictionary ["CFBundleShortVersionString"] = VERSION_CANARI
  let plistNewData = try PropertyListSerialization.data (fromPropertyList: plistDictionary, format: .binary, options: 0)
  try plistNewData.write (to: URL (fileURLWithPath: plistFileFullPath), options: .atomic)
//-------------------- Compiler le projet Xcode
  let debutCompilation = Date ()
  runCommand ("/bin/rm", ["-fr", "build"])
  runCommand ("/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
              ["-target", "ElCanari-" + BUILD_KIND.string,
               "-configuration", BUILD_KIND.string
              ])
  let DureeCompilation = Date ().timeIntervalSince (debutCompilation)
  let PRODUCT_NAME : String
  switch BUILD_KIND {
  case .debug :
    PRODUCT_NAME = "ElCanari-Debug"
  case .release:
    PRODUCT_NAME = "ElCanari"
  }
//-------------------- Copier l'application dans la racine du répertoire de distribution
  runCommand ("/bin/cp", ["-r", "build/" + BUILD_KIND.string + "/" + PRODUCT_NAME + ".app", DISTRIBUTION_DIR])
//-------------------- Construction package
  let packageFile = PRODUCT_NAME + "-" + VERSION_CANARI + ".pkg"
  runCommand ("/usr/bin/productbuild", ["--component-compression", "auto", "--component", "build/" + BUILD_KIND.string + "/" + PRODUCT_NAME + ".app", "/Applications", packageFile])
  runCommand ("/bin/cp", [packageFile, DISTRIBUTION_DIR])
//-------------------- Créer l'archive de Cocoa canari
  let nomArchive = PRODUCT_NAME + "-" + VERSION_CANARI
  runCommand ("/bin/mkdir", [nomArchive])
  runCommand ("/bin/cp", [packageFile, nomArchive])
  runCommand ("/usr/bin/hdiutil", ["create", "-srcfolder", nomArchive, nomArchive + ".dmg", "-fs", "HFS+"])
  runCommand ("/bin/mv", [nomArchive + ".dmg", "../" + nomArchive + ".dmg"])
//-------------------- Supprimer le fichier .pkg
  runCommand ("/bin/rm", [DISTRIBUTION_DIR + "/" + packageFile])
//-------------------- Calculer la clé de la somme de contrôle de l'archive DMG pour Sparkle
  let signature = runHiddenCommand ("./distribution-el-canari/sign_update", ["../" + nomArchive + ".dmg"])
  // print ("cleArchive '\(signature)'")
  var edSignature = ""
  var dmgLength = ""
  var ok = false
  let c1 = signature.components (separatedBy: "sparkle:edSignature=\"")
  if (c1.count == 2) && (c1 [0] == "") {
    let c2 = c1 [1].components (separatedBy: "\" length=\"")
    if c2.count == 2 {
      edSignature = c2 [0]
      let c3 = c2 [1].components (separatedBy: "\"\n")
      if c3.count == 2 {
        dmgLength = c3 [0]
        ok = true
      }
    }
  }
  if ok {
    print ("edSignature: \(edSignature) ")
    print ("length: \(dmgLength) ")
  }else{
    print (RED + "Error line \(#line)" + ENDC)
    exit (1)
  }
//-------------------- Construire le fichier json
  var versionDescriptor = VersionDescriptor ()
  versionDescriptor.edSignature = edSignature
  versionDescriptor.length = dmgLength
  versionDescriptor.notes = NOTES
  versionDescriptor.bugfixes = BUGFIXES
  versionDescriptor.changes = CHANGES
  versionDescriptor.news = NEWS
  versionDescriptor.date = ISO8601DateFormatter ().string (from: dateConstruction)
  versionDescriptor.osmin = MAC_OS_MINIMUM_VERSION
  let encoder = JSONEncoder ()
  encoder.outputFormatting = .prettyPrinted
  let jsonData = try encoder.encode (versionDescriptor)
  let nomJSON = DISTRIBUTION_DIR + "/" + PRODUCT_NAME + "-" + VERSION_CANARI + ".json"
  try jsonData.write (to: URL (fileURLWithPath: nomJSON), options: .atomic)
//--- Vérififer l'existence de certificats
//  runCommand ("security", ["find-identity", "-p", "basic", "-v"])
//--- Vérifier la signature
  let argumentsSignatureCode = [
    "-dv",
//    "--digest-algorithm=sha1,sha256",
    "--verbose=4",
    DISTRIBUTION_DIR + "/" + CANARI_DIR + "/build/" + BUILD_KIND.string + "/" + PRODUCT_NAME + ".app"
  ]
  runCommand ("/usr/bin/codesign", argumentsSignatureCode)
//--- Supprimer les répertoires intermédiaires
  fm.changeCurrentDirectoryPath (DISTRIBUTION_DIR)
  while fm.fileExists (atPath: DISTRIBUTION_DIR + "/" + CANARI_DIR) {
    runCommand ("/bin/rm", ["-fr", DISTRIBUTION_DIR + "/" + CANARI_DIR])
  }
  //---
  let durée = Int (DureeCompilation)
  print ("Durée de compilation : \(durée / 60) min \(durée % 60) s")
}catch (let error) {
  print ("Exception \(error)")
}

//--------------------------------------------------------------------------------------------------
