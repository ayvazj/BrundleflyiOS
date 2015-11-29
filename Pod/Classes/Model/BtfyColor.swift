/*
* Copyright (c) 2015 James Ayvaz
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/


struct BtfyColor {
    var r: Double
    var g: Double
    var b: Double
    var a: Double
    
    init () {
        self.r = 0
        self.g = 0
        self.b = 0
        self.a = 1
    }
    
    init (r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = 1
    }
    
    init (a: Double, r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    static func parseRGBA(json: [String:AnyObject]) -> BtfyColor {
        var a = json["a"] as! Double?
        var r = json["r"] as! Double?
        var g = json["g"] as! Double?
        var b = json["b"] as! Double?
        
        if a == nil {
            a = 1.0
        }
        if r == nil {
            r = 1.0
        }
        if g == nil {
            g = 1.0
        }
        if b == nil {
            b = 1.0
        }
        return BtfyColor(a: a!, r: r!, g: g!, b: b!)
    }
}
