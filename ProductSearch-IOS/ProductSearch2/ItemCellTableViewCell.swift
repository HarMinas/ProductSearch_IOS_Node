//
//  ItemCellTableViewCell.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/19/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
//PROTOTYPE CELL
class ItemCell: UITableViewCell{
    private var storage = UserDefaults.standard
    
    //Data
    var itemData: JSON!
    
    //Views
    var buttonView: UIView!
    var textContainer: UIView!
    var title: UILabel!
    var price: UILabel!
    var shipping: UILabel!
    var condition: UILabel!
    var location: UILabel!
    var myImage: UIImageView!
    var likeButton: UIButton!
    
    private var inCartImg = UIImage(named: "inWishlist")
    private var notInCartImg = UIImage(named: "notInWishlist")
    var liked = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        title = UILabel()
        price = UILabel()
        shipping = UILabel()
        condition = UILabel()
        location = UILabel()
        myImage = UIImageView()
        textContainer = UIView()
        buttonView = UIView()
        likeButton = UIButton(type: .custom)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupViews(){
        
        textContainer.addSubview(title)
        textContainer.addSubview(price)
        textContainer.addSubview(shipping)
        textContainer.addSubview(condition)
        textContainer.addSubview(location)
        textContainer.addSubview(myImage)
        
        self.addSubview(textContainer)
        self.addSubview(buttonView)
        
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        myImage.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        shipping.translatesAutoresizingMaskIntoConstraints = false
        condition.translatesAutoresizingMaskIntoConstraints = false
        location.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(buttonView)
        buttonView.addSubview(likeButton)
        
        adjustFonts()
        
        createAnchors()
        
    }
    
    
    
    
    private func createAnchors(){
        //image
        myImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        myImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        myImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        //textContainer
        textContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        textContainer.leftAnchor.constraint(equalTo: myImage.rightAnchor).isActive = true
        textContainer.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width * 0.5)).isActive = true
        
        //title
        title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 0).isActive = true
        title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 5).isActive = true
        title.rightAnchor.constraint(equalTo: textContainer.rightAnchor, constant: 10).isActive = true
        
        
        //price
        price.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        price.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 5).isActive = true
        
        //shipping
        shipping.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 2).isActive = true
        shipping.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 5).isActive = true
        
        //location
        location.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 5).isActive = true
        location.topAnchor.constraint(equalTo: shipping.bottomAnchor, constant: 2).isActive = true
        
        //condition
        condition.rightAnchor.constraint(equalTo: textContainer.rightAnchor, constant: -5).isActive = true
        condition.topAnchor.constraint(equalTo: shipping.bottomAnchor, constant: 2).isActive = true
        
        
        
        //Like Button View
        buttonView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        buttonView.leftAnchor.constraint(equalTo: textContainer.rightAnchor).isActive = true
        buttonView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        //Like Button
//        likeButton.frame.size = CGSize(width: 150, height: 150)

        likeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        likeButton.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
        
        likeButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        likeButton.imageView?.topAnchor.constraint(equalTo: likeButton.topAnchor).isActive = true
        likeButton.imageView?.leftAnchor.constraint(equalTo: likeButton.leftAnchor).isActive = true
        likeButton.imageView?.rightAnchor.constraint(equalTo: likeButton.rightAnchor).isActive = true
        likeButton.imageView?.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor).isActive = true

    }
    
    private func adjustFonts(){
        title.font = .boldSystemFont(ofSize: 16)
        price.font = .systemFont(ofSize: 14)
        condition.font = .systemFont(ofSize: 14)
        shipping.font = .systemFont(ofSize: 14)
        location.font = .systemFont(ofSize: 14)
        
        price.textColor = UIColor.init(red: 67/255, green: 128/255, blue: 238/225, alpha: 1)
        shipping.textColor = .lightGray
        location.textColor = .lightGray
        condition.textColor = .lightGray
        
        
    }
    
    
    
    
    //Like Button Logic
    func wireUpLikeButton(){
        
        let key = storage.string(forKey: itemData["itemId"].string!)
        if(key == nil){
            liked = false
            likeButton.setImage(notInCartImg, for: .normal)
            likeButton.addTarget(self, action: #selector(addToWishlist), for: .touchUpInside)
        }else{
            liked = true
            likeButton.setImage(inCartImg, for: .normal)
            likeButton.addTarget(self, action: #selector(removeFromWishlist), for: .touchUpInside)
        }
    }
    
    @objc private func addToWishlist(sender: UIButton){
        likeButton.setImage(inCartImg, for: .normal)
        likeButton.removeTarget(self, action: #selector(addToWishlist(sender:)), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(removeFromWishlist(sender:)), for: .touchUpInside)
        storage.set(itemData.rawString(), forKey: itemData["itemId"].string!)

    }
    
    @objc private func removeFromWishlist(sender: UIButton){
        likeButton.setImage(notInCartImg, for: .normal)
        likeButton.removeTarget(self, action: #selector(removeFromWishlist(sender:)), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(addToWishlist(sender:)), for: .touchUpInside)
        storage.removeObject(forKey: itemData["itemId"].string!)
    }
}



