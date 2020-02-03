//
//  SimilarViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/14/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner

class SimilarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
    //data containers
    private var itemId: String!
    private var urlEndpoint: String = "http://newproductsearchapp-hminasya-csci571-eachbase.us-west-1.elasticbeanstalk.com"
    private var rawItems: [JSON]!
    private var numberOfItems: Int!
    private var numImagesFetched: Int!
    private var items: [SimilarItem]!
    private var defaultItems: [SimilarItem]!
    
    
    
    //views
    private var sortFilter: UISegmentedControl!
    private var sortOrder: UISegmentedControl!
    private var collection: UICollectionView!
    
    //Initializers
    init(itemId: String) {
        super.init(nibName: nil, bundle: nil)
        self.itemId = itemId
        self.numberOfItems = 0
        self.numImagesFetched = 0
        self.items = [SimilarItem]()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    ///LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Similar Items")
        self.view.backgroundColor = .white
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getItems()
    }
    
    
    
    //Getting Items
    private func getItems(){
       let query = urlEndpoint + "/getSimilarItems?itemId=" + itemId
        Alamofire.request(query).validate().responseJSON {[weak self] response in
            switch response.result{
            case .success(let val):
                print(JSON(val))
                //Here insert error checking (ack == 1 is good, else == bad)
                self!.rawItems = JSON(val)["items"].array!
                self!.numberOfItems = self!.rawItems.count
                self!.buildItems()
            case .failure(let err): print(err)
            }
        }
    }
    
    
    //After getting the similar Items data, we initiate the building of views.
    private func buildItems(){
        var url: String!
        for i in 0..<numberOfItems{
            items.append(SimilarItem())
            
            items[i].title = rawItems[i]["title"].string!
            items[i].price = rawItems[i]["price"]["value"].string!
            items[i].shipping = rawItems[i]["shipping"]["value"].string!
            items[i].daysLeft = rawItems[i]["daysLeft"]["value"].string!
            items[i].link = rawItems[i]["link"].string!
            
            url = rawItems[i]["picture"].string
            
            Alamofire.request(url).validate().responseData {[weak self] response in
                switch response.result{
                case .success(let val):
                    self!.items[i].image  = UIImage(data: val)
                    self!.numImagesFetched += 1
                    self!.isFetchingComplete()
                case .failure(let err): print(err)
                }
            }
        }
    }
    
    private func isFetchingComplete(){
        if(numImagesFetched == numberOfItems){
            defaultItems = items
            buildView()
            
        }
    }
    
    
    private func buildView(){
        buildSortFilters()
        buildOrderFilters()
        setupCollection()
        SwiftSpinner.hide()
    }
  
    
}










//Creates the page controls
extension SimilarViewController{
    //Filter
    private func buildSortFilters(){
        let label = UILabel()
        sortFilter = UISegmentedControl()
        view.addSubview(label)
        view.addSubview(sortFilter)
        label.translatesAutoresizingMaskIntoConstraints = false
        sortFilter.translatesAutoresizingMaskIntoConstraints = false

        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        label.leftAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        
        sortFilter.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        sortFilter.leftAnchor.constraint(equalTo: label.leftAnchor).isActive = true
        sortFilter.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true

        
        label.text = "Sort By"
        label.font = .boldSystemFont(ofSize: 16)
        
        let filters = ["Default", "Name", "Price", "Days Left", "Shipping"]
        for i in 0..<filters.count{
            sortFilter.insertSegment(withTitle: filters[i], at: i, animated: true)
        }
    
        sortFilter.selectedSegmentIndex = 0
        
        sortFilter.addTarget(self, action: #selector(sortItems), for: .valueChanged)
    }
    
    //Order
    private func buildOrderFilters(){
        sortOrder = UISegmentedControl()
        let label = UILabel()
        view.addSubview(label)
        view.addSubview(sortOrder)
        
        label.text = "Order"
        label.font = .boldSystemFont(ofSize: 16)

        label.translatesAutoresizingMaskIntoConstraints = false
        sortOrder.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: sortFilter.bottomAnchor, constant: 10).isActive = true
        label.leftAnchor.constraint(lessThanOrEqualTo: sortFilter.leftAnchor).isActive = true
        
        
        sortOrder.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        sortOrder.leftAnchor.constraint(equalTo: label.leftAnchor).isActive = true
        sortOrder.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        sortOrder.insertSegment(withTitle: "Ascending", at: 0, animated: true)
        sortOrder.insertSegment(withTitle: "Descending", at: 1, animated: true)
        sortOrder.selectedSegmentIndex = 0
        
        sortOrder.addTarget(self, action: #selector(changeOrder), for: .valueChanged)
        sortOrder.isEnabled = false
    }
    
    
    
}





//Building the collectionView
extension SimilarViewController{
    private func setupCollection(){
        
        let collectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionLayout.itemSize = CGSize(width: view.frame.width * 0.45, height: view.frame.height * 0.35)
        
        
        collection = UICollectionView(frame: view.frame, collectionViewLayout: collectionLayout)
        collection.dataSource = self
        collection.delegate = self
        collection.register(CollectionItem.self, forCellWithReuseIdentifier: "MyItem")
        
        view.addSubview(collection)
        collection.reloadData()
        let safeArea = view.safeAreaLayoutGuide
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        collection.topAnchor.constraint(equalTo: sortOrder.bottomAnchor, constant: 10).isActive = true
        collection.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        collection.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true
        
        collection.backgroundColor = .white
    }
}

//Handling collection view delegation
extension SimilarViewController{
    
    //tells delegate how many items to render
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    //creates the cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        print("TRYING TO CREATE A CELL")
//
        let cell: CollectionItem = collection.dequeueReusableCell(withReuseIdentifier: "MyItem", for: indexPath) as! CollectionItem

//        print(items[indexPath.row])
        let numDaysLeft = Int(items[indexPath.row].daysLeft)
        var daysLeft: String!
        if(numDaysLeft == 1){
            daysLeft = " Day Left"
        }else{
            daysLeft = " Days Left"
        }
      
        cell.imageView.image = items[indexPath.row].image
        cell.title.text = items[indexPath.row].title
        cell.shippingCost.text = items[indexPath.row].shipping
        
        cell.daysLeft.text = items[indexPath.row].daysLeft + daysLeft
        cell.price.text = items[indexPath.row].price
        cell.link = items[indexPath.row].link
        
        
        return cell
    }
    
    //called when a user taps on a cell. opens safari and in a new tab, opens he ebay page of the item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collection.cellForItem(at: indexPath) as! CollectionItem
        if let link = cell.link {
            if let url = URL(string: link){
                UIApplication.shared.open(url)
            }
        }
    }

    
    
}

//Handle Sorting
extension SimilarViewController {
    
    
    @objc private func sortItems(sender: UISegmentedControl){
        switch (sender.selectedSegmentIndex){
        //default
        case 0:
            sortByDefault()
            sortOrder.selectedSegmentIndex = 0
            sortOrder.isEnabled = false
            break
        case 1:
            items = items.sorted(by: {sortByName(i1: $0, i2: $1)});
            sortOrder.isEnabled = true
            checkOrder()
            break
        case 2:
            items = items.sorted(by: {sortByPrice(i1: $0, i2: $1)});
             sortOrder.isEnabled = true
            checkOrder()
            break
        case 3:
            items = items.sorted(by: {sortByDaysLeft(i1: $0, i2: $1)});
             sortOrder.isEnabled = true
            checkOrder()
            break

        case 4:
            items = items.sorted(by: {sortByShipping(i1: $0, i2: $1)});
            sortOrder.isEnabled = true
            checkOrder()
            break
        default: sortByDefault()
        }
        collection.reloadData()
    }
    
    @objc private func changeOrder(sender: UISegmentedControl){
        items.reverse()
        collection.reloadData()
    }
    
    
    
    private func sortByName(i1: SimilarItem, i2: SimilarItem)->Bool{
        let name1 = i1.title.lowercased()
        let name2 = i2.title.lowercased()
        
        return name1 < name2
    }
    private func sortByPrice(i1: SimilarItem, i2: SimilarItem)->Bool{
        let num1 = Double(i1.price.components(separatedBy: "$").last!)!
        let num2 = Double(i2.price.components(separatedBy: "$").last!)!
        
        return num1 < num2
    }
    private func sortByDaysLeft(i1: SimilarItem, i2: SimilarItem)->Bool{
        let num1 = Int(i1.daysLeft.components(separatedBy: " ").first!)!
        let num2 = Int(i2.daysLeft.components(separatedBy: " ").first!)!
        
        return num1 < num2
    }
    private func sortByShipping(i1: SimilarItem, i2: SimilarItem)->Bool{
        let num1 = Double(i1.shipping.components(separatedBy: "$").last!)!
        let num2 = Double(i2.shipping.components(separatedBy: "$").last!)!
        
        return num1 < num2
    }
    private func sortByDefault(){
        items = defaultItems
    }
    
 
    
    private func checkOrder(){
        if(sortOrder.selectedSegmentIndex == 1){
            items.reverse()
        }
    }
}


//Data Structures
extension SimilarViewController{
    //To hold item info
    private struct SimilarItem {
        var price: String!
        var title: String!
        var daysLeft: String!
        var shipping: String!
        var link: String!
        var image: UIImage!
    }
    
}


//PROTOTYPE ITEM
class CollectionItem: UICollectionViewCell{
    var imageView: UIImageView!
    var textArea: UIView!
    var title: UILabel!
    var price: UILabel!
    var daysLeft: UILabel!
    var shippingCost: UILabel!
    var imageURL: String!
    var link: String!
    
    
    
    //lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.layer.borderWidth = CGFloat(1.0)
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        createImageView()
        createTextView()
        addTextLabels()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    
    //Creating the imageView
    private func createImageView(){
        imageView = UIImageView()
        self.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(self.bounds.height * 0.4)).isActive = true
        

    }
    
    //Creating the text area that will hold the information
    private func createTextView(){
        textArea = UIView()
        self.addSubview(textArea)
        
        textArea.translatesAutoresizingMaskIntoConstraints = false
        
        textArea.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        textArea.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        textArea.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textArea.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        textArea.backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        
    }
    
    private func addTextLabels(){
        //title
        title = UILabel()
        textArea.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: textArea.topAnchor, constant: 5).isActive = true
        title.leftAnchor.constraint(equalTo: textArea.leftAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(equalTo: textArea.rightAnchor , constant: -10).isActive = true
        title.numberOfLines = 3
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 16)
        
        //price
        shippingCost = UILabel()
        textArea.addSubview(shippingCost)
        shippingCost.translatesAutoresizingMaskIntoConstraints = false
        shippingCost.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        shippingCost.leftAnchor.constraint(equalTo: textArea.leftAnchor , constant: 10).isActive = true
        shippingCost.font = .systemFont(ofSize: 14)
        
        //days left
        daysLeft = UILabel()
        textArea.addSubview(daysLeft)
        daysLeft.translatesAutoresizingMaskIntoConstraints = false
        daysLeft.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        daysLeft.rightAnchor.constraint(equalTo: textArea.rightAnchor, constant: -10).isActive = true
        daysLeft.font = .systemFont(ofSize: 14)
        
        //price
        price = UILabel()
        textArea.addSubview(price)
        price.translatesAutoresizingMaskIntoConstraints = false
        price.topAnchor.constraint(equalTo: daysLeft.bottomAnchor, constant: 5).isActive = true
        price.rightAnchor.constraint(equalTo: textArea.rightAnchor, constant: -10).isActive = true
        price.textColor = UIColor(displayP3Red: 68/255, green: 127/255, blue: 238/255, alpha: 1)
        price.font = .boldSystemFont(ofSize: 16)
        
        
    }
    
//
//
//    override func prepareForReuse() {
//        self.imageView.image = nil
//    }
//
    
    
    
}










/*    Program flow
    1. init with item id
    2. show spinner
    3. fetch similaritems
    4. check ack from 3. results
    5. if good, for each item, create a similar item in items array, populate the fields
    6. for image field in every similar item, fetch image using the url from raw items
    7. once results come back, create a UIImage with the imae data and give it to the similar item that requested the image
    8. every time check if all images are back
    9. once all images are back, launch the presentation sequence
    10. for evey item, create a cell and populate the collection view
    11. create and present the segmented controls, linked to their handlers.
    12. Hide the spinner
    13. inside the handlers, perform sorting and update the table
 */
