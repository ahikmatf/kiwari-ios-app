//
//  FriendListVC.swift
//  kiwari-ios-test
//
//  Created by aegislabs on 18/09/19.
//  Copyright © 2019 fatahillah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FriendListCell: UITableViewCell {
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
}

class FriendListViewController: UITableViewController {

    var myFriends: [QueryDocumentSnapshot] = []
    
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        title = "Friends"
        
        checkAuthState()
    }
    
    func checkAuthState() {
        let mySelf = Auth.auth().currentUser
        if mySelf != nil {
            // User is signed in.
            // ...
            loadFriendList()
        } else {
            // No user is signed in.
            // ...
            navigateToLoginPage()
        }
    }
    
    func loadFriendList () {
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.excludeMyself(users: querySnapshot!.documents)
            }
        }
    }
    
    func excludeMyself(users: Array<QueryDocumentSnapshot>) {

        for user in users {
            if user["email"] as? String == UserDefaults.standard.string(forKey: "email") ?? "" {
                UserDefaults.standard.set(user["name"], forKey: "name")
                UserDefaults.standard.set(user["avatar"], forKey: "avatar")
            } else {
                myFriends.append(user)
            }
        }
        
        self.tableView.reloadData()
        
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
        return myFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendListCell
        
        cell.friendNameLabel.text = myFriends[indexPath.row]["name"] as? String
        
        let url = URL(string: myFriends[indexPath.row]["avatar"] as! String)
        let data = try? Data(contentsOf: url!)
        cell.friendImageView.image = UIImage(data: data!)

        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(myFriends[indexPath.row]["email"], forKey: "friendEmail")
        UserDefaults.standard.set(myFriends[indexPath.row]["avatar"], forKey: "friendAvatar")
        UserDefaults.standard.set(myFriends[indexPath.row]["name"], forKey: "friendName")
        
        navigationController?.pushViewController(ChatViewController(), animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

    }

}
