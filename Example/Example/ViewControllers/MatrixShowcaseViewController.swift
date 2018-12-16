
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
import Showcaser
import NameThatColor

class MatrixShowcaseViewController: UIViewController {

    let verticalStackView = UIStackView()

    let horizontalStackViews = [UIStackView]()

    let verticalColors = [
        UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0),
        UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0),
        UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0),
        UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0),
        UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1.0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalStackView)
        verticalStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        (0..<5).forEach { i in
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution = .fillEqually
            verticalStackView.addArrangedSubview(horizontalStackView)

            (0..<3).forEach { j in
                let v = UIView()
                let alpha = CGFloat(Double(j + 1) / 3.0)
                horizontalStackView.addArrangedSubview(v)
                (verticalStackView.arrangedSubviews[i] as! UIStackView)
                    .arrangedSubviews[j].backgroundColor = verticalColors[i].withAlphaComponent(alpha)
            }
        }
    }

    var showcaser: Showcaser!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let styles: [Showcaser.Area.Style] =  [
            .rectangle,
            .roundCappedToLongestSide,
            .roundCappedToShortestSide,
            .roundCorner(radius: 7)
        ]

        var steps = [Showcaser.Step]()
        (0..<5).forEach { i in
            (0..<3).forEach { j in
                let colorName = verticalColors[i].name
                let style = styles[((i * 3) + j) % styles.count]
                if ((i * 3) + j) % 2 == 0 {
                    steps.append(Showcaser.Step(text: "This color is called \"\(colorName)\". Here with style=`\(style)`",
                        area: Showcaser.Area(element: .view(verticalStackView.subviews[i].subviews[j]), style: style)))
                } else {
                    steps.append(Showcaser.Step(text: "This color is called \"\(colorName)\". Here with style=`\(style)`"))
                }
            }
        }

        let config = Showcaser.Config(title: "Hello there! 🙌",
                                      body: "Welcome to `Showcaser`, this is an `Example` app for the library.",
                                      steps: steps)
        showcaser = Showcaser(config: config)
        showcaser.show()
    }

}
