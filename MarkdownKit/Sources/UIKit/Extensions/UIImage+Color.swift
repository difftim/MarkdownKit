//
//  UIImage+Color.swift
//  MarkdownKit
//
//  Created by jone on 2022/7/5.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import UIKit

extension UIImage {
    static func lineAttach(_ font: UIFont = .preferredFont(forTextStyle: .body)) -> NSTextAttachment {
        let lineHeight = font.lineHeight
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 2000, height: lineHeight))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        let img = UIImage.image(color: .gray, andRect: CGRect(x: 0, y: 0, width: 2000, height: 1))
        imageView.image = img
        let newImage = UIImage.image(from: imageView)
        let textAttachment = NSTextAttachment()
        textAttachment.image = newImage
        return textAttachment
    }
  
    static func image(color: UIColor, andRect rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    static func image(from view: UIView) -> UIImage? {
        // draw a view's contents into an image context
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            view.layer.render(in: context)
        }
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage
    }
}
