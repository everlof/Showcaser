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

extension UIEdgeInsets {
    static prefix func - (inset: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
    }
}

public class Showcaser: NSObject {

    // MARK: Public properties

    public static var backdropColor = UIColor.black.withAlphaComponent(0.8)

    public static var alertBackgroundColor = UIColor.black.withAlphaComponent(0.9)

    public static var leadToLargeCircleColor = UIColor.AppleHIG.blue

    public static var alertBorderColor = UIColor.AppleHIG.blue

    public static var alertTitleTextColor = UIColor.AppleHIG.blue

    public static var alertBodyTextColor = UIColor.AppleHIG.blue

    public static var alertHintTextColor = UIColor.AppleHIG.blue

    public static var titleFont = UIFont.systemFont(ofSize: 30) // UIFont.forHints(with: 30)

    public static var bodyFont = UIFont.systemFont(ofSize: 21) // UIFont.forHints(with: 21)

    public static var alertMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

    // MARK: Miscellaneous confiuration

    public static var distanceThreshold: CGFloat = 50.0

    public static var lineDashPattern: [NSNumber]? = [5, 5]

    public struct Config {
        let title: String
        let body: String
        let areas: [Area]

        public init(title: String, body: String, areas: [Area]) {
            self.title = title
            self.body = body
            self.areas = areas
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

        let text: String
        let element: Element
        let style: Style
        let inset: UIEdgeInsets
        let offset: CGSize

        public init(text: String,
             element: Element,
             style: Style = .roundCappedToShortestSide,
             inset: UIEdgeInsets = .zero,
             offset: CGSize = .zero) {
            self.text = text
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

internal class ShowcaseContainerView: UIView {

    fileprivate let contentView: ShowcaseView

    private let backgroundView = UIView()

    internal var backdropColor = Showcaser.backdropColor

    private var feedbackGenerator = UIImpactFeedbackGenerator()

    fileprivate var yOffsetConstraint: NSLayoutConstraint?

    enum Vertical {
        case top
        case bottom
    }

    enum Horizontal {
        case left
        case right
    }

    internal init(config: Showcaser.Config) {
        contentView = ShowcaseView(config: config)
        super.init(frame: .zero)
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backgroundView.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Showcaser.AnimationDurations.appearMoveInDelay.duration) {
            self.showBox { }
        }

        UIView.animate(withDuration: Showcaser.AnimationDurations.appearFadeIn.duration) {
            self.backgroundView.backgroundColor = self.backdropColor
        }
    }

    func disappear(complete: @escaping (() -> Void)) {
        UIView.animate(withDuration: Showcaser.AnimationDurations.disappearMoveOut.duration, animations: {
            self.contentView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.bounds.maxY)
        }, completion: { finished in
            UIView.animate(withDuration: Showcaser.AnimationDurations.disappearFadeOut.duration, animations: {
                self.backgroundView.backgroundColor = .clear
            }, completion: { finished in
                complete()
            })
        })
    }

    func showBox(completed: @escaping (() -> Void)) {
        contentView.showcaseContainerView = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        yOffsetConstraint = contentView.centerYAnchor.constraint(equalTo: centerYAnchor)
        yOffsetConstraint?.isActive = true

        contentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        contentView.layer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity.translatedBy(x: 0, y: -bounds.maxY)
        )

        let appearAnimation = CASpringAnimation(keyPath: "transform")
        appearAnimation.fromValue = contentView.layer.transform
        appearAnimation.toValue = CATransform3DIdentity
        appearAnimation.mass = 0.65
        appearAnimation.duration = appearAnimation.settlingDuration
        appearAnimation.isAdditive = true
        appearAnimation.onCompletion {
            completed()
        }

        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0))
        scaleAnimation.toValue = CATransform3DIdentity
        scaleAnimation.isAdditive = true
        scaleAnimation.duration = appearAnimation.settlingDuration * 0.7

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [appearAnimation, scaleAnimation]
        groupAnimation.duration = appearAnimation.settlingDuration
        contentView.layer.add(groupAnimation, forKey: nil)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView.layer.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    func quadrant(for point: CGPoint) -> (vertical: Vertical, horizontal: Horizontal) {
        return (point.y < UIScreen.main.bounds.midY ? .top : .bottom,
                point.x < UIScreen.main.bounds.midX ? .left : .right)
    }


    func hideArea(andPrepareForArea area: Showcaser.Area? = nil, completed: @escaping (() -> Void)) {
        guard let sublayers = layer.sublayers else { return }

        backgroundView.layer.mask?.removeFromSuperlayer()

        if sublayers.compactMap({ $0 as? CAShapeLayer }).isEmpty {
            completed()
        }

        sublayers
            .compactMap { $0 as? CAShapeLayer }
            .enumerated()
            .forEach { (offset, layer) in
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 1.0
                animation.toValue = 0.0
                animation.duration = 0.1
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                animation.onCompletion {
                    layer.removeFromSuperlayer()
                    if offset == 0 {
                        DispatchQueue.main.async {
                            completed()
                        }
                    }
                }

                layer.add(animation, forKey: nil)
        }
    }

    internal func yOffset(for area: Showcaser.Area) -> CGFloat? {
        let areaFrame = area.frame
        let availableWidthForText = contentView.stackView.frame.width
        let textSize =
            (area.text as NSString)
                .boundingRect(with: CGSize(width: availableWidthForText, height: .greatestFiniteMagnitude),
                              options: .usesLineFragmentOrigin,
                              attributes: [NSAttributedString.Key.font: Showcaser.bodyFont],
                              context:  nil)

        var contentSize =
            CGRect(x: 0, y: 0, width: availableWidthForText, height: textSize.height)
                .inset(by: -contentView.margins)

        contentSize.origin.x = frame.center.x - (contentSize.width / 2)
        contentSize.origin.y = frame.center.y - (contentSize.height / 2)

        let insettedContentRect =
            contentSize.insetBy(dx: -Showcaser.distanceThreshold, dy: -Showcaser.distanceThreshold)

        if areaFrame.intersects(insettedContentRect) {
            let above = areaFrame.minY
            let under = frame.maxY - areaFrame.maxY

            if above > under {
                return (above / 2) - frame.midY
            } else {
                return (under + ((frame.maxY - under) / 2)) - frame.midY
            }
        }
        return nil
    }

    // Helper to make code below more concise
    private func setup<T: CAAnimation>(_ animation: T, for part: Showcaser.AnimationDurations) -> T {
        animation.duration = part.duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        return animation
    }

    private func layerForLine(through points: [CGPoint]) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        lineLayer.path = CGPath.smoothBezierThrough(points: points)
        lineLayer.strokeColor = Showcaser.leadToLargeCircleColor.cgColor
        lineLayer.lineCap = .square
        lineLayer.lineDashPattern = Showcaser.lineDashPattern
        lineLayer.lineWidth = 2
        lineLayer.fillColor = nil
        return lineLayer
    }

    private func animationForStartingPoint() -> CAAnimation {
        let animation = setup(CABasicAnimation(keyPath: "lineWidth"), for: .lineInitialDot)
        animation.fromValue = 0
        animation.toValue = 6
        return animation
    }

    private func pathFor(startingPoint: CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: startingPoint,
                    radius: 0,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        path.closeSubpath()
        return path
    }

    private func layerFor(startingPoint: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = pathFor(startingPoint: startingPoint)
        layer.strokeColor = Showcaser.leadToLargeCircleColor.cgColor
        layer.lineWidth = 0
        layer.lineCap = .round
        return layer
    }

    private func layerForArea(with path: CGPath) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path
        layer.fillColor = nil
        layer.strokeColor = Showcaser.leadToLargeCircleColor.cgColor
        layer.lineWidth = 2
        return layer
    }

    private func areaPathsFor(targetPoint: CGPoint, areaRect: CGRect, with field: Showcaser.Area) -> (from: CGPath, to: CGPath) {
        switch field.style {
        case .roundCappedToLongestSide, .roundCappedToShortestSide:
            let areaFromPath = CGMutablePath()
            areaFromPath.addArc(center: targetPoint, radius: 0, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            areaFromPath.closeSubpath()

            let areaToPath = CGMutablePath()
            areaToPath.addArc(center: targetPoint, radius: areaRect.width / 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            areaToPath.closeSubpath()
            return (areaFromPath, areaToPath)
        case .rectangle:
            return (UIBezierPath(rect: areaRect.collapsed).cgPath,
                    UIBezierPath(rect: areaRect).cgPath)
        case .roundCorner(radius: let radius):
            return (UIBezierPath(roundedRect: areaRect.collapsed, cornerRadius: radius).cgPath,
                    UIBezierPath(roundedRect: areaRect, cornerRadius: radius).cgPath)
        }
    }

    private func getLine(with contentRect: CGRect, and area: Showcaser.Area) -> (start: CGPoint, mid: CGPoint, end: CGPoint) {
        let targetPoint = area.frame.center
        let verticalSplit = quadrant(for: targetPoint).vertical
        let startingPoint: CGPoint
        let pointOnTheWay: CGPoint

        switch verticalSplit {
        case .bottom:
            startingPoint = CGPoint(x: contentRect.midX, y: contentRect.maxY)
            pointOnTheWay = CGPoint(x: contentRect.midX, y: contentRect.maxY + (frame.maxY * 0.1))
        case .top:
            startingPoint = CGPoint(x: contentRect.midX, y: contentRect.minY)
            pointOnTheWay = CGPoint(x: contentRect.midX, y: contentRect.minY - (frame.maxY * 0.1))
        }

        return (
            start: startingPoint,
            mid: pointOnTheWay,
            end: targetPoint
        )
    }

    fileprivate func addIndicatorTo(area: Showcaser.Area) {
        feedbackGenerator.prepare()

        let areaRect = area.frame
        let contentRect = contentView.convert(contentView.bounds, to: nil)
        let linePoints = getLine(with: contentRect, and: area)

        let areaPaths = areaPathsFor(targetPoint: linePoints.end, areaRect: areaRect, with: area)
        let areaLayer = layerForArea(with: areaPaths.from)
        let startPointAnimation = animationForStartingPoint()
        let startingPointLayer = layerFor(startingPoint: linePoints.start)
        let lineLayer = layerForLine(through: [linePoints.start, linePoints.mid, linePoints.end])

        let targetDotPathAnimation = setup(CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path)), for: .lineTargetDot)
        targetDotPathAnimation.fromValue = areaPaths.from
        targetDotPathAnimation.toValue = areaPaths.to
        targetDotPathAnimation.onCompletion {
            self.feedbackGenerator.impactOccurred()
        }

        // Mask away the part of the line that is "inside" the `area`
        let followLineMaskPathFrom = CGMutablePath()
        followLineMaskPathFrom.addRect(bounds)
        followLineMaskPathFrom.addPath(areaPaths.from)

        let followLineMaskPathTo = CGMutablePath()
        followLineMaskPathTo.addRect(bounds)
        followLineMaskPathTo.addPath(areaPaths.to)

        let maskAnimation = setup(CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path)), for: .lineTargetDot)
        maskAnimation.fromValue = followLineMaskPathFrom
        maskAnimation.toValue = followLineMaskPathTo

        let followLineMask = CAShapeLayer()
        followLineMask.fillRule = .evenOdd
        followLineMask.path = followLineMaskPathFrom
        lineLayer.mask = followLineMask

        // Mask away the background that convers `area`
        let toPath = CGMutablePath()
        toPath.addRect(bounds)
        toPath.addPath(areaPaths.to)
        toPath.closeSubpath()

        let fromPath = CGMutablePath()
        fromPath.addRect(bounds)
        fromPath.addPath(areaPaths.from)
        fromPath.closeSubpath()

        let showTransparentCircleAnimation = setup(CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path)), for: .lineTargetDot)
        showTransparentCircleAnimation.fromValue = fromPath
        showTransparentCircleAnimation.toValue = toPath

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = fromPath

        let followTheLineAnimation = setup(CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd)), for: .lineDrawLine)
        followTheLineAnimation.calculationMode = .paced
        followTheLineAnimation.values = [0.0, 1.0]
        followTheLineAnimation.keyTimes = [0.0, 1.0]
        followTheLineAnimation.onCompletion {
            // Once we've reached this destination, animate the size of this circle
            self.layer.addSublayer(areaLayer)
            areaLayer.add(targetDotPathAnimation, forKey: nil)

            // Mask away part of the line (that's inside the circle)
            followLineMask.add(maskAnimation, forKey: nil)

            // And mask all of `backgroundView` except the hole of "target circle"
            self.backgroundView.layer.mask = maskLayer
            maskLayer.add(showTransparentCircleAnimation, forKey: nil)
        }

        startPointAnimation.onCompletion {
            // Next follow the "path" to the "target dot"
            self.layer.addSublayer(lineLayer)
            lineLayer.add(followTheLineAnimation, forKey: nil)
        }

        layer.addSublayer(areaLayer)
        layer.addSublayer(startingPointLayer)
        startingPointLayer.add(startPointAnimation, forKey: nil)
    }

}

internal class ShowcaseView: UIView {

    enum LabelStyle {
        case title
        case body
        case tiny
    }

    public weak var showcaseContainerView: ShowcaseContainerView?

    private let config: Showcaser.Config

    private let titleLabel: UILabel

    private let bodyLabel: UILabel

    fileprivate var stackView = UIStackView()

    private var stackViewViewIndex = 2

    private var feedbackGenerator = UISelectionFeedbackGenerator()

    fileprivate var margins = Showcaser.alertMargins

    func progress() -> Bool {
        let areaIndex = stackViewViewIndex - 2
        guard areaIndex < config.areas.count else { return false }

        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()

        let area = config.areas[areaIndex]

        let targetView = stackView.arrangedSubviews[stackViewViewIndex]
        targetView.alpha = 0

        if let yOffset = showcaseContainerView?.yOffset(for: area) {
            showcaseContainerView?.yOffsetConstraint?.constant = yOffset
        } else {
            showcaseContainerView?.yOffsetConstraint?.constant = 0
        }

        self.showcaseContainerView?.hideArea { }
        UIView.animate(withDuration: 0.35) {
            self.showcaseContainerView?.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.15, animations: {
            (0..<self.stackViewViewIndex).forEach { i in
                self.stackView.arrangedSubviews[i].alpha = 0.0
            }
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                (0..<self.stackViewViewIndex).forEach { i in
                    self.stackView.arrangedSubviews[i].isHidden = true
                }
                targetView.isHidden = false
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, animations: {
                    targetView.alpha = 1.0
                }, completion: { _ in
                    self.showcaseContainerView?.addIndicatorTo(area: area)
                })
            })
        }

        stackViewViewIndex += 1
        return true
    }

    init(config: Showcaser.Config) {
        self.config = config

        titleLabel = ShowcaseView.label(for: .title)
        titleLabel.text = config.title

        bodyLabel = ShowcaseView.label(for: .body)
        bodyLabel.text = config.body

        super.init(frame: .zero)

        backgroundColor = Showcaser.alertBackgroundColor

        layer.masksToBounds = true
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = Showcaser.alertBorderColor.cgColor

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: margins.top).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.left).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.right).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margins.bottom).isActive = true

        stackView.axis = .vertical
        stackView.spacing = 20

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bodyLabel)

        config.areas.forEach { field in
            let lbl = ShowcaseView.label(for: .body)
            lbl.text = field.text
            lbl.isHidden = true
            stackView.addArrangedSubview(lbl)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class private func label(for style: LabelStyle) -> UILabel {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center

        switch style {
        case .title:
            lbl.font = Showcaser.titleFont
            lbl.textColor = Showcaser.alertTitleTextColor
        case .body:
            lbl.font = Showcaser.bodyFont
            lbl.textColor = Showcaser.alertBodyTextColor
        case .tiny:
            lbl.font = UIFont.systemFont(ofSize: 17)
            lbl.textColor = Showcaser.alertHintTextColor
        }

        return lbl
    }

}

class ShowcaseViewController: UIViewController {

    private let config: Showcaser.Config

    fileprivate var handdrawnView: ShowcaseContainerView {
        return view as! ShowcaseContainerView
    }

    fileprivate init(config: Showcaser.Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ShowcaseContainerView(config: config)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (view as! ShowcaseContainerView).appear()
    }

}
