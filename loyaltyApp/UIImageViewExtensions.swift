//
//  UIImageViewExtensions.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/28/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode, image:UIImage?, callback:(image:UIImage?) -> Void) {
        if let savedImage = image {
            self.image = savedImage
            callback(image: savedImage)
        } else {
            guard
                let url = NSURL(string: link)
                else {return}
            contentMode = mode
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                guard
                    let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                    let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                    let data = data where error == nil,
                    let image = UIImage(data: data)
                    else { return }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.image = image
                    callback(image: image)
                }
            }).resume()
        }
        
        
        
    }
}

