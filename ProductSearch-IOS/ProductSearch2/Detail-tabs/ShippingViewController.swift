//
//  ShippingViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/14/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ShippingViewController: UITableViewController {
    var itemData: JSON!


    
    //tableView variables
    private var numSections = 0
    
    private var seller: [[String]]!
    private var shipping: [[String]]!
    private var returns: [[String]]!
    
    private var sellerLink: String!
    private var hasStar: Bool!
    
    
    var margins: UILayoutGuide!
    
    
    ///Initializers
    init(item: JSON) {
        super.init(nibName: nil, bundle: nil)
        itemData = item
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        margins = view.safeAreaLayoutGuide
        view.backgroundColor = .white
        seller = [[String]]()
        shipping = [[String]]()
        returns = [[String]]()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HeaderCell.self, forHeaderFooterViewReuseIdentifier: "HeaderCell")
        tableView.register(DataCell.self, forCellReuseIdentifier: "DataCell")
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        getSeller()
        getShipping()
        styleTable()
        
        tableView.reloadData()

        
    }
    


 
    //Getting seller information and storing it in the selller
    private func getSeller(){
        var sellerTitles = [String]()
        var sellerData = [String]()
        let temp = itemData["seller"]
        
        if let obj = temp["storeName"]["value"].string{
            sellerTitles.append("Store Name")
            sellerData.append(obj)
            if let link = temp["storeURL"]["value"].string{
                sellerLink = link
            }
        }
        if let obj = temp["feedbackScore"]["value"].string{
            sellerTitles.append("Feedback Score")
            sellerData.append(obj)
        }
        if let obj = temp["popularity"]["value"].string{
            sellerTitles.append("Popularity")
            sellerData.append(obj)
        }
        if temp["feedbackStars"]["value"].string != nil{
            hasStar = true
        }
        
        if(sellerData.count > 0){
            seller.append(sellerTitles)
            seller.append(sellerData)
            numSections += 1
        }
        
      
       
        
    }
    

    //Getting seller information and storing it in the selller
    private func getShipping(){
        var shippingTitles = [String]()
        var shippingData = [String]()
        let temp = itemData["shipping"]
        
        if let obj = temp["cost"]["value"].string{
            shippingTitles.append("Shipping Cost")
            shippingData.append(obj)
        }
        if let obj = temp["toLocations"]["value"].string{
            shippingTitles.append("Global Shipping")
            if(obj == "Worldwide"){
                shippingData.append("Yes")
            }else{
                shippingData.append("No")
            }
        }
        if let obj = temp["handling"]["value"].string{
            shippingTitles.append("Handling Time")
            shippingData.append(obj)
        }
        
       
      
        if(shippingData.count > 0){
            shipping.append(shippingTitles)
            shipping.append(shippingData)
            numSections += 1
        }
    }
    

    
    
    private func styleTable(){
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }

    
 

}







extension ShippingViewController{
    
    //number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }

    //numver of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return seller[0].count
        }else if (section == 1){
            return shipping[0].count
        }
        return 0
    }

    //Cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! DataCell
        //cell is seller cell
        if(indexPath.section == 0){
            cell.title.text = seller[0][indexPath.row]
            if(cell.title.text == "Store Name"){
                cell.data.textColor = UIColor(displayP3Red: 60/255, green: 130/255, blue: 240/255, alpha: 1)
                cell.linkURL = sellerLink
                cell.setLink()
            }
            cell.data.text = seller[1][indexPath.row]
        }
        if(indexPath.section == 1){
            cell.title.text = shipping[0][indexPath.row]
            cell.data.text = shipping[1][indexPath.row]
        }
       
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: HeaderCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCell") as! HeaderCell
        if(section == 0){
            header.title.text = "Seller Info"
            header.image.image = UIImage(named: "seller")
        }
        if(section == 1){
            header.title.text = "Shipping Info"
            header.image.image = UIImage(named: "shipping")
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    
    
    
}





//HEADER
class HeaderCell: UITableViewHeaderFooterView{
    
    var image: UIImageView!
    var title: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        image = UIImageView()
        title = UILabel()
        adjustViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func adjustViews(){
        self.addSubview(title)
        self.addSubview(image)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        image.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        image.widthAnchor.constraint(equalToConstant: 25).isActive = true
        image.heightAnchor.constraint(equalToConstant: 25).isActive = true
        image.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        
        title.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
     
        title.font = .boldSystemFont(ofSize: 20)

    }
    
}


class DataCell: UITableViewCell {
    var title: UILabel!
    var data: UILabel!
    var link: UIButton!
    var linkURL: String!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        title = UILabel()
        data = UILabel()
        link = UIButton(type: .system)
        adjustViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func adjustViews(){
        self.addSubview(title)
        self.addSubview(data)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        data.translatesAutoresizingMaskIntoConstraints = false

        title.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        title.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2).isActive = true
        title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        


        data.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        data.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        data.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2).isActive = true
        data.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        title.textAlignment = .center
        data.textAlignment = .center
        
        title.font = .boldSystemFont(ofSize: 16)
        data.font = .boldSystemFont(ofSize: 16)
        
        title.textColor = .gray
        data.textColor = .gray
        
        
    

    }
    
    func setLink(){
        
        self.addSubview(link)
        link.translatesAutoresizingMaskIntoConstraints = false

        link.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        link.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        link.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2).isActive = true
        link.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        link.addTarget(self, action: #selector(openLink), for: .touchUpInside)
    }
    
    @objc private func openLink(sender: UIButton){
        if let temp = linkURL {
            if let url = URL(string: temp){
                UIApplication.shared.open(url)
            }
        }
    }
    
    
}


/* Program Flow
 
 */




