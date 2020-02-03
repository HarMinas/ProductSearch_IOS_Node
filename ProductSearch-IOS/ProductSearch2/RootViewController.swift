//
//  ViewController.swift
//  ProductSearch2
//
//  Created by Harutyun Minasyan on 4/12/19.
//  Copyright © 2019 Harutyun Minasyan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class RootViewController: UIViewController, SearchFormDelegate, WishlistDelegate {
    
    //UserDefaults
    private var storage: UserDefaults!
    //Control views
    private var pageToggle: UISegmentedControl!

    //View Controllers
    var results: ResultsTableViewController!
    
    
    //views
    private var searchForm = SearchForm()
    private var wishlist: Wishlist!
    private var rootView = UIView()
    
    private var viewFrame: CGRect!
    
    
    
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        viewFrame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
        loadApp()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }


    
    
    
    
    
    ////SETUP THE INITIAL App Loading
    private func loadApp(){
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        createPageTogggle(screenWidth: screenWidth)
        createSearchForm(screenWidth: screenWidth, screenHeight: screenHeight)
        searchForm.submitDelegate = self
        self.title = "Product Search"
    }
    
    
    // SearchForm Delegates
    func getResults(query: String) {
        SwiftSpinner.show("Loading Results")
        results = ResultsTableViewController(query: query)
        navigationController!.pushViewController(results, animated: true)
    }
    
    // Wishlist Delegate
    func showDetails(vc: DetailsViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    //CREATING VIEWS AND CONTROLS
    private func createPageTogggle(screenWidth: CGFloat){
        pageToggle = UISegmentedControl()
        pageToggle.frame = CGRect(x: 50, y: 130, width: screenWidth - 100, height: 30)
        pageToggle.insertSegment(withTitle: "SEARCH", at: 0, animated: true)
        pageToggle.insertSegment(withTitle: "WISH LIST", at: 1, animated: true)
        pageToggle.selectedSegmentIndex = 0
        pageToggle.addTarget(self, action: #selector(changePage), for: .valueChanged)
        view.addSubview(pageToggle)
    }
    
    private func createSearchForm(screenWidth: CGFloat, screenHeight: CGFloat ){
        searchForm.frame = viewFrame
        searchForm.createForm()
        view.addSubview(searchForm)
    }
    
    
    
    
    
    @objc private func changePage(sender: UISegmentedControl){
        if(sender.selectedSegmentIndex == 0){
            view.addSubview(searchForm)
            wishlist.removeFromSuperview()
        }else if (sender.selectedSegmentIndex == 1){
            wishlist = Wishlist(frame: viewFrame)
            wishlist.detailsDelegate = self
            view.addSubview(wishlist)
            searchForm.removeFromSuperview()
        }
    }
}


