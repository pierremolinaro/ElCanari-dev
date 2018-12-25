//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariVersionField) class CanariVersionField : NSTextField, EBUserClassNameProtocol {

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

  private var mVersionController : EBReadOnlyController_Int? = nil

  //····················································································································

  func bind_version (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mVersionController = EBReadOnlyController_Int (
      model: model,
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

  private var mVersionShouldChangeController : EBReadOnlyController_Bool? = nil

  //····················································································································

  func bind_versionShouldChange (_ model : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mVersionShouldChangeController = EBReadOnlyController_Bool (
      model: model,
      callBack: { [weak self] in self?.update (from: model) }
     )
  }

  //····················································································································

  func unbind_versionShouldChange () {
    self.mVersionShouldChangeController?.unregister ()
    self.mVersionShouldChangeController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Bool) {
    switch model.prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      self.textColor = v ? NSColor.systemBlue : NSColor.black
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
