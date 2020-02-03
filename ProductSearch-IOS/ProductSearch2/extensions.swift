//
//  extensions.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/13/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire



extension UIImageView {
  
    func downloadFromServer(url: URLConvertible){
        
        Alamofire.request(url).validate().responseData(completionHandler: {(data) in
            self.image = UIImage(data: data.data!)
        })
        
    }
}
