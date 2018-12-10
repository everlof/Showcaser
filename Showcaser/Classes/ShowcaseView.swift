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

internal class ShowcaseView: UIView {

    internal enum LabelStyle {
        case title
        case body
        case tiny
    }

    public weak var showcaseContainerView: ShowcaseContainerView?

    internal var stackView = UIStackView()

    internal var margins = Showcaser.alertMargins

    private let config: Showcaser.Config

    private let titleLabel: UILabel

    private let bodyLabel: UILabel

    private var stackViewViewIndex = 2

    private var feedbackGenerator = UISelectionFeedbackGenerator()

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

    internal init(config: Showcaser.Config) {
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
