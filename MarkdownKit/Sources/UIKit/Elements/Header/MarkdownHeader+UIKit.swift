//
//  MarkdownHeader+UIKit.swift
//  MarkdownKit
//
//  Created by Bruno Oliveira on 31/01/2019.
//  Copyright © 2019 Ivan Bruel. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public extension MarkdownHeader {
    
    class func defaultFont () -> (UIFont){

        guard let artistDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3).withSymbolicTraits(.traitBold) else{

            return UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        }

        return UIFont(descriptor: artistDescriptor, size: 0.0)
    }
    
}

#endif
