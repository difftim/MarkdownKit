//
//  MarkdownParser.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownParser {
  public struct EnabledElements: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    public static let automaticLink = EnabledElements(rawValue: 1)
    public static let header        = EnabledElements(rawValue: 1 << 1)
    public static let list          = EnabledElements(rawValue: 1 << 2)
    public static let orderList     = EnabledElements(rawValue: 1 << 3)
    public static let quote         = EnabledElements(rawValue: 1 << 4)
    public static let link          = EnabledElements(rawValue: 1 << 5)
    public static let bold          = EnabledElements(rawValue: 1 << 6)
    public static let italic        = EnabledElements(rawValue: 1 << 7)
    public static let code          = EnabledElements(rawValue: 1 << 8)
    public static let strikethrough = EnabledElements(rawValue: 1 << 9)
    public static let horizontalLine = EnabledElements(rawValue: 1 << 10)

    public static let disabledAutomaticLink: EnabledElements = [
      .header,
      .list,
      .orderList,
      .link,
      .quote,
      .bold,
      .italic,
      .code,
      .strikethrough,
      .horizontalLine,
      ]

    public static let all: EnabledElements = [
      .disabledAutomaticLink,
      .automaticLink,
      ]
  }

  // MARK: Element Arrays
  fileprivate var escapingElements: [MarkdownElement]
  fileprivate var defaultElements: [MarkdownElement] = []
  fileprivate var unescapingElements: [MarkdownElement]
  
  open var customElements: [MarkdownElement]
  
  // MARK: Basic Elements
  public let header: MarkdownHeader
  public let list: MarkdownList
  public let orderList: MarkdownOrderList
  public let quote: MarkdownQuote
  public let link: MarkdownLink
  public let automaticLink: MarkdownAutomaticLink
  public let bold: MarkdownBold
  public let italic: MarkdownItalic
  public let inlineCode: MarkdownInlineCode
  public let strikethrough: MarkdownStrikethrough
  public let horizontalLine: MarkdownHorizontalLine

  // MARK: Escaping Elements
  fileprivate var inlineCodeEscaping = MarkdownInlineCodeEscaping()
  fileprivate var codeEscaping = MarkdownCodeEscaping()
  fileprivate var escaping = MarkdownEscaping()
  fileprivate var unescaping = MarkdownUnescaping()
  
  // MARK: Configuration
  /// Enables individual Markdown elements and automatic link detection
  open var enabledElements: EnabledElements {
    didSet {
      updateDefaultElements()
      updateEscapingElements()
      updateUnescapingElements()
    }
  }

  public let font: MarkdownFont
  public let color: MarkdownColor
  
  // MARK: Legacy Initializer
  @available(*, deprecated, renamed: "init", message: "This constructor will be removed soon, please use the new options constructor")
  public convenience init(automaticLinkDetectionEnabled: Bool,
                          font: MarkdownFont = MarkdownParser.defaultFont,
                          customElements: [MarkdownElement] = []) {
    let enabledElements: EnabledElements = automaticLinkDetectionEnabled ? .all : .disabledAutomaticLink
    self.init(font: font, enabledElements: enabledElements, customElements: customElements)
  }
  
  // MARK: Initializer
  public init(font: MarkdownFont = MarkdownParser.defaultFont,
              color: MarkdownColor = MarkdownParser.defaultColor,
              enabledElements: EnabledElements = .all,
              customElements: [MarkdownElement] = []) {
    self.font = font
    self.color = color
    
    self.header = MarkdownHeader()
    self.list = MarkdownList()
    self.orderList = MarkdownOrderList()
    self.quote = MarkdownQuote()
    self.link = MarkdownLink()
    self.automaticLink = MarkdownAutomaticLink()
    self.bold = MarkdownBold()
    self.italic = MarkdownItalic()
    self.inlineCode = MarkdownInlineCode()
    self.strikethrough = MarkdownStrikethrough()
    self.horizontalLine = MarkdownHorizontalLine()

    self.escapingElements = [inlineCodeEscaping, escaping]
    self.unescapingElements = [inlineCode, unescaping]
    self.customElements = customElements
    self.enabledElements = enabledElements
    updateDefaultElements()
    updateEscapingElements()
    updateUnescapingElements()
  }

  // MARK: Element Extensibility
  public func replaceDefaultElement(_ defaultElement: MarkdownElement, with element: MarkdownElement) {
    guard let index = defaultElements.firstIndex(where: { $0 === defaultElement }) else { return }
	defaultElements[index] = element
  }

  open func addCustomElement(_ element: MarkdownElement) {
    customElements.append(element)
  }
  
  open func removeCustomElement(_ element: MarkdownElement) {
    if let index = customElements.firstIndex(where: { $0 === element }) {
      customElements.remove(at: index)
    }
  }
  
  // MARK: Parsing
  open func parse(_ markdown: String) -> NSAttributedString {
    return parse(NSAttributedString(string: markdown))
  }
  
  open func parse(_ markdown: NSAttributedString) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(attributedString: markdown)
    attributedString.addAttribute(.font, value: font,
                                  range: NSRange(location: 0, length: attributedString.length))
    attributedString.addAttribute(.foregroundColor, value: color,
                                  range: NSRange(location: 0, length: attributedString.length))
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 2.0
    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle,
                                  range: NSRange(location: 0, length: attributedString.length))
    var elements: [MarkdownElement] = escapingElements
    elements.append(contentsOf: defaultElements)
    elements.append(contentsOf: customElements)
    elements.append(contentsOf: unescapingElements)
    elements.forEach { element in
      element.parse(attributedString)
    }
    return attributedString
  }

  fileprivate func updateDefaultElements() {
    // Parsing order matters!
    let pairs: [(EnabledElements, MarkdownElement)] = [
      (.quote, quote),
      (.header, header),
      (.list, list),
      (.orderList, orderList),
      (.bold, bold),
      (.italic, italic),
      (.strikethrough, strikethrough),
      (.horizontalLine, horizontalLine),
      (.link, link),
      (.automaticLink, automaticLink),
      (.code, inlineCode),
    ]
    defaultElements = pairs.compactMap { enabled, element in
        enabledElements.contains(enabled) ? element : nil
    }
  }

  fileprivate func updateEscapingElements() {
    if enabledElements.contains(.code) {
      escapingElements = [codeEscaping, inlineCodeEscaping, escaping]
    } else {
      escapingElements = [escaping]
    }
  }

  fileprivate func updateUnescapingElements() {
    if enabledElements.contains(.code) {
      unescapingElements = [inlineCode, unescaping]
    } else {
      unescapingElements = [unescaping]
    }
  }
}
