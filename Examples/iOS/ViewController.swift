//
//  ViewController.swift
//  MarkdownKit
//
//  Created by Ivan Bruel on 07/18/2016.
//  Copyright (c) 2016 Ivan Bruel. All rights reserved.
//

import MarkdownKit
import MarkdownView
import UIKit

class ViewController: UIViewController {
  @IBOutlet fileprivate var textView: UITextView! {
    didSet {
      textView.delegate = self
      textView.isScrollEnabled = false
    }
  }
  
  fileprivate lazy var attributedStringFromResources: String = NSLocalizedString("Markdown", comment: "").stringByDecodingHTMLEntities
  
  fileprivate lazy var viewModel: ViewModel = {
    let parser = MarkdownParser()
    
    let viewModel = ViewModel(markdownParser: parser)
    viewModel.markdownAttributedStringChanged = { [weak self] attributtedString, error in
      if let error = error {
        NSLog("Error requesting -> \(error)")
        return
      }
      
      guard let attributedText = attributtedString else {
        NSLog("No error nor string found")
        return
      }
    }
    
    return viewModel
  }()
  
  fileprivate var resourcesAction: UIAlertAction {
    return UIAlertAction(title: "Resources",
                         style: .default,
                         handler: { [unowned self] _ in
                           self.viewModel.parseString(markdownString: self.attributedStringFromResources)
                         })
  }
  
  fileprivate var internetAction: UIAlertAction {
    return UIAlertAction(title: "Internet",
                         style: .default,
                         handler: { [unowned self] _ in
                           self.viewModel.requestTestPage()
                         })
  }
  
  fileprivate var actionSheetController: UIAlertController {
    let alert = UIAlertController(title: "Choose the Markdown source", message: nil, preferredStyle: .actionSheet)
    alert.addAction(resourcesAction)
    alert.addAction(internetAction)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
      alert.dismiss(animated: true, completion: nil)
    }))
    return alert
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "MarkdownKit"
    viewModel.parseString(markdownString: attributedStringFromResources)
    textView.attributedText = viewModel.attString
    
    viewModel.attString.enumerateAttribute(.paragraphStyle,
                                           in: NSRange(0 ..< viewModel.attString.length)) {
      value, range, _ in
      // Confirm the attribute value is actually a font
      if let paragraphStyle = value as? NSMutableParagraphStyle, paragraphStyle.tag == 10 {
        print(range)
        if let linerect = self.textView.rect(forStringRange: range) {
          print(linerect)
          let view1 = UIView(frame: CGRect(x: 0, y: linerect.minY, width: 5, height: linerect.height))
//          print(linerect)
          view1.frame = linerect
//          view1.backgroundColor = .red
          self.textView.addSubview(view1)
        }
        let rect = self.textView.rect(for: range)
        print(rect)
        let view = UIView(frame: CGRect(x: 0, y: rect.minY, width: 5, height: rect.height))
//        view.frame = rect
        view.backgroundColor = .gray
        self.textView.addSubview(view)
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !textView.isScrollEnabled {
      textView.isScrollEnabled = true
      textView.setContentOffset(.zero, animated: false)
    }
  }
  
  @IBAction func userDidTapSwitch(_ sender: Any) {
    present(actionSheetController, animated: true, completion: nil)
  }
}

extension ViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                in characterRange: NSRange) -> Bool
  {
//    UIApplication.shared.open(URL, options: [:])
    print("keith-s ==> \(URL)")
    // UIApplication.shared.openURL(URL)
    let tuple = MarkdownCodeEscaping.code(url: URL)
    if let lang = tuple.0, let code = tuple.1 {
      print(lang)
      print(code)
        
      present(CodeViewController(code: code), animated: true)
    }
    return false
  }
}

extension UITextView {
  /// 查找文本范围所在的矩形范围
  ///
  /// - Parameter range: 文本范围
  /// - Returns: 文本范围所在的矩形范围
  func rect(forStringRange range: NSRange) -> CGRect? {
    guard let start = position(from: beginningOfDocument, offset: range.location) else { return nil }
    guard let end = position(from: start, offset: range.length) else { return nil }
    guard let textRange = textRange(from: start, to: end) else { return nil }
    let selRects = selectionRects(for: textRange)
    var returnRect = CGRect.zero
     
    for thisSelRect in selRects {
      if thisSelRect == selRects.first {
        returnRect = thisSelRect.rect
      } else {
        if thisSelRect.rect.size.width > 0 {
          returnRect.origin.y = min(returnRect.origin.y, thisSelRect.rect.origin.y)
          returnRect.size.height += thisSelRect.rect.size.height
        }
      }
    }
    return returnRect
  }
  
  func rect(for range: NSRange) -> CGRect {
    let firstLineIndex = layoutManager.glyphIndexForCharacter(at: range.lowerBound)
    let lastLineIndex = layoutManager.glyphIndexForCharacter(at: range.upperBound)
    let firstRect = layoutManager.lineFragmentRect(forGlyphAt: Int(firstLineIndex), effectiveRange: nil)
    let lastRect = layoutManager.lineFragmentRect(forGlyphAt: Int(lastLineIndex), effectiveRange: nil)
    if firstRect == lastRect {
      return firstRect
    } else {
      return CGRect(x: 0, y: firstRect.minY, width: firstRect.width, height: lastRect.maxY - firstRect.minY)
    }
  }
}
