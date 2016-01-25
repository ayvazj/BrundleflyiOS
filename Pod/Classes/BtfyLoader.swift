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

class BtfyLoader {
    internal static func bundleFileAsStage(filename: String, ofType: String, inDirectory: String) throws -> BtfyStage? {
        
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(filename, ofType: ofType, inDirectory: inDirectory)
        
        
        if (NSFileManager.defaultManager().fileExistsAtPath(path!)) {
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(NSFileManager.defaultManager().contentsAtPath(path!)!, options: []) as! [String:AnyObject]
                
                guard let type = json["type"] as? String else {
                    throw BtfyError.ParseError(msg: "Stage type is missing.")
                }
                
                if !(type == "stage") {
                    throw BtfyError.ParseError(msg: "Unexpected stage type: \(type)")
                }
                
                
                guard let size  = json["size"] as? [String:AnyObject] else {
                    throw BtfyError.ParseError(msg: "Stage is missing size.")
                }
                
                guard let animationList  = json["animations"] as? [[String:AnyObject]] else {
                    throw BtfyError.ParseError(msg: "Stage is missing animations.")
                }
                
                var animationGroups : [BtfyAnimationGroup] = []
                for animationGroup in animationList {
                    do {
                        if let group = try BtfyJson.parseAnimationGroup(animationGroup) {
                            animationGroups.append(group);
                        }
                    }
                    catch let err as NSError {
                        print(err)
                    }
                }
                
                do {
                    return try BtfyStage(sizeInfo: BtfyJson.parseSize(size), animationGroups: animationGroups)
                }
                catch let err as NSError {
                    throw err
                }
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        return nil
    }
}