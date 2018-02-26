//
//  MasterViewController.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.contact = object
                controller.managedObjectContext = managedObjectContext
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.title = object.fullName
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
        if segue.identifier == "createContact" {
            if let navController = segue.destination as? UINavigationController, let controller = navController.viewControllers.first as? AddContactViewController {
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let context = container.newBackgroundContext()
                controller.managedObjectContext = context
                controller.contact = Contact(context: context)
                controller.setEditing(true, animated: false)
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        if fetchedResultsController.sections!.count > 0 {
            tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            return (fetchedResultsController.sections?.count)!
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.font = UIFont.systemFont(ofSize: 25)
            noDataLabel.text = "No Contacts"
            noDataLabel.textColor = UIColor.darkGray
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.highlightedTextColor = UIColor.black
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
                
            } catch let error as NSError {
                let errorDialog = UIAlertController(title: "Error!", message: "Failed to save! \(error): \(error.userInfo)", preferredStyle: .alert)
                errorDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(errorDialog, animated: true)
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent contact: Contact) {
        cell.textLabel!.text = contact.fullName
    }

    // MARK: - Fetched results controller

   var  fetchedResultsController: NSFetchedResultsController<Contact> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
    
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        let query = navigationItem.searchController?.searchBar.text ?? ""
        if !query.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "lastName CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@", query, query)
        } else {
            fetchRequest.predicate = nil
        }
    
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "lastInitial", cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Contact>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("WillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                print("insert")
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                print("delete")
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert2")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("delete2")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            break
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("DidChangeContent")
        tableView.endUpdates()
    }
    
    // MARK: - Searching
    
    func updateSearchResults(for searchController: UISearchController) {
        _fetchedResultsController = nil
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let error as NSError {
            let errorDialog = UIAlertController(title: "Error!", message: "Failed to load Contacts! \(error): \(error.userInfo)", preferredStyle: .alert)
            errorDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(errorDialog, animated: true)
        }
    }
}


