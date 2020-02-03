//
//  detailsViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/14/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DetailsViewController: UITabBarController {
    var storage = UserDefaults.standard
    
    var infoView: InfoViewController!
    var shippingView: ShippingViewController!
    var photosView: PhotosViewController!
    var similarView: SimilarViewController!
   
    var item: JSON!
    var itemId: String!
    let liked = UIImage(named: "inWishlist")
    let unliked = UIImage(named: "notInWishlist")
    var isLiked: Bool!
    
    var itemDetails: JSON!
    private var urlEndpoint: String = "http://newproductsearchapp-hminasya-csci571-eachbase.us-west-1.elasticbeanstalk.com"

    //INITIALIZATION
    init(item: JSON) {
        super.init(nibName: nil, bundle: nil)
        self.item = item
        itemId = item["itemId"].string!
        getItemDetails()
        
        setupNavBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    
    
    func setupDetails(){
        infoView = InfoViewController(itemId: item["itemId"].string!)
        shippingView = ShippingViewController(item: item)
        photosView = PhotosViewController(itemTitle: item["title"].string!)  //DONE
        similarView = SimilarViewController(itemId: item["itemId"].string!)
        
        infoView.tabBarItem = UITabBarItem(title: "info", image: UIImage(named: "infoTab"), selectedImage: nil)
        
        shippingView.tabBarItem = UITabBarItem(title: "shipping", image: UIImage(named: "shippingTab"), selectedImage: nil)
        
        //Photos
        photosView.tabBarItem = UITabBarItem(title: "info", image: UIImage(named: "photosTab"), selectedImage: nil)
        
        similarView.tabBarItem = UITabBarItem(title: "similar", image: UIImage(named: "similarTab"), selectedImage: nil)
        
        
        self.viewControllers = [infoView, shippingView,  photosView, similarView]
    }
    
    
    private func setupNavBar(){
        var likeButton: UIBarButtonItem!
        if(storage.object(forKey: itemId) != nil){
//            likeButton = UIBarButtonItem(image: liked, style: .done, target: self, action: #selector(unlikePressed))
            likeButton = UIBarButtonItem()
            likeButton.action = #selector(unlikePressed)
            likeButton.image = liked
            likeButton.target = self
        }
        else{
            likeButton = UIBarButtonItem(image: unliked, style: .done, target: self, action: #selector(likePressed))
        }
        
        
        let facebookButton = UIBarButtonItem(image: UIImage(named: "facebook"), style: .plain, target: self, action: #selector(postOnFacebook))
        
      
        navigationItem.rightBarButtonItems =  [likeButton, facebookButton]
    }
    
    
    
    private func getItemDetails(){
        let query =  urlEndpoint + "/getItem?itemId=" + itemId
        Alamofire.request(query).validate().responseJSON {[weak self] response in
            switch response.result{
            case .success(let val):
                self!.itemDetails = JSON(val)
            case .failure(let err): print(err)
            }
        }
    }
    
    
    @objc private func postOnFacebook(sender: UIBarButtonItem){
        var query = "https://www.facebook.com/dialog/share?app_id=785412368489899&display=popup"
        query += "&href=" + itemDetails["link"].string! + "&redirect_uri=http://localhost:4200";
        let url = URL(string: query)
        
        UIApplication.shared.open(url!)
    }
    
    @objc private func likePressed(sender: UIBarButtonItem){
        print("likePressed")
        sender.image = liked
        sender.action = #selector(unlikePressed(sender:))
        storage.set(item.rawString(), forKey: itemId)
    }
    
    @objc private func unlikePressed(sender: UIBarButtonItem){
        print("unlikePressed")
        sender.image = unliked
        sender.action = #selector(likePressed(sender:))
        storage.removeObject(forKey: itemId)
    }
    
    


}
