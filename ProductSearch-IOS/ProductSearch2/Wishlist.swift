//
//  Wishlist.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/18/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire


class Wishlist: UIView, UITableViewDelegate, UITableViewDataSource {
    //Views
    private var wishlist: UITableView!
    private var totalLabel: UILabel!
    private var total: UILabel!
    private var emptyListLabel: UILabel!
    //Storage
    private var items: [Item]!
    private var itemKeys: [Any]?
    private var storage = UserDefaults.standard
    private var keys: [String]!
    private var rawItems: [JSON]!
    private var totalNum: Double!
    
    //Control Vars
    private var numExpected: Int!
    private var numFetched: Int!
    var detailsDelegate: WishlistDelegate!
    
    
    
    //View Controllers
    private var detailsVC: DetailsViewController!

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showWishlist()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
     func showWishlist() {
        SwiftSpinner.show("Fetching Items From Wishlist")
        items = [Item]()
        rawItems = [JSON]()
        wishlist = UITableView()
        totalLabel = UILabel()
        total = UILabel()
        numFetched = 0
        numExpected = 0
        totalNum = 0
        
        getItemsFromStorage(keys: Array(storage.dictionaryRepresentation().keys))
        
        if(numExpected < 1){
            emptyList()
            SwiftSpinner.hide()
        }else{
            self.addSubview(totalLabel)
            self.addSubview(total)
            setupTotal()
            fetchImages()
        }
    }
    
    
    
    



    
    
    //Removes an item from the stored location
    private func getItemsFromStorage(keys: [String]){
        for key in keys {
            if (Int(key) != nil){
                rawItems.append(JSON.init(parseJSON: storage.string(forKey: key)!))
            }
        }
        numExpected = rawItems.count
    }
    
    
    
    private func fetchImages(){
        for i in 0..<numExpected{
            items.append(Item())
            items[i].title = rawItems[i]["title"].string!
            items[i].price = rawItems[i]["price"].string!
            items[i].shipping = rawItems[i]["shipping"]["cost"]["value"].string!
            items[i].zip = rawItems[i]["zip"].string!
            items[i].condition = "New"
            totalNum! += Double(items[i].price.components(separatedBy: "$").last!)!
            //Fetching images
            let url = rawItems[i]["image"].string!
            Alamofire.request(url).validate().responseData { [weak self] response in
                switch response.result{
                case .success(let val):
                    self!.numFetched += 1
                    self!.items[i].image = UIImage(data: val)
                    self!.isFetchingComplete()
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
    //Build the table
    private func isFetchingComplete(){
        if(numExpected == numFetched){
            updateTotal(items: numExpected, tot: totalNum)
            setupTable()
            wishlist.delegate = self
            wishlist.dataSource = self
            wishlist.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
            wishlist.reloadData()
            SwiftSpinner.hide()
        }
    }
    
    
    //Total Setup
    private func setupTotal(){
       
      
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        total.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = self.safeAreaLayoutGuide

        totalLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
        totalLabel.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 10).isActive = true
        
        total.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
        total.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -10).isActive = true

        total.font = .boldSystemFont(ofSize: 18)
        totalLabel.font = .boldSystemFont(ofSize: 18)
    }
    
    private func updateTotal(items: Int, tot: Double){
        let roundedTot = String(format: "%.2f", tot)
        totalLabel.text = "Wishlist Total(\(items) items):"
        total.text = "$\(roundedTot)"
    }
    
    private func setupTable(){
        self.addSubview(wishlist)
        wishlist.translatesAutoresizingMaskIntoConstraints = false
        let margins = self.safeAreaLayoutGuide
        
        wishlist.topAnchor.constraint(equalTo: total.bottomAnchor, constant: 20).isActive = true
        wishlist.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        wishlist.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        wishlist.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    

    
    //Empty list label
    private func emptyList(){
        emptyListLabel = UILabel()
        self.addSubview(emptyListLabel)
        emptyListLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyListLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        emptyListLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        emptyListLabel.text = "No Items in Wishlist"
        emptyListLabel.font = .boldSystemFont(ofSize: 18)
    }
}

//END OF CLASS














//Table Delegates
extension Wishlist {
    //Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    //Create Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        cell.itemData = rawItems[indexPath.row] //ItemData
        
        cell.myImage.image = items[indexPath.row].image!
        cell.title.text = items[indexPath.row].title!
        cell.price.text = items[indexPath.row].price!
        cell.shipping.text = items[indexPath.row].shipping!
        cell.location.text = items[indexPath.row].zip!
        cell.condition.text = items[indexPath.row].condition!
//        cell.wireUpLikeButton()
        return cell
    }
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
      
            numExpected -= 1
            totalNum! -= Double(items[indexPath.row].price.components(separatedBy: "$").last!)!
            storage.removeObject(forKey: rawItems[indexPath.row]["itemId"].string!)
            items.remove(at: indexPath.row)
            rawItems.remove(at: indexPath.row)
            updateTotal(items: numExpected, tot: totalNum)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if(numExpected == 0){
                totalLabel.removeFromSuperview()
                total.removeFromSuperview()
                wishlist.removeFromSuperview()
                emptyList()
            }
        }
    }
    
    
    //Override tapping on the cell
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailsVC = DetailsViewController(item: rawItems[indexPath.row])
        detailsVC.setupDetails()
        detailsDelegate.showDetails(vc: detailsVC)
    }

}






//Data Structures
extension Wishlist{
    private struct Item{
        var title: String!
        var price: String!
        var shipping: String!
        var zip: String!
        var condition: String!
        var image: UIImage!
    }
}

protocol WishlistDelegate {
    func showDetails(vc: DetailsViewController)
}



/*   Program Flow - Show SwiftSpinner
 
    1. From the storage grab all items using the integer conversion of the set of all keys in the userdefaults.standard
    2. Convert the item string into json
    3. store JSON objects into itemsJSON array
    4. After all items are recovered from the userDefaults, populate the items array with Item structs
    5. Grab the picture data from the network using alamofire
    6. every time picture data is returned, increment the count of fetched images and check if all are recovered.
    7. Once all images are recovered, build table
    8. Hide SwiftSpinner
 
 */
