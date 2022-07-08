//
//  String+Base64.swift
//  MarkdownKit
//
//  Created by user on 2022/7/8.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import Foundation

extension String {
  func encodBase64() -> String? {
    if let data = self.data(using: .utf8) {
      return data.base64EncodedString()
    }
    return nil
  }
  
  func decodBase64() -> String? {
    if let data = Data(base64Encoded: self) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
}
