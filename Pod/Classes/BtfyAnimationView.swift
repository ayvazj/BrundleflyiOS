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

public class BtfyAnimationView: UIView {
    let kDebug = false // draw bounding boxes and green screens
    
    var btfyStage : BtfyStage?
    var viewMap : [String:UIView] = [:]
    let stageView : UIView
    
    
    // drawRect lays out a grid to help verify placement
    //    override public func drawRect(rect: CGRect) {
    //        let context = UIGraphicsGetCurrentContext()
    //
    //        CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)
    //        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
    //        for var i = 0; i < 200; i++ {
    //            if i % 10 == 0 {
    //                CGContextSetLineWidth(context,2.0)
    //                CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
    //            }
    //            else {
    //                CGContextSetLineWidth(context,0.5)
    //                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
    //
    //            }
    //
    //            CGContextMoveToPoint(context, CGFloat(i * 10), 0)
    //            CGContextAddLineToPoint(context, CGFloat(i * 10), 1000)
    //
    //            CGContextMoveToPoint(context, 0, CGFloat(i * 10))
    //            CGContextAddLineToPoint(context, 1000, CGFloat(i * 10))
    //
    //            CGContextStrokePath(context)
    //        }
    //    }
    
    override init(frame: CGRect) {
        self.stageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.stageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() -> Void {
        self.autoresizesSubviews = false
        self.autoresizingMask = UIViewAutoresizing.None
    }
    
    public func load(filename: String, ofType: String, inDirectory: String, complete: () -> Void) -> Void {
        if (!filename.isEmpty) {
            do {
                let stage = try BtfyLoader.bundleFileAsStage(filename, ofType: ofType, inDirectory: inDirectory)
                initStage(stage!, complete: complete)
            }
            catch BtfyError.ParseError(let msg) {
                print(msg)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            catch _ {
                
            }
        }
        if kDebug {
            self.backgroundColor = UIColor.greenColor()
        }
    }
    
    private func initStage(stage: BtfyStage, complete: () -> Void ) -> Void {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        self.btfyStage = stage
        self.viewMap = [:]
        
        
        self.updateBounds()
        
        for var i = 0; i < stage.animationGroups.count; ++i {
            let animationGroup = stage.animationGroups[i]
            var view : UIView?
            if let text = animationGroup.text {
                view = UILabel()
                (view as? UILabel)?.text = text
            } else {
                if let backgroundImage = animationGroup.backgroundImage {
                    if let imagePath = NSBundle.mainBundle().pathForResource("btfy/\(backgroundImage)") {
                        if (NSFileManager.defaultManager().fileExistsAtPath(imagePath)) {
                            
                            let img = UIImage(data: UIImagePNGRepresentation(UIImage(contentsOfFile: imagePath)!)!)
                            
                            view = UIImageView(image: img)
                            view!.contentMode = .ScaleToFill
                        }
                    }
                } else if let shape = animationGroup.shape {
                    if shape.name == BtfyShape.Name.ellipse {
                        view = BtfyEllipseView()
                    }
                    else {
                        view = BtfyRectangleView()
                    }
                } else {
                    view = BtfyRectangleView()
                }
            }
            view!.animationGroup = animationGroup
            
            if (kDebug) {
                //view!.layer.masksToBounds = false
                view!.layer.borderColor = UIColor.redColor().CGColor
                view!.layer.borderWidth = 1
            }
            
            
            
            initView(view!, animationGroup: animationGroup)
        }
        
        complete()
    }
    
    private func animateView(view : UIView) {
        if let animationGroup = view.animationGroup {
            playAnimation(view, animationGroup: animationGroup)
        }
        for sv in view.subviews {
            animateView(sv)
        }
    }
    
    public func playAnimation() {
        for subview in self.stageView.subviews {
            animateView(subview)
        }
    }
    
    private func playAnimation(subview : UIView, animationGroup: BtfyAnimationGroup) -> Void {
        guard animationGroup.duration > 0 else {
            return;
        }
        
        var animations :[CAAnimation] = []
        for ani in animationGroup.animations {
            switch ani.property {
            case .Opacity:
                var values : [Double] = []
                var keys : [CGFloat] = []
                var timings : [CAMediaTimingFunction] = []
                for keyframe in ani.keyframes {
                    let val = keyframe.val as! Double
                    
                    values.append(val)
                    keys.append(CGFloat(keyframe.index))
                    timings.append(keyframe.timingFunction)
                } // for keyframe in ani.keyframes {
                
                let opacityAnim = createKeyFrame(
                    "opacity",
                    values: values,
                    keyTimes: keys,
                    timings: timings,
                    ani: ani)
                
                animations.append(opacityAnim)
                break
            case .Position:
                var values : [NSValue] = []
                var keys : [CGFloat] = []
                var timings : [CAMediaTimingFunction] = []
                for keyframe in ani.keyframes {
                    let val = keyframe.val as! BtfyPoint
                    
                    values.append(NSValue(CGPoint: CGPoint(x: xRel(val.x), y: yRel(val.y))))
                    keys.append(CGFloat(keyframe.index))
                    timings.append(keyframe.timingFunction)
                } // for keyframe in ani.keyframes {
                
                let posAnim = createKeyFrame(
                    "position",
                    values: values,
                    keyTimes: keys,
                    timings: timings,
                    ani: ani)
                
                animations.append(posAnim)
                
                break
            case .Scale:
                var values : [NSValue] = []
                var keys : [CGFloat] = []
                var timings : [CAMediaTimingFunction] = []
                for keyframe in ani.keyframes {
                    let val = keyframe.val as! BtfyPoint
                    
                    values.append(NSValue(CGPoint: CGPoint(x: val.x, y: val.y)))
                    keys.append(CGFloat(keyframe.index))
                    timings.append(keyframe.timingFunction)
                } // for keyframe in ani.keyframes {
                
                let scaleAnim = createKeyFrame(
                    "transform.scale",
                    values: values,
                    keyTimes: keys,
                    timings: timings,
                    ani: ani)
                
                animations.append(scaleAnim)
                
                break
            case .Rotation:
                var values : [Double] = []
                var keys : [CGFloat] = []
                var timings : [CAMediaTimingFunction] = []
                for keyframe in ani.keyframes {
                    let val = (keyframe.val as! Double).degreesToRadians
                    
                    values.append(val)
                    keys.append(CGFloat(keyframe.index))
                    timings.append(keyframe.timingFunction)
                } // for keyframe in ani.keyframes {
                
                let rotationAnim = createKeyFrame(
                    "transform.rotation",
                    values: values,
                    keyTimes: keys,
                    timings: timings,
                    ani: ani)
                
                animations.append(rotationAnim)
                
                break
            }
            let animGroup = CAAnimationGroup()
            animGroup.duration = NSTimeInterval(animationGroup.duration)
            animGroup.repeatCount = 1
            animGroup.animations = animations
            animGroup.fillMode = kCAFillModeForwards
            animGroup.removedOnCompletion = false
            
            subview.layer.addAnimation(animGroup, forKey: animationGroup.id)
        }
    }
    
    
    
    private func createKeyFrame(
        keyPath: String,
        values: [AnyObject],
        keyTimes: [CGFloat],
        timings: [CAMediaTimingFunction],
        ani: BtfyAnimation) -> CAKeyframeAnimation {
            let anim = CAKeyframeAnimation(keyPath: keyPath)
            anim.beginTime = ani.delay
            anim.values = values
            anim.keyTimes = keyTimes
            anim.duration = NSTimeInterval(ani.duration)
            anim.additive = false
            anim.timingFunctions = timings
            anim.fillMode = kCAFillModeForwards
            anim.removedOnCompletion = false
            return anim
    }
    
    
    private func updateBounds() {
        if let stage = self.btfyStage  {
            let size = stage.size;
            
            self.addSubview(self.stageView)
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            var resolveSizeWidth = Double(self.bounds.width)
            var resolveSizeHeight = Double(self.bounds.height)
            
            let resolvedRatio = resolveSizeWidth / resolveSizeHeight
            let sizeRatio = size.width / size.height


            if resolvedRatio > sizeRatio {
                resolveSizeWidth = round( resolveSizeHeight * sizeRatio)
            } else if (resolvedRatio < sizeRatio) {
                resolveSizeHeight = round( resolveSizeWidth / sizeRatio)
            }
            
            self.stageView.transform = CGAffineTransformIdentity
            
            if kDebug {
                self.stageView.backgroundColor = UIColor.orangeColor()
            }
            
            self.stageView.bounds = CGRect(x: 0, y: 0, width: resolveSizeWidth, height: resolveSizeHeight)
            self.stageView.center = self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
            
            self.stageView.clipsToBounds = true
            self.stageView.setNeedsLayout()
            self.stageView.layoutIfNeeded()
        }
    }
    
    private func initView(view: UIView, animationGroup : BtfyAnimationGroup) {
        let iv = animationGroup.initialValues
        
        self.viewMap[animationGroup.id] = view
        if let parentId = animationGroup.parentId, parentView = self.viewMap[parentId] {
            parentView.addSubview(view)
        }
        else {
            self.stageView.addSubview(view)
        }
        
        view.clipsToBounds = false
        view.autoresizingMask = UIViewAutoresizing.None
        view.autoresizesSubviews = false
        
        view.backgroundColor = UIColor(btfyColor: iv.backgroundColor)
        
        view.bounds = CGRect(x:0, y: 0, width: relWidth(iv.size.width), height: relHeight(iv.size.height))
        view.center = CGPoint(x: xRel(iv.position.x), y: yRel(iv.position.y))
        view.layer.anchorPoint = CGPoint(x: iv.anchorPoint.x, y: iv.anchorPoint.y)
        view.alpha = CGFloat(iv.opacity)
        
        var tMatrix = CGAffineTransformIdentity
        // tMatrix = CGAffineTransformTranslate(tMatrix, CGFloat(xRel(iv.position.x)), CGFloat(yRel(iv.position.y)))
        tMatrix = CGAffineTransformRotate(tMatrix, (CGFloat(iv.rotation.degreesToRadians)))
        tMatrix = CGAffineTransformScale(tMatrix, CGFloat(iv.scale.x), CGFloat(iv.scale.y))
        view.transform = tMatrix
        
        
        if let labelview = view as? UILabel {
            labelview.textColor = UIColor(btfyColor: iv.textColor)
            labelview.font = UIFont(name: BtfyJson.parseTypeface(iv.textStyle), size: CGFloat(relWidth(iv.fontSize!)))
            labelview.textAlignment = iv.textAlign
            labelview.numberOfLines = 0
            labelview.lineBreakMode = .ByWordWrapping
        }
        
    }
    
    
    
    private func relWidth(width: Double) -> Double {
        return (width * Double(self.stageView.bounds.width))
    }
    
    private func relHeight(height: Double) -> Double {
        return (height * Double(self.stageView.bounds.height))
    }
    
    
    private func xRel(x: Double) -> Double {
        return (x * Double(self.stageView.bounds.width ))
    }
    
    private func yRel(y: Double) -> Double {
        return (y * Double(self.stageView.bounds.height))
    }
    
    func deviceOrientationDidChange() -> Void {
        setNeedsLayout()
    }
}
