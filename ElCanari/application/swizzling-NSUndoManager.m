//
//  swizzling-NSUndoManager.m
//  ElCanari-Debug
//
//  Created by Pierre Molinaro on 11/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@interface NSUndoManager (MySwizzlingNSUndoManager)

@end

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@implementation NSUndoManager (MySwizzlingNSUndoManager)

  //····················································································································

  - (void) swizzling_disableUndoRegistration {
    NSLog (@"swizzling_disableUndoRegistration") ;
    [self swizzling_disableUndoRegistration] ;
  }

  //····················································································································

  - (void) swizzling_enableUndoRegistration {
    NSLog (@"swizzling_enableUndoRegistration") ;
    [self swizzling_enableUndoRegistration] ;
  }

  //····················································································································

  - (void) swizzling_registerUndoWithTarget:(id) target selector:(SEL) selector object:(id) anObject {
    NSLog (@"registerUndoWithTarget: %@ %@", target, NSStringFromSelector (selector)) ;
    [self swizzling_registerUndoWithTarget: target selector: selector object: anObject] ;
  }

  //····················································································································

  + (void) load {
    NSLog (@"MySwizzlingNSUndoManager load") ;
  //---
    Method original = class_getInstanceMethod (self, @selector (swizzling_disableUndoRegistration));
    Method swizzled = class_getInstanceMethod (self, @selector (disableUndoRegistration));
    method_exchangeImplementations (original, swizzled) ;
  //---
    original = class_getInstanceMethod (self, @selector (swizzling_enableUndoRegistration));
    swizzled = class_getInstanceMethod (self, @selector (enableUndoRegistration));
    method_exchangeImplementations (original, swizzled) ;
  //--
    original = class_getInstanceMethod (self, @selector (swizzling_registerUndoWithTarget:selector:object:));
    swizzled = class_getInstanceMethod (self, @selector (registerUndoWithTarget:selector:object:));
    method_exchangeImplementations (original, swizzled) ;
  }

  //····················································································································

@end

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
