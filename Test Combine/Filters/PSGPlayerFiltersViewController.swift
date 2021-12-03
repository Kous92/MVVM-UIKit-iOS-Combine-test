//
//  PSGPlayerFiltersViewController.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 21/11/2021.
//

import UIKit
import Combine

final class PSGPlayerFiltersViewController: UIViewController {

    let viewModel = PSGPlayersFiltersViewModel()
    private var actualSelectedIndex = 0
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    
    @IBAction func backToMainView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PSGPlayerFiltersViewController {
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension PSGPlayerFiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(viewModel.filters.count)
        return viewModel.filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = viewModel.filters[indexPath.row].rawValue
        
        // Useless to reuse the cells since there are few categories
        let cell = UITableViewCell(style: .default, reuseIdentifier: "filterCell")
        cell.textLabel?.text = filter
        cell.textLabel?.textColor = .white
        cell.tintColor = .systemGreen
        cell.backgroundColor = .clear
        
        if viewModel.actualFilter.rawValue == filter {
            actualSelectedIndex = indexPath.row
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
}

extension PSGPlayerFiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row.
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        // Did the user tap on an already selected cell ? If it's the case, do nothing
        let selected = indexPath.row
        if selected == actualSelectedIndex {
            return
        }
        
        // Removal of the checkmark from the previous selected cell
        if let previousCell = tableView.cellForRow(at: IndexPath(row: actualSelectedIndex, section: indexPath.section)) {
            previousCell.accessoryType = .none
        }
        
        // Marking the newly selected cell with a checkmark
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        // Keeping in memory the selected category
        actualSelectedIndex = selected
        viewModel.actualFilter = viewModel.filters[indexPath.row]
        viewModel.selectedFilter.send(viewModel.filters[indexPath.row])
    }
}
