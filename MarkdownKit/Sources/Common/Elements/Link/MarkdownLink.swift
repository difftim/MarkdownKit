//
//  MarkdownLink.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownLink: MarkdownLinkElement {
    
    fileprivate static let regex = "\\[[^\\]]+\\]\\(\\S+(?=\\))\\)"
    
    // This regex is eager if does not count even trailing Parentheses.
    fileprivate static let onlyLinkRegex = "\\]\\(\\S+(?=\\))\\)"
    
    private let schemeRegex = "([a-z]{2,20}):\\/\\/"
    
    open var font: MarkdownFont?
    open var color: MarkdownColor?
    open var defaultScheme: String?
    
    open var regex: String {
      return MarkdownLink.regex
    }
    
    open func regularExpression() throws -> NSRegularExpression {
      return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }
    
    public init(font: MarkdownFont? = nil, color: MarkdownColor? = MarkdownLink.defaultColor) {
      self.font = font
      self.color = color
    }
    
    
    open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange,
                           link: String) {
      let regex = try? NSRegularExpression(pattern: schemeRegex, options: .caseInsensitive)
      let hasScheme = regex?.firstMatch(
          in: link,
          options: .anchored,
          range: NSRange(0..<link.count)
      ) != nil
      
      let fullLink = hasScheme ? link : "\(defaultScheme ?? "https://")\(link)"
      
      guard let encodedLink = fullLink.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        else {
        return
      }
      guard let url = URL(string: fullLink) ?? URL(string: encodedLink) else { return }
      attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: range)
    }
    
    open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
      let nsString = (attributedString.string as NSString)
      let urlString = nsString.substring(with: match.range)
      
      guard let onlyLinkRegex = try? NSRegularExpression(pattern: MarkdownLink.onlyLinkRegex, options: .dotMatchesLineSeparators) else {
        return
      }
      
      guard let linkMatch = onlyLinkRegex.firstMatch(in: urlString,
                       options: .withoutAnchoringBounds,
                       range: NSRange(location: 0, length: urlString.count)) else {
                        return
      }

      let urlLinkAbsoluteStart = match.range.location
      
      let linkURLString = nsString
        .substring(with: NSRange(location: urlLinkAbsoluteStart + linkMatch.range.location + 2, length: linkMatch.range.length - 3))
      
      // deleting trailing markdown
      // needs to be called before formattingBlock to support modification of length
      let trailingMarkdownRange = NSRange(location: urlLinkAbsoluteStart + linkMatch.range.location, length: linkMatch.range.length)
      attributedString.deleteCharacters(in: trailingMarkdownRange)
      
      // deleting leading markdown
      // needs to be called before formattingBlock to provide a stable range
      let leadingMarkdownRange = NSRange(location: match.range.location, length: 1)
      attributedString.deleteCharacters(in: leadingMarkdownRange)
      
      let formatRange = NSRange(location: match.range.location,
                                length: linkMatch.range.location - 1)
      
      formatText(attributedString, range: formatRange, link: linkURLString)
      addAttributes(attributedString, range: formatRange, link: linkURLString)
    }
    
    open func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange,
                              link: String) {
      attributedString.addAttributes(attributes, range: range)
    }
}
