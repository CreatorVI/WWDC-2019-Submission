//
//  BluredShadowView.swift
//  Book_Sources
//
//  Created by Yu Wang on 2019/3/18.
//

import UIKit

public class BluredShadowView: UIView {
    
    public var label:UILabel?
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.masksToBounds = true
        addShadow(color: UIColor.black)
        
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = 16
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(title:String){
        self.init()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = title
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ]
        )
        self.label = label
    }
}

public extension UIView {
    
    public func addShadow(color: UIColor,offsetBy:CGSize = CGSize(width: 0.8, height: 1.5),opacity:Float = 0.5) {
        layer.masksToBounds = false
        layer.shadowOffset = offsetBy
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}
