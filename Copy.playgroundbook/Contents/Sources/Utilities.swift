//
//  Utilities.swift
//  Book_Sources
//
//  Created by Yu Wang on 2019/3/18.
//

import SceneKit

//width: x, length: z, height: y
public func randomVector3InBox(position:SCNVector3,width:CGFloat,length:CGFloat,height:CGFloat)->SCNVector3{
    var x = CGFloat(0)
    var y = CGFloat(0)
    var z = CGFloat(0)
    
    x = CGFloat(position.x) + CGFloat.random(in: -width/2...width/2)
    y = CGFloat(position.y) + CGFloat.random(in: -height/2...height/2)
    z = CGFloat(position.z) + CGFloat.random(in: -length/2...length/2)
    return SCNVector3(x, y, z)
}

public func randomVector3InStandardBox(position:SCNVector3 = SCNVector3.zero) -> SCNVector3{
    return randomVector3InBox(position: position, width: 1, length: 1, height: 1)
}

public func transtitionView(_ view:UIView,withDuration duration:Double = 0.2,upWard:Bool = true){
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
        if upWard{
            view.transform = view.transform.translatedBy(x: 0, y: -120)
        }else{
            view.transform = view.transform.translatedBy(x: 0, y: 120)
        }
    })
}

public func addGradientLayer(view:UIView,on shimmerView:UIView,duration:Int = 3,delayInMilliseconds:Int = 0){
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
        UIColor.clear.cgColor, UIColor.clear.cgColor,
        UIColor.black.cgColor, UIColor.black.cgColor,
        UIColor.clear.cgColor, UIColor.clear.cgColor
    ]
    
    gradientLayer.locations = [0, 0.2, 0.4, 0.6, 0.8, 1]
    
    let angle = 45 * CGFloat.pi / 180
    let rotationTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
    gradientLayer.transform = rotationTransform
    view.layer.addSublayer(gradientLayer)
    gradientLayer.frame = view.frame
    
    shimmerView.layer.mask = gradientLayer
    
    gradientLayer.transform = CATransform3DConcat(gradientLayer.transform, CATransform3DMakeScale(3, 3, 0))
    
    let animation = CABasicAnimation(keyPath: "transform.translation.x")
    animation.duration = CFTimeInterval(duration)
    animation.repeatCount = Float.infinity
    animation.autoreverses = false
    animation.fromValue = -view.frame.width
    animation.toValue = view.frame.width
    animation.isRemovedOnCompletion = false
    animation.fillMode = CAMediaTimingFillMode.forwards
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
        gradientLayer.add(animation, forKey: "shimmerKey")
    }
}

public func +(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3(left.x+right.x,left.y+right.y,left.z+right.z)
}

public func -(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3(left.x-right.x,left.y-right.y,left.z-right.z)
}

public func *(left:SCNVector3,right:Float)->SCNVector3{
    return SCNVector3(left.x*right, left.y*right, left.z*right)
}

public func /(left:SCNVector3,right:Float)->SCNVector3{
    return SCNVector3(left.x/right, left.y/right, left.z/right)
}
