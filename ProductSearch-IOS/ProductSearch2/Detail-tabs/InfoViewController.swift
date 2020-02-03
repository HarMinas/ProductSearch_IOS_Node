//
//  InfoViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/14/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner


class InfoViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate , UITableViewDataSource{
    //Layout
    private var margins: UILayoutGuide!
    
    //DATA
    private var itemId: String!
    private var imageURLs: [String]!
    private var itemDescriptions: [JSON]!
    private var link: String!
    private var itemTitle: String!
    private var itemPrice: String!
    private var numberOfExpectedImages: Int = 0
    
    //Views
    private var imageViews: [UIImageView]!
    private var images: [UIImage]!
    private var scrollView: UIScrollView!
    private var pages: UIPageControl!
    private var priceLabel: UILabel!
    private var titleLabel: UILabel!
    private var infoTable: UITableView!
    private var descriptionLabel: UILabel!
    private var descriptionIcon: UIImageView!
    //HTTP
    private var urlEndpoint: String = "http://newproductsearchapp-hminasya-csci571-eachbase.us-west-1.elasticbeanstalk.com"

    
    //INITIALIZERS
    init(itemId: String) {
        super.init(nibName: nil, bundle: nil)
        self.itemId = itemId
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        images = [UIImage]()
        imageViews = [UIImageView]()
        scrollView = UIScrollView()
        pages = UIPageControl()
        infoTable = UITableView()
        imageURLs = [String]()
        itemDescriptions = [JSON]()
        
        
        scrollView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(images.isEmpty){
            SwiftSpinner.show("Fetching Prodcut Details...")
            margins = view.safeAreaLayoutGuide
            view.backgroundColor = .white
            getProductDetails()
        }
    }
    
    
    
    //INSTANCE METHODS
    private func getProductDetails(){
        let query =  urlEndpoint + "/getItem?itemId=" + itemId
        Alamofire.request(query).validate().responseJSON {[weak self] response in
            switch response.result{
            case .success(let val):
                self?.handleResutls(json: JSON(val))
                self?.createViews()
            case .failure(let err): print(err)
            }
        }
    }
    
    
    //results Helper - takes the results from the incoming item details data and prepares class objects to be drawn on the screen
    private func handleResutls(json: JSON){
        let imgs = json["pictures"]["value"].array!
        for i in 0..<imgs.count{
            imageURLs.append(imgs[i].string!)
        }
        let dVals = json["itemDetails"].array!
        var str: String!
        for i in 0..<dVals.count{
            str =  dVals[i]["Name"].string!
            if(str != "Price"){
                itemDescriptions.append(dVals[i])
            }else{
                itemPrice = dVals[i]["Value"][0].string!
            }
        }
        
        itemTitle = json["title"].string!
        
    }
    
    
    
    
    //Creating the views - as soon as the handle results is finished parsing the results, fire this function to start drawind
    private func createViews(){
        //number of images that need to be fetched
         numberOfExpectedImages = imageURLs.count
        //fire the httpRequests
        getImages()
        //Setup the image scrollviews and page views and setup the image views
        setupScrollView()
        //Setup the title
        drawTitle(title: itemTitle)
        //Setup the price
        drawPrice(price: itemPrice)
        //Setup the table with descriptions
        setupDescription()
        setupTable()
        
        
    }
    
    
    //Getting images
    private func getImages(){
        for i in imageURLs{
            Alamofire.request(i).validate().responseData { [weak self]  response in
                switch response.result{
                case .success(let data):
                    self!.addImage(img: data)
                case .failure(let err): print(err)
                }
            }
        }
    }
    
    private func addImage(img: Data){
        images.append(UIImage(data: img)!)
        
        if(images.count == numberOfExpectedImages){
            createImages(images: images)
        }
    }
     //called only if the images are all fetched from the servers
    private func createImages(images: [UIImage]){
        for i in 0..<images.count{
            imageViews![i].image = images[i]
        }
        SwiftSpinner.hide()
    }
    
    
    
    
    
    

}



//this extension is used to draw all the views
extension InfoViewController{
    
    //   SECTION 1 - IMAGE DISPLAY WITH PAGINATION
    private func setupImageViews(){
        var xPos: CGFloat!
        var imgView: UIImageView!
        for i in 0..<numberOfExpectedImages{
            imgView = UIImageView()
        
            imageViews.append(imgView)
            scrollView.addSubview(imgView)
            
            imageViews[i].widthAnchor.constraint(equalTo: scrollView!.widthAnchor).isActive = true
            imageViews[i].heightAnchor.constraint(equalTo: scrollView!.widthAnchor).isActive = true
            
            
            imgView.frame.size = scrollView.frame.size
            
            imgView.translatesAutoresizingMaskIntoConstraints = false
            xPos = scrollView.frame.width * CGFloat(i)
            imgView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: xPos).isActive = true
        }
    }
    
    private func setupPageControl(){
        view.addSubview(pages)
        pages.translatesAutoresizingMaskIntoConstraints = false
        pages.topAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        pages.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        pages.pageIndicatorTintColor = UIColor(displayP3Red: 68/255, green: 127/255, blue: 238/255, alpha: 1)
        pages.currentPageIndicatorTintColor = .gray
        pages.currentPage = 0
        pages.numberOfPages = imageViews.count
    }
    
    private func setupScrollView(){
        let padding = view.frame.width * 0.1
        let top = view.safeAreaLayoutGuide.topAnchor
        view.addSubview(scrollView)
        
        scrollView.frame.size = CGSize(width: view.frame.width * 0.8, height: view.frame.height * 0.35)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topAnchor.constraint(equalTo: top, constant: padding/2).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: scrollView.frame.height).isActive = true

        
        let width = scrollView.frame.width * CGFloat(numberOfExpectedImages)
        scrollView.contentSize = CGSize(width: width, height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        setupImageViews()
        setupPageControl()
   
    }
    
    
    
    //   SECTION 2 - TITLE AND PRICE
    private func drawTitle(title: String){
        titleLabel = UILabel()
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.numberOfLines = 3
    
        titleLabel.topAnchor.constraint(equalTo: pages.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -25).isActive = true
        
    }
    
    private func drawPrice(price: String){
        priceLabel = UILabel()
        priceLabel.text = price
        view.addSubview(priceLabel)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        priceLabel.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 15).isActive = true
        priceLabel.textColor = UIColor(displayP3Red: 68/255, green: 127/255, blue: 238/255, alpha: 1)
        priceLabel.font = .boldSystemFont(ofSize: 16)
    }
    
    
    // SECTION 3 - TABLE OF INFORMATION
    private func setupTable(){
        infoTable.register(TableCell.self, forCellReuseIdentifier: "MyCell")
        infoTable.dataSource = self
        infoTable.delegate = self
        
        view.addSubview(infoTable)
        
        infoTable.translatesAutoresizingMaskIntoConstraints = false
        infoTable.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10).isActive = true
        infoTable.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 15).isActive = true
        infoTable.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -20).isActive = true
        infoTable.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 10).isActive = true

       
    }
    
    private func setupDescription(){
        descriptionIcon = UIImageView(image: UIImage(named: "description"))
        view.addSubview(descriptionIcon)
        descriptionIcon.translatesAutoresizingMaskIntoConstraints = false
        descriptionIcon.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10).isActive = true
        descriptionIcon.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 15).isActive = true
        
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "Description"
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: descriptionIcon.rightAnchor, constant: 10).isActive = true
        descriptionLabel.font = .boldSystemFont(ofSize: 14)
    }
    
    
}







//This extension is used to handle delegations
extension InfoViewController{
    //Carousel Scroll View
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == self.scrollView){
            let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
            pages.currentPage = page
        }
    }
    
    
    //TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableCell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! TableCell
//        print(itemDescriptions[indexPath.row])
        cell.name.text = itemDescriptions[indexPath.row]["Name"].string!
        cell.value.text = itemDescriptions[indexPath.row]["Value"][0].string!
        return cell
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 20.0
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
}
//// STEPS OF OPERATION



class TableCell: UITableViewCell {
    //INstance variables
    var name: UILabel!
    var value: UILabel!
    var nameContainer: UIView!
    var valContainer: UIView!
    
    //Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameContainer = UIView()
        valContainer = UIView()
        name = UILabel()
        value = UILabel()
        
        setLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setLabels(){
        self.addSubview(nameContainer)
        self.addSubview(valContainer)
        
        nameContainer.translatesAutoresizingMaskIntoConstraints = false
        valContainer.translatesAutoresizingMaskIntoConstraints = false
        
        nameContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        nameContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant:  20).isActive = true
        nameContainer.widthAnchor.constraint(equalToConstant: self.frame.width/2 - 20).isActive = true
//        nameContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        valContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        valContainer.leftAnchor.constraint(equalTo: nameContainer.rightAnchor).isActive = true
        valContainer.widthAnchor.constraint(equalToConstant: self.frame.width/2 - 20).isActive = true
//        valContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        
        
        nameContainer.addSubview(name)
        valContainer.addSubview(value)
        name.translatesAutoresizingMaskIntoConstraints = false
        value.translatesAutoresizingMaskIntoConstraints = false
        
        name.widthAnchor.constraint(equalTo: nameContainer.widthAnchor).isActive = true
        value.widthAnchor.constraint(equalTo: valContainer.widthAnchor).isActive = true

     
        
        
        
        name.font = .boldSystemFont(ofSize: 12)
        value.font = .systemFont(ofSize: 12)
        
        
        
    }
    
    
    
}


/*
    1. receive item Json in init
    2. setup views in viewWillAppear - turn on swift spinner
    3. call getItem api in viewWillAppear
    4. call getImages api in getItem callback
    5. setup views in getItem callback - setting the tables
  5.1. add image data to the images array one by one
    6. once pictures are in, attach them all to the UIImageViews - turn off swiftSpinner
 */
