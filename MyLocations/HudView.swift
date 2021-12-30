//
//  HudView.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/30/21.
//

import Foundation
import UIKit

class HudView: UIView {
    var text = ""
    
    // Drawing Constants
    let boxWidth: CGFloat = 150
    let boxHeight: CGFloat = 150
    let checkmarkBoxRatio: Double = 0.5 // For some reason XCode won't let me use this for setting checkmark rect...
 
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hud = HudView(frame: view.bounds)
        hud.isOpaque = false
        
        view.isUserInteractionEnabled = false
        view.addSubview(hud)
        
        hud.show()
        
        return hud
    }
    
    override func draw(_ rect: CGRect) {
        let boxRect = CGRect(
            x: round((bounds.width - boxWidth) / 2),
            y: round((bounds.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(
            roundedRect: boxRect,
            cornerRadius: 10)
        
        UIColor(white: 0.2, alpha: 0.6).setFill()
        roundedRect.fill()
        
        // Checkmark
        guard let image = UIImage(systemName: "checkmark")?.withTintColor(.white) else { return }
        let checkmarkRect = CGRect(x: round((bounds.width - boxWidth * 0.5) / 2 ),
                                   y: round((bounds.height - boxHeight) / 2 + boxHeight / 8),
                                   width: boxRect.width * 0.5,
                                   height: boxRect.height * 0.5)
        image.draw(in: checkmarkRect)
        
        // Text
        let attribs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attribs)
        let textOrigin = CGPoint(
            x: round((bounds.width - textSize.width) / 2 ),
            y: round((bounds.height + boxHeight * 0.6 - textSize.height) / 2 ))
        
        text.draw(at: textOrigin, withAttributes: attribs)
    }
    
    // Animation
    func show() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.6,
                       options: [],
                       animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: nil)
    }
    
    func exit() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
