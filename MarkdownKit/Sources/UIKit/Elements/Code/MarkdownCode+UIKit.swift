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
    static let defaultHighlightColor = UIColor(red: 58/255.0, green: 129/255.0, blue: 84/255.0, alpha: 1.0)
  static let defaultBackgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
  static let defaultFont = UIFont(name: "Menlo-Regular", size: 12)
}

#endif
