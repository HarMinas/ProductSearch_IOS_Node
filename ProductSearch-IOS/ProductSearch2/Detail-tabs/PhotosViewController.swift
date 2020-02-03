//
//  PhotosViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/14/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner

class PhotosViewController: UIViewController {
    //Variables
    var itemTitle: String!
    var scrollView: UIScrollView!
    var images: [UIImageView]!
    var numberOfExpectedImages: Int = 0
    private var urlEndpoint: String = "http://newproductsearchapp-hminasya-csci571-eachbase.us-west-1.elasticbeanstalk.com"

    
    
    ///INITIALIZERs
    init(itemTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.itemTitle = itemTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        images = [UIImageView]()
        scrollView = UIScrollView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(images.isEmpty){
            SwiftSpinner.show("Fetching Google Images...")
            view.backgroundColor = .white
            createScrollView()
            getPhotos()
        }
     
    }
    
    
    //INSTANCE METHODS
    
    //Fetching image urls from the server
    private func getPhotos(){
        let rawQuery = urlEndpoint + "/getImages?title=" + itemTitle
        let query =  rawQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(query!).validate().responseJSON { [weak self]  response in
            switch response.result{
            case .success(let val):
                let json = JSON(val).array
                self?.getImageData(imageURLs: json!)
            case .failure(let err): print(err)
            }
        }
        
    }
    
    //Fetching image data from the server
    private func getImageData(imageURLs: [JSON]){
        numberOfExpectedImages = imageURLs.count
        
        var str: String!
        for i in imageURLs {
            str = i.string!
            Alamofire.request(str!).validate().responseData { [weak self] response in
                switch response.result{
                    case .success(let data):
                        self!.addImage(img: data)
                    case .failure(let err): print(err)
                }
            }
        }
    }
    

  //adding image into images array and checking if the
    private func addImage(img: Data){
        let imageView = UIImageView()
        imageView.image = UIImage(data: img)
        images.append(imageView)
        
        if(images.count == numberOfExpectedImages){
            createImages(images: images)
        }
    }
    
    //Create an image to display the fetched data
    private func createImages(images: [UIImageView]){
        var yPos: CGFloat!
        for i in 0..<numberOfExpectedImages{
            scrollView.addSubview(images[i])
            images[i].translatesAutoresizingMaskIntoConstraints = false
            images[i].widthAnchor.constraint(equalTo: scrollView!.widthAnchor).isActive = true
            
            images[i].frame.size = CGSize(width: scrollView.frame.width, height:  scrollView.frame.width)
            images[i].heightAnchor.constraint(equalTo: scrollView!.widthAnchor).isActive = true

            yPos = images[i].frame.height * CGFloat(i)
            images[i].topAnchor.constraint(equalTo: scrollView!.topAnchor, constant: yPos).isActive = true
         
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: images[0].frame.height * CGFloat(images.count))
        
        SwiftSpinner.hide()
    }
    
    ///View creation
    private func createScrollView(){
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let top = view.safeAreaLayoutGuide.topAnchor
        
        scrollView.topAnchor.constraint(equalTo: top).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
}
