//
//  BottomToTop.swift
//  E-chase
//
//  Created by Parth Saxena on 1/7/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit

class BottomToTop: UIStoryboardSegue {
    override func perform() {
        var firstVCView = self.source.view as UIView!
        var secondVCView = self.destination.view as UIView!
        
        // Get the screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specify the initial position of the destination view.
        secondVCView?.frame = CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: screenHeight)
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            firstVCView?.frame = ((firstVCView?.frame)?.offsetBy(dx: 0.0, dy: -screenHeight))!
            secondVCView?.frame = (secondVCView?.frame.offsetBy(dx: 0.0, dy: -screenHeight))!
            
        }) { (Finished) -> Void in
            self.source.present(self.destination ,
                                animated: false,
                                completion: nil)
        }
        
    }
}
