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

public class Showcaser: NSObject {

    // MARK: Public properties

    public static var alertBackgroundColor = UIColor.white.withAlphaComponent(0.9)

    public static var leadToLargeCircleColor = UIColor.AppleHIG.red

    public static var alertBorderColor = UIColor.AppleHIG.red

    public static var alertTitleTextColor = UIColor.AppleHIG.red

    public static var alertBodyTextColor = UIColor.AppleHIG.red

    public static var alertHintTextColor = UIColor.AppleHIG.red

    public static var titleFont = UIFont.systemFont(ofSize: 30)

    public static var bodyFont = UIFont.systemFont(ofSize: 21)

    public static var alertMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

    // MARK: Miscellaneous confiuration

    public static var distanceThreshold: CGFloat = 50.0

    public static var lineDashPattern: [NSNumber]? = [5, 5]

    public enum BackdropStyle {
        case dimmed(UIColor)
        case blur(UIBlurEffect.Style)
    }

    public struct Config {
        let title: String
        let body: String
        let steps: [Step]
        let backdrop: BackdropStyle

        public init(title: String, body: String, steps: [Step], backdrop: BackdropStyle = .dimmed(.white)) {
            self.title = title
            self.body = body
            self.steps = steps
            self.backdrop = backdrop
        }
    }

    public struct Step {
        let text: String
        let area: Area?

        public init(text: String, area: Area? = nil) {
            self.text = text
            self.area = area
        }
    }

    public struct Area {

        public enum Element {
            case view(UIView)
            case rect(CGRect)
        }

        public enum Style {
            case roundCappedToShortestSide
            case roundCappedToLongestSide
            case rectangle
            case roundCorner(radius: CGFloat)
        }

        let element: Element
        let style: Style
        let inset: UIEdgeInsets
        let offset: CGSize

        public init(element: Element,
                    style: Style = .roundCappedToShortestSide,
                    inset: UIEdgeInsets = .zero,
                    offset: CGSize = .zero) {
            self.element = element
            self.style = style
            self.inset = inset
            self.offset = offset
        }

        internal var frame: CGRect {
            let applyConfig: ((CGRect) -> CGRect) = { input in
                return self.applyStyle(
                    input
                        .inset(by: self.inset)
                        .offsetBy(dx: self.offset.width, dy: self.offset.height)
                )
            }

            switch element {
            case .rect(let rect):
                return applyConfig(rect)
            case .view(let view):
                return applyConfig(view.convert(view.bounds, to: nil))
            }
        }

        internal func applyStyle(_ frame: CGRect) -> CGRect {
            switch style {
            case .rectangle, .roundCorner:
                return frame
            case .roundCappedToLongestSide:
                if frame.width < frame.height {
                    let heightToAdd = frame.height - frame.width
                    return CGRect(origin: CGPoint(x: frame.minX - (heightToAdd / 2), y: frame.minY),
                                  size: CGSize(width: frame.height, height: frame.height))
                } else {
                    let widthToAdd = frame.width - frame.height
                    return CGRect(origin: CGPoint(x: frame.minX , y: frame.minY - (widthToAdd / 2)),
                                  size: CGSize(width: frame.width, height: frame.width))
                }
            case .roundCappedToShortestSide:
                if frame.width < frame.height {
                    let removeFromHeight = frame.height - frame.width
                    return CGRect(origin: CGPoint(x: frame.minX, y: frame.minY + removeFromHeight / 2),
                                  size: CGSize(width: frame.width, height: frame.width))
                } else {
                    let removeFromWidth = frame.width - frame.height
                    return CGRect(origin: CGPoint(x: frame.minX + removeFromWidth / 2, y: frame.minY),
                                  size: CGSize(width: frame.height, height: frame.height))
                }
            }
        }

    }

    internal enum AnimationDurations {
        case lineInitialDot
        case lineDrawLine
        case lineTargetDot

        case disappearMoveOut
        case disappearFadeOut

        case appearFadeIn
        case appearMoveInDelay

        var duration: CFTimeInterval {
            switch self {
            // For drawing the line which shows different areas
            case .lineInitialDot:
                return 0.1
            case .lineDrawLine:
                return 0.3
            case .lineTargetDot:
                return 0.1
            // Disappearing
            case .disappearMoveOut:
                return 0.25
            case .disappearFadeOut:
                return 0.25
            // Appearing
            case .appearFadeIn:
                return 0.5
            case .appearMoveInDelay:
                return 0.25
            }
        }
    }
    
    private let tapGestureRecognizer = UITapGestureRecognizer()

    private var window: UIWindow?

    private let showcaseVC: ShowcaseViewController

    public init(config: Config) {
        showcaseVC = ShowcaseViewController(config: config)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = showcaseVC
        window?.addGestureRecognizer(tapGestureRecognizer)
        window?.windowLevel = .statusBar
        super.init()
        tapGestureRecognizer.addTarget(self, action: #selector(tap))
    }

    public func show() {
        window?.makeKeyAndVisible()
    }

    @objc private func tap(gesture: UITapGestureRecognizer) {
        if !showcaseVC.handdrawnView.contentView.progress() {
            showcaseVC.handdrawnView.hideArea {
                self.showcaseVC.handdrawnView.disappear {
                    self.window?.rootViewController = nil
                    self.window = nil
                }
            }
        }
    }

}
