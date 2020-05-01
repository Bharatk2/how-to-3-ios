//
//  AllGuidesTableViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/30/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreData
class AllGuidesTableViewController: UITableViewController {

    // MARK: - Properties
    var guidesDetailController: GuidesDetailViewController?
    var backendController = BackendController.shared
    var objectPosts: [NSManagedObject] = []
     lazy var fetchedResultsController: NSFetchedResultsController<Post>  = {
             let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
             let context = CoreDataStack.shared.mainContext
             context.reset()
             fetchRequest.sortDescriptors = [NSSortDescriptor(key: "likes", ascending: true)]
             let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
             frc.delegate = self
       
        do {
             try frc.performFetch()
        } catch {
                NSLog("Error in fetching the posts.")
            }
         return frc
         }()
    // MARK: - Outlets

    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: - Protocol Conforming

    // MARK: - Custom Methods
  
    @IBAction func unwindSegue(segue:UIStoryboardSegue) { }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 searchBar.delegate = self
        searchBar(searchBar, textDidChange: "")
        
        if backendController.isSignedIn {
                backendController.syncPosts { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            NSLog("Error trying to fetch posts: \(error)")
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "AllGuidesCell", for: indexPath) as? MainPostTableViewCell else {
            return UITableViewCell() }
        cell.post = fetchedResultsController.object(at: indexPath)
    
        return cell
    }
    
   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

//    The closure returns:
//    1. Only an error if something went wrong
//    2. Only a bool value if we communicated with the server successfully:
//        A. It will return True if we deleted the chosen post
//        B. False if the server wasn't able to delete the post
//        C. BOTH! ONLY IF: We successfully deleted from the server, but were unable to delete from Core Data
    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            let post = fetchedResultsController.object(at: indexPath)
//            backendController.deletePost(post: post) { result, error in
//                if let error = error {
//                    self.showAlertMessage(title: "Something wen't wrong", message: "Couldn't delete the guide", actiontitle: "Ok")
//                }
//
//
//                DispatchQueue.main.async {
//                        CoreDataStack.shared.mainContext.delete(post)
//
//                    do {
//                        try CoreDataStack.shared.mainContext.save()
//                    } catch {
//                        CoreDataStack.shared.mainContext.reset()
//                        NSLog("Error saving object: \(error)")
//                    }
//                }
//            }
//
//        }
//    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PostDetailViewSegue" {
            if let detailVC = segue.destination as? GuidesDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.post = fetchedResultsController.object(at: indexPath)
                }
            }
        }


}

extension AllGuidesTableViewController: NSFetchedResultsControllerDelegate {
    //     this is the warning the tableview that the fetch controller is goijng to makechanges in the tableview.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        //        this is the beggnining of the fetchhing
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        //         the endo of the fetchhing.
    }
    //    deletes the entire section or insert entire section
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
extension AllGuidesTableViewController: UISearchBarDelegate, UISearchDisplayDelegate  {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "title contains[c] '\(searchText)'")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Contact")
            fetchRequest.predicate = predicate
        }
        tableView.reloadData()
    }

     }
extension AllGuidesTableViewController {
    func showAlertMessage(title: String, message: String, actiontitle: String) {
        let endAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let endAction = UIAlertAction(title: actiontitle, style: .default) { (action: UIAlertAction ) in
        }
        
        endAlert.addAction(endAction)
        present(endAlert, animated: true, completion: nil)
    }
}

