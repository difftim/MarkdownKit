//
//  MarkdownKitViewModel.swift
//  Example
//
//  Created by Bruno Oliveira on 21/01/2019.
//  Copyright © 2019 Ivan Bruel. All rights reserved.
//

import Foundation
import MarkdownKit
import Alamofire

class ViewModel {
  
  let markdownParser: MarkdownParser
  
  var attString: NSAttributedString = NSAttributedString()
  
  fileprivate let testingURL: String
  
  var markdownAttributedStringChanged: ((NSAttributedString?, Error?) -> ())? = nil
  
  init(markdownParser: MarkdownParser,
       testingURL: String = "https://raw.githubusercontent.com/apple/swift-evolution/master/proposals/0240-ordered-collection-diffing.md") {
    self.markdownParser = markdownParser
    self.testingURL = testingURL
  }
}

extension ViewModel {
  func parseString(markdownString: String) {
    let regex = try! NSRegularExpression(pattern: "\\n *\\n", options: NSRegularExpression.Options.caseInsensitive)
    let range = NSMakeRange(0, markdownString.count)
    let newString = regex.stringByReplacingMatches(in: markdownString, options: [], range: range, withTemplate: "\n")
    attString =  markdownParser.parse(newString)
    markdownAttributedStringChanged?(attString, nil)
  }
  
  func requestTestPage() {
    AF.request(testingURL).responseString { [weak self]response in
      if let error = response.error {
        self?.markdownAttributedStringChanged?(nil, error)
        return
      }
      if let markdownString = try? response.result.get() {
        self?.parseString(markdownString: markdownString)
      }
    }
  }
}
