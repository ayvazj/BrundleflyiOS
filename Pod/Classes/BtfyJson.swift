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


class BtfyJson {
    static let positionProps = BtfyPropertyParserKeyframePosition()
    static let rotationProps = BtfyPropertyParserKeyframeRotation()
    static let scaleProps = BtfyPropertyParserKeyframeScale();
    static let opacityProps  = BtfyPropertyParserKeyframeOpactity()
    
    static func parseSize(json: [String:AnyObject]) throws -> BtfySize {
        guard let width = json["width"] as? Int else {
            throw BtfyError.ParseError(msg: "Size missing width.")
        }
        
        guard let height = json["height"] as? Int else {
            throw BtfyError.ParseError(msg: "Size missing height.")
        }
        
        return BtfySize(width: Double(width), height: Double(height));
    }
    
    static func parsePoint(json: [String:AnyObject]) throws -> BtfyPoint {
        guard let x = json["x"] as? Double else {
            throw BtfyError.ParseError(msg: "Point missing x.")
        }
        
        guard let y = json["y"] as? Double else {
            throw BtfyError.ParseError(msg: "Point missing y.")
        }
        
        return BtfyPoint(x: x, y: y);
    }
    
    static func parseScale(json: [String:AnyObject]) throws -> BtfyPoint {
        guard let sx = json["sx"] as? Double else {
            throw BtfyError.ParseError(msg: "Scale missing sx.")
        }
        
        guard let sy = json["sy"] as? Double else {
            throw BtfyError.ParseError(msg: "Scale missing sy.")
        }
        
        return BtfyPoint(x: sx, y: sy);
    }
    
    static func parseTypeface(str: String?) -> String {
        guard let typefaceStr = str else {
            return UIFont.systemFontOfSize(0).fontName
        }
        
        switch(typefaceStr) {
        case "italic":
            return UIFont.italicSystemFontOfSize(0).fontName
        case "bold":
            return UIFont.boldSystemFontOfSize(0).fontName
        case "bold-italic":
            return UIFont.italicSystemFontOfSize(0).fontName
        default:
            break
        }
        return UIFont.systemFontOfSize(0).fontName
    }
    
    static func parseTextAlignment(str: String?) -> NSTextAlignment {
        guard let textAlignStr = str else {
            return NSTextAlignment.Left
        }
        
        switch(textAlignStr) {
        case "center":
            return NSTextAlignment.Center
        case "right":
            return NSTextAlignment.Right
        case "right-center":
            return NSTextAlignment.Right
        case "left-center":
            return NSTextAlignment.Left
        default:
            break
        }
        return NSTextAlignment.Left
    }
    
    static func parseTimingFunction(json: [AnyObject]) -> CAMediaTimingFunction {
        guard json.count > 2 else {
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        }
        let jsonTiming = json[2]
        guard let nameStr = jsonTiming["name"] as! String? else {
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        }
        
        if nameStr == "cubic-bezier" || nameStr == "linear" {
            let x1 = jsonTiming["x1"] as! Float
            let y1 = jsonTiming["y1"] as! Float
            let x2 = jsonTiming["x2"] as! Float
            let y2 = jsonTiming["y2"] as! Float
            
            return CAMediaTimingFunction(controlPoints: x1, y1, x2, y2)
        }
        
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    }
    
    
    static func parseAnimationGroup(json: [String: AnyObject]) throws -> BtfyAnimationGroup? {
        guard let typeStr = json["type"] as? String else {
            throw BtfyError.ParseError(msg: "Undefined animation group type")
        }
        
        guard let jsonId = json["id"] as? String else {
            throw BtfyError.ParseError(msg: "Animation missing id")
        }
        
        if typeStr != "animationGroup" {
            throw BtfyError.ParseError(msg: "Unexpected animation group type: \(typeStr)")
        }
        
        var parentId = json["parentId"] as! String?
        if ( parentId != nil && parentId!.isEmpty) {
            parentId = nil // we want it nil rather than empty
        }
        
        var shape = BtfyShape()
        if let shapeJSON = json["shape"] {
            let shapeStr = shapeJSON["name"] as! String?
            
            if (BtfyShape.Name.ellipse  == shapeStr) {
                shape.name = BtfyShape.Name.ellipse
            }
            else {
                shape.name = BtfyShape.Name.rectangle
            }
        }
        
        let duration = (json["duration"] as! Double?)!
        
        var textStr = json["text"] as! String?
        if (textStr != nil && !(textStr!.isEmpty)) {
            
            textStr = textStr!.localized
        }
        
        
        var backgroundImageStr = json["backgroundImage"] as! String?
        if ( backgroundImageStr != nil && backgroundImageStr!.isEmpty ) {
            backgroundImageStr = nil
        }
        
        var animations : [BtfyAnimation] = []
        if let animationsList = json["animations"] as? [[String:AnyObject]]  {
            for var i = 0; i < animationsList.count; ++i {
                let animation = animationsList[i]
                
                let idStr = animation["id"] as! String?
                let animTypeStr = animation["type"] as! String?
                
                if "animation" != animTypeStr {
                    throw BtfyError.ParseError(msg: "Unexpected animation type: \(animTypeStr)")
                }
                
                var delay = animation["delay"] as! Double?
                if delay == nil {
                    delay = 0
                }
                delay = delay!
                
                var animduration = animation["duration"] as! Double?
                if animduration == nil {
                    animduration = 0
                }
                animduration = animduration!
                
                let jsonKeyframesList = animation["keyframes"] as! [AnyObject]?
                let propertyValue = animation["property"] as! String?
                
                var animationObj : BtfyAnimation?
                if let propValue = propertyValue {
                    switch(propValue) {
                    case "opacity":
                        var keyframes : [BtfyKeyframe] = []
                        do {
                            keyframes = try opacityProps.parseKeyframes(jsonKeyframesList!)
                        }
                        catch let err as NSError {
                            print(err)
                        }
                        
                        animationObj = BtfyAnimation(id: idStr, property: BtfyAnimation.Property.Opacity, delay: delay!, duration: animduration!, list: keyframes)
                        break
                    case "rotation":
                        var keyframes : [BtfyKeyframe] = []
                        do {
                            keyframes = try rotationProps.parseKeyframes(jsonKeyframesList!)
                        }
                        catch let err as NSError {
                            print(err)
                        }
                        
                        animationObj = BtfyAnimation(id: idStr, property: BtfyAnimation.Property.Rotation, delay: delay!, duration: animduration!, list: keyframes)
                        
                        break
                    case "scale":
                        var keyframes : [BtfyKeyframe] = []
                        do {
                            keyframes = try scaleProps.parseKeyframes(jsonKeyframesList!)
                        }
                        catch let err as NSError {
                            print(err)
                        }
                        
                        animationObj = BtfyAnimation(id: idStr, property: BtfyAnimation.Property.Scale, delay: delay!, duration: animduration!, list: keyframes)
                        break
                    case "position":
                        var keyframes : [BtfyKeyframe] = []
                        do {
                            keyframes = try positionProps.parseKeyframes(jsonKeyframesList!)
                        }
                        catch let err as NSError {
                            print(err)
                        }
                        
                        animationObj = BtfyAnimation(id: idStr, property: BtfyAnimation.Property.Position, delay: delay!, duration: animduration!, list: keyframes)
                        break
                    default:
                        print("Unrecognised animation property value : \(propValue)")
                        animationObj = nil
                    }
                }
                else {
                    print("Unrecognised animation property: \(propertyValue)")
                }
                
                
                if animationObj != nil {
                    animations.append(animationObj!)
                }
            }
        }
        
        let intialValues = json["initialValues"] as! [String:AnyObject]?
        if intialValues == nil {
            throw BtfyError.ParseError(msg: "Animation group missing initial values.")
        }
        let jsonSize = intialValues!["size"] as! [String:AnyObject]?
        if jsonSize == nil {
            throw BtfyError.ParseError(msg: "Missing size in initial values.")
        }
        
        var anchorPointJson = intialValues!["anchorPoint"] as! [String:AnyObject]?
        if anchorPointJson == nil {
            anchorPointJson = ["anchorPoint": ["x": 0, "y":0]]
        }
        var anchorPoint : BtfyPoint?
        do {
            anchorPoint = try parsePoint(anchorPointJson!)
        }
        catch _ {
            throw BtfyError.ParseError(msg: "Unable to parse anchor point")
        }
        
        var backgroundColorJson = intialValues!["backgroundColor"] as! [String:AnyObject]?
        if backgroundColorJson == nil {
            backgroundColorJson = ["r": 0, "g":0, "b": 0, "a": 0]
        }
        let backgroundColor = BtfyColor.parseRGBA(backgroundColorJson!)
        
        
        var opacity = intialValues!["opacity"] as! Double?
        if opacity == nil {
            opacity = 1.0
        }
        
        var positionJson = intialValues!["position"] as! [String:AnyObject]?
        if positionJson == nil {
            positionJson = ["position": ["x": 0, "y":0]]
        }
        var position : BtfyPoint?
        do {
            position = try parsePoint(positionJson!)
        }
        catch _ {
            throw BtfyError.ParseError(msg: "Unable to parse position")
        }
        
        var scaleJson = intialValues!["scale"] as! [String:AnyObject]?
        if scaleJson == nil {
            scaleJson = ["scale": ["sx": 1, "sy":1]]
        }
        var scale : BtfyPoint?
        do {
            scale = try parseScale(scaleJson!)
        }
        catch _ {
            throw BtfyError.ParseError(msg: "Unable to parse scale")
        }
        
        var rotation = intialValues!["rotation"] as! Double?
        if rotation == nil {
            rotation = 0.0
        }
        
        let fontSize = intialValues!["fontSize"] as! Double?
        
        var textColorJson = intialValues!["textColor"] as! [String:AnyObject]?
        if textColorJson == nil {
            textColorJson = ["textColor": ["r": 1, "g":1, "b": 1, "a": 1]]
        }
        let textColor = BtfyColor.parseRGBA(textColorJson!)
        
        let textStyle = intialValues!["textStyle"] as! String?
        
        let textAlign = parseTextAlignment(intialValues!["textAlign"] as! String?)

        let sizeWidth = jsonSize!["width"] as! Double?
        let sizeHeight = jsonSize!["height"] as! Double?
        
        if (sizeWidth != nil && sizeHeight != nil) {
            return BtfyAnimationGroup(
                jsonId: jsonId,
                parentId: parentId,
                shape: shape,
                duration: duration,
                text: textStr,
                backgroundImageStr: backgroundImageStr,
                initialValues: BtfyInitialValues(
                    size: BtfySize(width:sizeWidth!, height:sizeHeight!),
                    anchorPoint: anchorPoint!,
                    backgroundColor: backgroundColor,
                    opacity: opacity!,
                    position: position!,
                    scale: scale!,
                    rotation: rotation!,
                    fontSize: fontSize,
                    textColor: textColor,
                    textStyle: textStyle,
                    textAlign: textAlign
                ),
                animations: animations
            )
        }
        else {
            throw BtfyError.ParseError(msg: "Size missing width or height.")
        }
    }
}


