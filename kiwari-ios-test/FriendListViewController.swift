//
//  FriendListVC.swift
//  kiwari-ios-test
//
//  Created by aegislabs on 18/09/19.
//  Copyright © 2019 fatahillah. All rights reserved.
//

import UIKit
import FirebaseAuth

class FriendListCell: UITableViewCell {
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
}

class FriendListViewController: UITableViewController {
    
    @IBAction func logOutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigateToLoginPage()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkAuthState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func checkAuthState() {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            // ...
        } else {
            // No user is signed in.
            // ...
            navigateToLoginPage()
        }
    }
    
    func navigateToLoginPage() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            else {
                return
        }
        
        present(loginViewController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendListCell
        
        cell.friendNameLabel.text = "WGWG \(indexPath.row)"

        

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
