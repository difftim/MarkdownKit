//
//  NSMutableParagraphStyle+Extenstion.swift
//  MarkdownKit
//
//  Created by jone on 2022/7/14.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import Foundation
import ObjectiveC

private var NSMutableParagraphStyleTag: UInt8 = 0

extension NSMutableParagraphStyle {
  open var tag: Int? {
    get {
      return objc_getAssociatedObject(self, &NSMutableParagraphStyleTag) as? Int
    }
    set {
      objc_setAssociatedObject(self, &NSMutableParagraphStyleTag, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }
}
