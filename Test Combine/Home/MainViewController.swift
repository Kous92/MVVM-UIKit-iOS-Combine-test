//
//  ViewController.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 01/11/2021.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var appliedFilterLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultLabel: UILabel!
    
    @Published private(set) var searchQuery = ""
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = PSGPlayersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setSearchBar()
        setNoResultLabel()
        setBindings()
    }
    
    @IBAction func filterButton(_ sender: Any) {
        guard let filterViewController = storyboard?.instantiateViewController(withIdentifier: "filtersViewController") as? PSGPlayerFiltersViewController else {
            fatalError("The ViewController is not detected in the Storyboard.")
        }
        
        func setFilterVCBinding() {
            // Keeping in memory the selected filter
            filterViewController.viewModel.setFilter(savedFilter: viewModel.activeFilter)
            
            // Here, we replace the delegation with a binding from a PassthroughSubject
            filterViewController.viewModel.selectedFilter
                .handleEvents(receiveOutput: { [weak self] filter in
                    self?.appliedFilterLabel.text = filter.rawValue
                    self?.viewModel.activeFilter = filter
                }).sink { _ in }
                .store(in: &subscriptions)
        }
        
        setFilterVCBinding()
        filterViewController.modalPresentationStyle = .fullScreen
        self.present(filterViewController, animated: true, completion: nil)
    }
}

// MARK: - Functions for views management and bindings with view model
extension MainViewController {
    private func setTableView() {
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setSearchBar() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.backgroundImage = UIImage() // Remove default background
        searchBar.showsCancelButton = false
        searchBar.delegate = self
    }
    
    private func setNoResultLabel() {
        noResultLabel.isHidden = false
        noResultLabel.text = ""
    }
    
    private func displayNoResult() {
        tableView.isHidden = true
        noResultLabel.isHidden = false
        noResultLabel.text = "No result for \"\(searchQuery)\". Please try again with an other search."
    }
    
    private func updateTableView() {
        noResultLabel.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func setBindings() {
        func setSearchBinding() {
            $searchQuery
                .receive(on: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] value in
                    print(value)
                    self?.viewModel.searchQuery = value
                }.store(in: &subscriptions)
        }
        
        func setUpdateBinding() {
            viewModel.updateResult.receive(on: RunLoop.main).sink { completion in
                switch completion {
                case .finished:
                    print("OK: done")
                case .failure(let error):
                    print("Received error: \(error.rawValue)")
                }
            } receiveValue: { [weak self] updated in
                self?.loadingSpinner.stopAnimating()
                self?.loadingSpinner.isHidden = true
                
                if updated {
                    self?.updateTableView()
                } else {
                    self?.displayNoResult()
                }
            }.store(in: &subscriptions)
        }
        
        func setActiveFilterBinding() {
            viewModel.$activeFilter
                .receive(on: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] value in
                    print(value)
                    self?.viewModel.activeFilter = value
                }.store(in: &subscriptions)
        }
        
        // The interest to use nested functions is to be able to respect the 1st principle of SOLID: SRP (Single Responsibility Principle)
        setSearchBinding()
        setUpdateBinding()
        setActiveFilterBinding()
    }
}

// MARK: - TableView Data Source functions
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPlayersViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as? PSGPlayerTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.filteredPlayersViewModels[indexPath.row])
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailsViewController = storyboard?.instantiateViewController(withIdentifier: "detailsViewController") as? PSGPlayerDetailsViewController else {
            fatalError("The ViewController is not detected in the Storyboard.")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        detailsViewController.configure(with: PSGPlayerDetailsViewModel(player: viewModel.filteredPlayersViewModels[indexPath.row].player))
        detailsViewController.modalPresentationStyle = .fullScreen
        present(detailsViewController, animated: true, completion: nil)
    }
}

// MARK: - Fonctions de la barre de recherche
extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchQuery = ""
        self.searchBar.text = ""
        self.appliedFilterLabel.text = "No filter"
        searchBar.resignFirstResponder() // Hide the keyboard and stop text editing
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Hide the keyboard and stop text editing
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
}
