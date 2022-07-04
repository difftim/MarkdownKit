//
//  CodeViewController.swift
//  MarkdownKit
//
//  Created by user on 2022/6/28.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import UIKit
import MarkdownView

class CodeViewController: UIViewController {
  let markdown = MarkdownView()
  let source: String

  init(code: String) {
    source = code
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    markdown.frame = view.bounds
    markdown.load(markdown: source)
    view.addSubview(markdown)
  }
}
