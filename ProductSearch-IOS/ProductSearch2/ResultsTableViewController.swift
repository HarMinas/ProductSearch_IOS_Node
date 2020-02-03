//
//  ResultsTableViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/13/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Toast_Swift


class ResultsTableViewController: UITableViewController{
    
    
    //containers
    private var rawItems: [JSON]!
    private var items: [Item]!

    //Other variables
    private var numItems: Int!
    private var numImagesFetched: Int!
    
    //Details view Controller
    private var detailsVC: DetailsViewController!
    
    private var messageView: UIView!
    private var message: UILabel!
    
    private var timer: Timer!
    
    //Initializers
    init(query: String!){
        super.init(nibName: nil, bundle: nil)
        messageView = UIView()
        message = UILabel()
        timer = Timer()
        getItems(query: query)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    //Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Results"
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        
        //init variables
        items = [Item]()
        numItems = 0
        numImagesFetched = 0
        
//        tableView.dataSource = self
    }
    
    
    
    //Contacts the backend and receives items data
    private func getItems(query: String){
        
        Alamofire.request(query).validate().responseJSON {[weak self] response in
            switch response.result{
            case .success(let val):
                if let tempItems = JSON(val).array {
                    self!.rawItems = tempItems
                    self!.numItems = self!.rawItems.count
                    self!.buildItems()
                } else {
                    self!.showEmptyList()
                    SwiftSpinner.hide()
                }
               
            default: print("Failty request")
            }
        }
    }
    
    //Uses the rawItems and constructs an array of Item structs with fields set. Fetches image data for each item
    private func buildItems(){
        for i in 0..<numItems{
            items.append(Item())
            items[i].title = rawItems[i]["title"].string!
            items[i].price = rawItems[i]["price"].string!
            items[i].shipping = rawItems[i]["shipping"]["cost"]["value"].string!
            items[i].zip = rawItems[i]["zip"].string!
            items[i].condition = "New"
            
            
            
            let url = rawItems[i]["image"].string!
            Alamofire.request(url).validate().responseData { [weak self] response in
                switch response.result{
                case .success(let val):
                    self!.numImagesFetched += 1
                    self!.items[i].image = UIImage(data: val)
                    self!.isFetchingComplete()
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
    
    //checks if the fetching of all images is done
    private func isFetchingComplete(){
        if(numImagesFetched == numItems){
            buildTable()
        }
    }
    
    
    //Once fetching is done, builds the table
    private func buildTable(){
        self.clearsSelectionOnViewWillAppear = false
        tableView.dataSource = self
        tableView.reloadData()
        SwiftSpinner.hide()
    }
    

    

}
//End of class


//Message
extension ResultsTableViewController {
    private func addTargets(cell: ItemCell){
        if(cell.liked){
            cell.likeButton.addTarget(self, action: #selector(showAddMessage(sender:)), for: .touchUpInside)
            
        }else{
            cell.likeButton.addTarget(self, action: #selector(showRemoveMessage(sender:)), for: .touchUpInside)
        }
    }
    
    @objc private func showAddMessage(sender: UIButton){
        let cell = sender.superview?.superview as! ItemCell
        let mes = cell.title.text! + " was removed from wishist"
        showMessage(text: mes)
        cell.liked = true
        cell.likeButton.removeTarget(self, action: #selector(showAddMessage(sender:)), for: .touchUpInside)
        cell.likeButton.addTarget(self, action: #selector(showRemoveMessage(sender:)), for: .touchUpInside)
        if(timer != nil){
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {[weak self]_ in
            self!.messageView.removeFromSuperview()
        })
        
        
    }
    
    @objc private func showRemoveMessage(sender: UIButton){
        let cell = sender.superview?.superview as! ItemCell
        let mes = cell.title.text! + " was added to the wishist"
        showMessage(text: mes)
        cell.liked = false
        cell.likeButton.removeTarget(self, action: #selector(showRemoveMessage(sender:)), for: .touchUpInside)
        cell.likeButton.addTarget(self, action: #selector(showAddMessage(sender:)), for: .touchUpInside)
        if(timer != nil){
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {[weak self]_ in
            self!.messageView.removeFromSuperview()
        })
    }
    
    private func showMessage(text: String ){
        view.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        
        messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        messageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        messageView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.7)
        messageView.layer.cornerRadius = 10
        messageView.clipsToBounds = true
    
        messageView.addSubview(message)
        message.translatesAutoresizingMaskIntoConstraints = false
        message.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 10).isActive = true
        message.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: 10).isActive = true
        message.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: -10).isActive = true
        message.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -10).isActive = true

        message.textColor = .white
        message.text = text
        message.numberOfLines = 0
       
        
    }
    
    //remove the message
    @objc private func removeMessage(){
        messageView.removeFromSuperview()
    }
    
}

//Delegation methods
extension ResultsTableViewController {
    //tells the delegate the number of secitons to display
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //tells the delegate number of items to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numItems
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        cell.itemData = rawItems[indexPath.row] //ItemData
        
        cell.myImage.image = items[indexPath.row].image!
        cell.title.text = items[indexPath.row].title!
        cell.price.text = items[indexPath.row].price!
        cell.shipping.text = items[indexPath.row].shipping!
        cell.location.text = items[indexPath.row].zip!
        cell.condition.text = items[indexPath.row].condition!
        cell.wireUpLikeButton()
        
        addTargets(cell: cell)
        return cell
    }
    
    
    //Override tapping on the cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailsVC = DetailsViewController(item: rawItems[indexPath.row])
        detailsVC.setupDetails()
        navigationController?.pushViewController(detailsVC, animated: true)
    }

}





//Data Structures
extension ResultsTableViewController{
    private struct Item{
        var title: String!
        var price: String!
        var shipping: String!
        var zip: String!
        var condition: String!
        var image: UIImage!
    }
}




extension ResultsTableViewController{

    //Show Empty list
    private func showEmptyList(){
        let background = UIView()
        background.frame = UIScreen.main.bounds
        
        background.backgroundColor = UIColor(displayP3Red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
        self.view.addSubview(background)
        
        let foreground = UIView()
        background.addSubview(foreground)
        foreground.translatesAutoresizingMaskIntoConstraints = false
        foreground.heightAnchor.constraint(equalToConstant: 150).isActive = true
        foreground.widthAnchor.constraint(equalToConstant: 300).isActive = true
        foreground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        foreground.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true

        foreground.backgroundColor = .white
        foreground.layer.cornerRadius = 10
        foreground.clipsToBounds = true
        
        let title = UILabel()
        foreground.addSubview(title)
        title.text = "No Results!"
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: foreground.topAnchor, constant: 20).isActive = true
        title.centerXAnchor.constraint(equalTo: foreground.centerXAnchor).isActive = true
        title.font = .boldSystemFont(ofSize: 20)
        
        
        let desc = UILabel()
        foreground.addSubview(desc)
        desc.text = "Failed to fetch search results"
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        desc.centerXAnchor.constraint(equalTo: foreground.centerXAnchor).isActive = true
        
        
        let button = UIButton(type: .system)
        foreground.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Ok", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.bottomAnchor.constraint(equalTo: foreground.bottomAnchor, constant: -10).isActive = true
        button.centerXAnchor.constraint(equalTo: foreground.centerXAnchor).isActive = true
        button.addTarget(self, action: #selector(dismissError(sender:)), for: .touchUpInside)
        
    }
    
    @objc private func dismissError(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }


    
}


/* Program flow
    1. init with items data --Show Spinner
    2. for each item in the items data, create an item
    3. for each item, fetch the image and store image data in image field in item
    4. once all images are fetched, (check everytime image data is returned and increment fetched images by 1) initiate
       table building phase
    5. For each item, create a cell, set the fields and insert it into the table.
    6. Hide Spinner

 */
