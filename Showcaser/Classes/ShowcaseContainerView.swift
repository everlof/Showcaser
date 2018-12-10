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

import Foundation

internal class ShowcaseContainerView: UIView {

    internal let contentView: ShowcaseView

    internal var yOffsetConstraint: NSLayoutConstraint?

    private var backgroundView = UIView()

    private var feedbackGenerator = UIImpactFeedbackGenerator()

    internal enum Vertical {
        case top
        case bottom
    }

    internal enum Horizontal {
        case left
        case right
    }

    internal init(config: Showcaser.Config) {
        contentView = ShowcaseView(config: config)
        super.init(frame: .zero)

        if !UIAccessibility.isReduceTransparencyEnabled {
            switch config.backdrop {
            case .blur(let effect):
                let blurEffect = UIBlurEffect(style: effect)
                backgroundView = UIVisualEffectView(effect: blurEffect)
            case .dimmed(let color):
                backgroundView.backgroundColor = color
            }

            addSubview(backgroundView)
            backgroundView.alpha = 0.0
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Showcaser.AnimationDurations.appearMoveInDelay.duration) {
            self.showBox { }
        }

        UIView.animate(withDuration: Showcaser.AnimationDurations.appearFadeIn.duration) {
            if UIAccessibility.isReduceTransparencyEnabled {
                self.backgroundView.backgroundColor = UIColor.black
            } else {
                self.backgroundView.alpha = 0.7
            }
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

        let appearAnimation = CASpringAnimation(keyPath: #keyPath(CAShapeLayer.transform))
        appearAnimation.fromValue = contentView.layer.transform
        appearAnimation.toValue = CATransform3DIdentity
        appearAnimation.mass = 0.65
        appearAnimation.duration = appearAnimation.settlingDuration
        appearAnimation.isAdditive = true
        appearAnimation.onCompletion {
            completed()
        }

        let scaleAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.transform))
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

    internal func hideArea(andPrepareForArea area: Showcaser.Area? = nil, completed: @escaping (() -> Void)) {
        guard let sublayers = layer.sublayers else { return }

        backgroundView.layer.mask?.removeFromSuperlayer()

        if sublayers.compactMap({ $0 as? CAShapeLayer }).isEmpty {
            completed()
        }

        sublayers
            .compactMap { $0 as? CAShapeLayer }
            .enumerated()
            .forEach { (offset, layer) in
                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.opacity))
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

    internal func addIndicatorTo(area: Showcaser.Area) {
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
