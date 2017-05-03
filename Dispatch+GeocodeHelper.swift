//  The MIT License (MIT)
//
//  Copyright (c) 2015 Arni Dexian
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

typealias PerformAfterClosure = (_ cancel: Bool) -> ()

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func performAfter(_ delayTime: Double, closure: @escaping ()->()) -> PerformAfterClosure? {
    var closure: (()->())? = closure
    var performClosure: PerformAfterClosure?
    
    let delayedClosure: PerformAfterClosure = { cancel in
        if let uclosure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: uclosure)
            }
        }
        closure = nil
        performClosure = nil
    }
    
    performClosure = delayedClosure
    
    delay(delayTime, closure: {
        if let delayedClosure = performClosure {
            delayedClosure(false)
        }
    })
    
    return performClosure
}

func cancelPerformAfter(_ closure: PerformAfterClosure?) {
    if let uclosure = closure {
        uclosure(true)
    }
}
