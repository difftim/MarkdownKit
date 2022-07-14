//
//  MarkdownCode+UIKit.swift
//  MarkdownKit
//
//  Created by Bruno Oliveira on 31/01/2019.
//  Copyright © 2019 Ivan Bruel. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public extension MarkdownInlineCode {
  static var defaultHighlightColor: UIColor = {
    if #available(iOSApplicationExtension 13.0, *) {
      return UIColor.label
    } else {
      return UIColor(red: 58/255.0, green: 129/255.0, blue: 84/255.0, alpha: 1.0)
    }
  }()
    
  static var defaultBackgroundColor: UIColor = {
    if #available(iOSApplicationExtension 13.0, *) {
      return UIColor.systemGray5
    } else {
      return UIColor.systemGray
    }
  }()

  static let defaultFont = UIFont.preferredFont(forTextStyle: .body)
}

#endif
