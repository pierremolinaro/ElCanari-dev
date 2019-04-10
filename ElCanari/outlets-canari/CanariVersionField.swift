//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariVersionField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  version binding
  //····················································································································

  private var mVersionController : EBSimpleController? = nil

  //····················································································································

  func bind_version (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mVersionController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  func unbind_version () {
    self.mVersionController?.unregister ()
    self.mVersionController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty :
      self.enableFromValueBinding (false)
      self.stringValue = "—"
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.stringValue = String (v)
    case .multiple :
      self.enableFromValueBinding (false)
      self.stringValue = "—"
    }
  }

  //····················································································································
  //  versionShouldChange binding
  //····················································································································

  private var mVersionShouldChangeController : EBSimpleController? = nil

  //····················································································································

  func bind_versionShouldChange (_ model : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mVersionShouldChangeController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
     )
  }

  //····················································································································

  func unbind_versionShouldChange () {
    self.mVersionShouldChangeController?.unregister ()
    self.mVersionShouldChangeController = nil
  }

  //····················································································································
  // NSColor.systemBlue is not defined in 10.9
  // We use 10.10 setting for getting systemBlue RGB components:
  //      let c = NSColor.systemBlue.usingColorSpace (.sRGB)!
  //      Swift.print ("RGB \(c.redComponent) \(c.greenComponent) \(c.blueComponent)")

  private func update (from model : EBReadOnlyProperty_Bool) {
    switch model.prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      if v {
        self.textColor = NSColor (
          calibratedRed: 0.10588235294117647,
          green: 0.6784313725490196,
          blue: 0.9725490196078431,
          alpha: 1.0
        )
      }else{
        self.textColor = NSColor.black
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
