// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIColor {

    // From:
    // https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/

    internal struct AppleHIG {

        internal static var red: UIColor {
            return UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0)
        }

        internal static var orange: UIColor {
            return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        }

        internal static var yellow: UIColor {
            return UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
        }

        internal static var green: UIColor {
            return UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        }

        internal static var tealBlue: UIColor {
            return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
        }

        internal static var blue: UIColor {
            return UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        }

        internal static var purple: UIColor {
            return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0)
        }

        internal static var pink: UIColor {
            return UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1.0)
        }

    }

}
