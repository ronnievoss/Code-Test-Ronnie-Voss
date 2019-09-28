//
//  LabelViewController.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/12/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import UIKit
import CoreData

final class LabelViewController: UITableViewController {
    
    var labels = ["Home", "Work", "Mobile", "Other"]
    
    var selectedLabel: String? {
        didSet {
            if let label = selectedLabel {
                selectedLabelIndex = labels.firstIndex(of: label)
            }
        }
    }
    var selectedLabelIndex: Int?
    var selectedIndex: Int?
    var tag: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedLabelIndex = selectedIndex
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = labels[(indexPath).row]
        
        if (indexPath).row == selectedLabelIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let index = selectedLabelIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: (indexPath).section))
            cell?.accessoryType = .none
        }
        
        selectedLabel = labels[indexPath.row]
        selectedLabelIndex = indexPath.row
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        performSegue(withIdentifier: "setLabel", sender: nil)
        
    }
    
    // MARK: - Private
    
    @IBAction private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
}
