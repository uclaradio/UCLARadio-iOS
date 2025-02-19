//
//  Constants.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 5/10/16.
//  Copyright © 2016 UCLA Student Media. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Colors {
        static let reallyDarkBlue = UIColor(hex: 0x2b8cbe)
        static let darkBlue = UIColor(hex: 0xa6bddb)
        static let lightBlue = UIColor(hex: 0xece7f2)
        static let gold = UIColor(hex: 0xffd970)
        static let darkPink = UIColor(hex: 0xfa9fb5)
        static let lightPink = UIColor(hex: 0xfde0dd)
        static let reallyDarkPink = UIColor(hex: 0xc51b8a)
        static let lightBackground = UIColor.white.withAlphaComponent(0.85)
        static let lightBackgroundHighlighted = UIColor.white
        static let lightBackgroundAltHighlighted = darkPink.withAlphaComponent(0.5)
        static let darkBackground = UIColor.black.withAlphaComponent(0.85)
    }
    
    struct Fonts {
        static let title = "apercu-regular"
        static let titleBold = "apercu-bold"
        static let titleMedium = "apercu-medium"
        static let titleLight = "apercu-light"
    }
    
    struct Floats {
        static let containerOffset: CGFloat = 8
        static let menuOffset: CGFloat = 15
    }
}
