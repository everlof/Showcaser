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

fileprivate class CallbackContainer {

    fileprivate  var callback: (() -> Void)

    fileprivate init(callback: @escaping (() -> Void)) {
        self.callback = callback
    }

}

extension CAAnimation: CAAnimationDelegate {

    private struct AssociatedKeys {
        static var callbackKey = "CAAnimation_callbackKey"
    }

    public func onCompletion(_ completion: @escaping (() -> Void)) {
        objc_setAssociatedObject(self,
                                 &AssociatedKeys.callbackKey,
                                 CallbackContainer(callback: completion),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        delegate = self
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let callbackContainer = objc_getAssociatedObject(self, &AssociatedKeys.callbackKey) as? CallbackContainer, flag {
            callbackContainer.callback()
            delegate = nil
        }
        objc_setAssociatedObject(self, &AssociatedKeys.callbackKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

}
