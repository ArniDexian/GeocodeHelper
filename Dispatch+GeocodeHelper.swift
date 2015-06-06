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

typealias PerformAfterClosure = (cancel: Bool) -> ()

func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func performAfter(delayTime: Double, closure: dispatch_block_t) -> PerformAfterClosure? {
    var closure: dispatch_block_t? = closure
    var performClosure: PerformAfterClosure?
    
    let delayedClosure: PerformAfterClosure = { cancel in
        if let uclosure = closure {
            if !cancel {
                dispatch_async(dispatch_get_main_queue(), uclosure)
            }
        }
        closure = nil
        performClosure = nil
    }
    
    performClosure = delayedClosure
    
    delay(delayTime, {
        if let delayedClosure = performClosure {
            delayedClosure(cancel: false)
        }
    })
    
    return performClosure
}

func cancelPerformAfter(closure: PerformAfterClosure?) {
    if let uclosure = closure {
        uclosure(cancel: true)
    }
}