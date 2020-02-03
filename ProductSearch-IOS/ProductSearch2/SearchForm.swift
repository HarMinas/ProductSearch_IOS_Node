//
//  searchForm.swift
//  ProductSearch
//
//  Created by Harutyun Minasyan on 4/9/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import McPicker
import Toast_Swift



class SearchForm: UIView, UITableViewDelegate, UITableViewDataSource{
    
    //Autolayout Vars
    private var xPos: CGFloat = 8
    private var yPos: CGFloat = 0
    
    //The UI elements for the forms
    private var keyword: UITextField!
    private var category: UITextField!
    private var new: UIButton!
    private var used: UIButton!
    private var unspecified: UIButton!
    private var localPickup: UIButton!
    private var freeShipping: UIButton!
    private var distance: UITextField!
    private var locToggle: UISwitch!
    private var zipcode: UITextField!
    private var search: UIButton!
    private var clear: UIButton!
    
    private var zipTable: UITableView!
    
    //Data Collections from the form
    private var switches: [String : Bool] = ["new": false, "used": false, "unspecified": false, "local": false, "free": false, "customZip": false]
    private var myLoc: String!
    private var currentLoc: String!
    private var categories = ["All": "0", "Art": "550", "Baby": "2984", "Books": "267",
                              "Clothing, Shoes &Accessories":"11450",
                              "Computers/Tablets & Networking":"58058",
                              "Health & Beauty":"26395", "Music" :"11233", "Video Games & Consoles":"1249"]
    
    
    public var data: Any!
    private var urlEndpoint: String = "http://newproductsearchapp-hminasya-csci571-eachbase.us-west-1.elasticbeanstalk.com"
    private var ipapi: String = "http://ip-api.com/json/"
    
    private var zipcodes = [String]()
    
    //DELEGATE
    var submitDelegate: SearchFormDelegate!
    
    
    
    
    //    INIT FOR THE FORM
    public func createForm(){
        createKeyword()
        createCategory()
        createCondition()
        createShipping()
        createDistance()
        createLocation()
        createButtons()
        getZipcode()
        createTable()
    }
    
    
    
    
    
    //Creation methods
    //Keyword
    private func createKeyword(){
        let label = createLabel(name: "Keyword", pos: CGPoint(x: xPos, y: yPos), bold: true)
        yPos += label.frame.height + 10
        keyword = createTextField(defaultVal: nil, pos: CGPoint(x: xPos, y: yPos))
        self.addSubview(label)
        self.addSubview(keyword)
        
        yPos += keyword.frame.height + 15
        
    }
    
    //Category
    private func createCategory(){
        let label = createLabel(name: "Category", pos: CGPoint(x: xPos, y: yPos), bold: true)
        yPos += label.frame.height + 10
        category = createTextField(defaultVal: nil, pos: CGPoint(x: xPos, y: yPos))
        category.text = "All"
        category.addTarget(self, action: #selector(chooseCategory), for: .editingDidBegin)
        
        self.addSubview(label)
        self.addSubview(category)
        
        yPos += category.frame.height + 15
        
    }
    
    //Condition
    private func createCondition(){
        var x = xPos + 20
        var label = createLabel(name: "Condition", pos: CGPoint(x: xPos, y: yPos), bold: true)
        self.addSubview(label)
        
        yPos += label.frame.height + 10
        
        let y = yPos
        //new
        new = createCheckbox(pos: CGPoint(x: x, y: yPos))
        new.addTarget(self, action: #selector(newCheckbox(sender:)), for: .touchUpInside)
        x += new.frame.width + 10
        label = createLabel(name: "New", pos: CGPoint(x: x, y: y), bold: false)
        self.addSubview(label)
        self.addSubview(new)
        
        x += label.frame.width + 10
        
        //used
        used = createCheckbox(pos: CGPoint(x: x, y: yPos))
        used.addTarget(self, action: #selector(usedCheckbox(sender:)), for: .touchUpInside)
        x += used.frame.width + 10
        label = createLabel(name: "Used", pos: CGPoint(x: x, y: y), bold: false)
        self.addSubview(label)
        self.addSubview(used)
        
        x += label.frame.width + 10
        
        //unspecified
        unspecified = createCheckbox(pos: CGPoint(x: x, y: yPos))
        unspecified.addTarget(self, action: #selector(unspecifiedCheckbox(sender:)), for: .touchUpInside)
        x += unspecified.frame.width + 10
        label = createLabel(name: "Unspecified", pos: CGPoint(x: x, y: y), bold: false)
        self.addSubview(label)
        self.addSubview(unspecified)
        
        yPos += unspecified.frame.height + 15
        
    }
    
    //Shipping
    private func createShipping(){
        var x = xPos + 20
        var label = createLabel(name: "Shipping", pos: CGPoint(x: xPos, y: yPos), bold: true)
        self.addSubview(label)
        
        yPos += label.frame.height + 10
        
        let y = yPos
        
        //Local
        localPickup = createCheckbox(pos: CGPoint(x: x, y: yPos))
        localPickup.addTarget(self, action: #selector(localCheckbox(sender:)), for: .touchUpInside)
        
        x += localPickup.frame.width + 10
        //        y += localPickup.frame.height/4
        label = createLabel(name: "Pickup", pos: CGPoint(x: x, y: y), bold: false)
        self.addSubview(label)
        self.addSubview(localPickup)
        
        x += label.frame.width + 10
        //free
        freeShipping = createCheckbox(pos: CGPoint(x: x, y: yPos))
        freeShipping.addTarget(self, action: #selector(freeCheckbox(sender:)), for: .touchUpInside)
        x += freeShipping.frame.width + 10
        label = createLabel(name: "Free Shipping", pos: CGPoint(x: x, y: y), bold: false)
        self.addSubview(label)
        self.addSubview(freeShipping)
        
        yPos += freeShipping.frame.height + 15
        
    }
    
    //Distance
    private func createDistance(){
        let label = createLabel(name: "Distance(Miles)", pos: CGPoint(x: xPos, y: yPos), bold: true)
        yPos += label.frame.height + 10
        distance = createTextField(defaultVal: nil, pos: CGPoint(x: xPos, y: yPos))
        distance.text = "10"
        self.addSubview(label)
        self.addSubview(distance)
        
        yPos += category.frame.height + 15
        
    }
    
    //Location
    private func createLocation(){
        
        let label = createLabel(name: "Custom Location", pos: CGPoint(x: xPos, y: yPos), bold: true)
        locToggle = UISwitch()
        locToggle.frame.size = CGSize(width: 50, height: 30)
        locToggle.frame.origin = CGPoint(x: UIScreen.main.bounds.width - (locToggle.frame.size.width + 10), y: yPos)
        locToggle.addTarget(self, action: #selector(toggleZip(sender:)), for: .valueChanged)
        
        yPos += locToggle.frame.height + 10
        
        zipcode = createTextField(defaultVal: nil, pos: CGPoint(x: xPos, y: yPos))
        zipcode.addTarget(self, action: #selector(getZipcodes(sender:)) , for: .editingChanged)
        zipcode.placeholder = "Zipcode"
        
        
        self.addSubview(label)
        self.addSubview(zipcode)
        self.addSubview(locToggle)
        
        zipcode.isHidden = true
        
        yPos += category.frame.height + 15
        
        
    }
    
    
    
    
    //Category Handler
    @objc private func chooseCategory(sender: UITextView){
        let keys = [String](categories.keys)
        McPicker.show(data: [keys]) { [weak self] (selection: [Int : String])->Void in
            if let name = selection[0]{
                self!.category.text = name
                self!.category.endEditing(true)
            }
        }
    }
    
    
    
    //Search and Clear buttons
    private func createButtons(){
        let buttonTextColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
        xPos += 20
        search = UIButton(type: .system)
        search.setTitle("SEARCH", for: .normal)
        search.setTitleColor(buttonTextColor, for: .normal)
        search.backgroundColor = UIColor(displayP3Red: 52/255, green: 121/255, blue: 246/255, alpha: 1)
        search.frame.size = CGSize(width: UIScreen.main.bounds.width/2.5, height: 40)
        search.frame.origin = CGPoint(x: xPos, y: zipcode.frame.origin.y)
        search.layer.cornerRadius = 10
        search.clipsToBounds = true
        
        
        search.addTarget(self, action: #selector(submit(sender:)), for: .touchUpInside)
        self.addSubview(search)
        
        xPos += search.frame.width + 20
        //        print(search.frame.width)
        
        clear = UIButton(type: .system)
        clear.setTitle("CLEAR", for: .normal)
        clear.setTitleColor(buttonTextColor, for: .normal)
        clear.backgroundColor = UIColor(displayP3Red: 52/255, green: 121/255, blue: 246/255, alpha: 1)
        clear.frame.size = CGSize(width: UIScreen.main.bounds.width/2.5, height: 40)
        clear.frame.origin = CGPoint(x: xPos, y: zipcode.frame.origin.y)
        clear.layer.cornerRadius = 10
        clear.clipsToBounds = true
        clear.addTarget(self, action: #selector(clear(sender:)), for: .touchUpInside)
        self.addSubview(clear)
    }


    
    
    
    
    
    
    
    
    
    
    //Handlers
    //Checkboxes
    @objc private func newCheckbox(sender: UIButton){
        
        switches["new"] = !(switches["new"]!)
        if(switches["new"]!){
            sender.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            
        }else{
            sender.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        }
        
    }
    @objc private func usedCheckbox(sender: UIButton){
        
        switches["used"] = !(switches["used"]!)
        if(switches["used"]!){
            sender.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            
        }else{
            sender.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        }
    }
    @objc private func unspecifiedCheckbox(sender: UIButton){
        
        switches["unspecified"] = !(switches["unspecified"]!)
        if(switches["unspecified"]!){
            sender.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            
        }else{
            sender.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        }
    }
    @objc private func localCheckbox(sender: UIButton){
        
        switches["local"] = !(switches["local"]!)
        if(switches["local"]!){
            sender.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            
        }else{
            sender.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        }
    }
    @objc private func freeCheckbox(sender: UIButton){
        
        switches["free"] = !(switches["free"]!)
        if(switches["free"]!){
            sender.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            
        }else{
            sender.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        }
    }
    
    
    //Toggle
    @objc private func toggleZip(sender: UISwitch){
        zipcode.isHidden = !(locToggle.isOn)
        if (zipcode.isHidden){
            search.frame.origin.y = zipcode.frame.origin.y
            clear.frame.origin.y = zipcode.frame.origin.y
            zipTable.isHidden = true
        }else {
            search.frame.origin.y = yPos
            clear.frame.origin.y = yPos

        }
    }
    
    
    @objc private func getZipcodes(sender: UITextField){
        if let x = zipcode.text{
            if(x.count < 5){
                var query: String = urlEndpoint
                query +=  "/getZipcodes?startsWith=" + sender.text!
                
                Alamofire.request(URL(string: query)!).validate().responseJSON {response in
                    switch response.result{
                    case .success(let val):
                        let json = JSON(val)
                        self.buildTable(vals: json.array!)
                    case .failure(let error):
                        print(error)
                    }
                }
            }else{
                zipTable.isHidden = true
            }
        }
    

    }
    
    //Submit
    @objc private func submit(sender: UIButton){
        
        if(validateForm()){
            let queryString: String = createQueryString()
            submitDelegate.getResults(query: queryString)
        }
    }
    
    
    
    //Clear
    @objc private func clear(sender: UIButton){
        keyword.text = ""
        category.text = "All"
        new.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        used.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        unspecified.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        localPickup.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        freeShipping.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        
        switches = ["new": false, "used": false, "unspecified": false, "local": false, "free": false, "customZip": false]
        distance.text = String(10)
        currentLoc = myLoc
        
        locToggle.isOn = false
        zipTable.isHidden = true
        zipcodes.removeAll()
        search.frame.origin.y = zipcode.frame.origin.y
        clear.frame.origin.y = zipcode.frame.origin.y
        zipcode.isHidden = true

    }
    
    
    
    
    
    
    //FORM VALIDATION
    private func validateForm()->Bool{
        //Keyword is empty
        if (keyword.text!.trimmingCharacters(in: .whitespaces).isEmpty){
            
            makeToast("Keyword Mandatory")
            return false
        }
        
        //Zipcode Validation
        if(locToggle.isOn){
            if(zipcode.text!.trimmingCharacters(in: .whitespaces).isEmpty){
                
                makeToast("Zipcode Mandatory")
                return false
            }
            if(!validateZip(zip: zipcode.text!)){
                makeToast("Zipcode invalid")
                return false
            }
        }
        
        return true
    }
    
    
    
    
    
    
    
    
    //Helpers - HTTP
    private func createQueryString()->String{
        if(locToggle.isOn){
            currentLoc = zipcode.text!
            if(!validateZip(zip: currentLoc))
            {
                print("Zipcode is not valid");
            }
        }
        let modKeyword = keyword.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        var query = urlEndpoint
        query += "/getItems?"
        query += "keyword="+modKeyword!
        query += "&category=" + categories[category.text!]!
        query += "&new=" + convertBoolToString(val: switches["new"]!)
        query += "&used=" + convertBoolToString(val: switches["new"]!)
        query += "&unspecified=" + convertBoolToString(val: switches["new"]!)
        query += "&local=" + convertBoolToString(val: switches["local"]!)
        query += "&free=" + convertBoolToString(val: switches["free"]!)
        query += "&distance=" + distance.text!
        query += "&zip=" + currentLoc
        
        print("THE QUERY STRING IS: " + query)
        return query
    }
    
    
    private func convertBoolToString(val: Bool)->String{
        if(val){
            return "true"
        }else{
            return "false"
        }
    }
    
    
    
    //IP API Code
    private func getZipcode(){
        Alamofire.request(URL(string: ipapi)!, method: .get).validate().responseJSON {[weak self ] response in
            if let weakself = self {
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    weakself.receiveLocationData(incomingData: json["zip"].string!)
                default: weakself.receiveLocationData(incomingData: "000000")
                }
            }
            
        }
    }
    
    private func receiveLocationData(incomingData: String){
        myLoc = incomingData
        currentLoc = incomingData
    }
    
    
    
    
    
    //validate zipcode
    private func validateZip(zip: String)->Bool{
        let regex = "[0-9]{5,5}"
        let numMatches = zip.range(of: regex, options: .regularExpression, range: nil, locale: nil)
        if(numMatches != nil){
            print("currect zip")
            return true
        }
        
        return false
        
    }
    
    
    
    
    //    DONE ************
    //Helpers - creating UI elements
    //Creating labels
    let labelSize = CGSize(width: 0, height: 0)
    
    private func createLabel(name: String, pos: CGPoint, bold: Bool)->UILabel{
        let label = UILabel()
        label.frame = CGRect(origin: pos, size: labelSize)
        label.text = name
        if (bold){
            label.font = UIFont.boldSystemFont(ofSize: 18.0)
        }
        label.sizeToFit()
        
        return label
    }
    
    //Creating TextFields
    let textSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 40)
    
    private func createTextField(defaultVal: String?, pos: CGPoint )->UITextField{
        let textfield = UITextField()
        textfield.frame = CGRect(origin: pos, size: textSize)
        textfield.borderStyle = .roundedRect
        
        
        return textfield
    }
    
    //Creating a button
    
    private func createCheckbox(pos: CGPoint)->UIButton{
        let button = UIButton()
        button.setImage(UIImage(named: "unchecked"), for: .normal)
        button.frame.origin = pos
        button.frame.size = CGSize(width: 20, height: 20)
        //      button.sizeToFit()
        
        return button
    }
    
    

    //CREATING THE TABLE
    private func createTable(){
        zipTable = UITableView()
        
        zipTable.register(ZipCell.self, forCellReuseIdentifier: "ZipCell")
        zipTable.dataSource = self
        zipTable.delegate = self
        
        self.addSubview(zipTable)
        
        zipTable.translatesAutoresizingMaskIntoConstraints = false
        zipTable.topAnchor.constraint(equalTo: zipcode.bottomAnchor).isActive = true
        zipTable.leftAnchor.constraint(equalTo: zipcode.leftAnchor).isActive = true
        zipTable.rightAnchor.constraint(equalTo: zipcode.rightAnchor).isActive = true
        zipTable.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        zipTable.layer.borderColor = UIColor.black.cgColor
        zipTable.layer.borderWidth = 2
        zipTable.layer.cornerRadius = 5
        zipTable.clipsToBounds = true
        zipTable.isHidden = true
    }
}


//TABLE VIEW DELEGATE
extension SearchForm {
    
    private func buildTable(vals: [JSON]){
        zipcodes.removeAll()
        for i in 0..<vals.count{
            zipcodes.append(vals[i].string!)
        }
        if(zipcodes.count > 0){
            zipTable.reloadData()
            zipTable.isHidden = false
        }else{
            zipTable.isHidden = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zipcodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ZipCell = tableView.dequeueReusableCell(withIdentifier: "ZipCell", for: indexPath) as! ZipCell
        cell.zipcode.text = zipcodes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        zipcode.text = zipcodes[indexPath.row]
        zipTable.isHidden = true
    }
}


class ZipCell: UITableViewCell{
   var zipcode: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        zipcode = UILabel()
        zipcode.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(zipcode)
        
        zipcode.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        zipcode.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        
        zipcode.font = .boldSystemFont(ofSize: 18)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

