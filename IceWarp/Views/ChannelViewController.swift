//
//  ChannelViewController.swift
//  IceWarp
//
//  Created by Ajay on 04/12/24.
//

import UIKit

class ChannelViewController: UIViewController {
    
    @IBOutlet weak var channelTableView: UITableView!
    
    private var viewModel = ChannelViewModel()
    
    private var groupedChannels: [(groupFolderName: String, channels: [ChannelList])] = []
    private var expandedSections: [Int: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        fetchChannels()
    }
    
    private func setup() {
        // Setup the table view
        channelTableView.delegate = self
        channelTableView.dataSource = self
        
        let button = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(buttonTapped))
        
        self.navigationItem.leftBarButtonItem = button
    }
    
    // Action method for the button
    @objc func buttonTapped() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        // Add "Sign Out" action
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            print("User signed out")
            self.viewModel.deleteAllData()
            self.setRootViewController()
        }
        
        // Add "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert controller
        alertController.addAction(signOutAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchChannels() {
        Task {
            showLoader()
            do {
                let channels = try await viewModel.fetchChannels()
                reloadTableData(with: channels)
                hideLoader()
            } catch let validationError as InputValidator.ValidationError {
                hideLoader()
                showError(validationError.localizedDescription)
            } catch {
                hideLoader()
                showError("Unexpected error occurred.")
            }
        }
    }
    
    private func reloadTableData(with channels: [ChannelList]) {
        // Group the channels by groupFolderName
        groupedChannels = Dictionary(grouping: channels, by: { $0.groupFolderName ?? "" })
            .map { (key, value) in
                (groupFolderName: key, channels: value)
            }
            .sorted { $0.groupFolderName < $1.groupFolderName }
        self.channelTableView.reloadData()
    }
    
    private func showError(_ message: String) {
        print(message)
    }
    
}

extension ChannelViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedChannels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections[section] == true ? groupedChannels[section].channels.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath)
        let channel = groupedChannels[indexPath.section].channels[indexPath.row]
        cell.textLabel?.text = channel.name
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a header view
        let headerView = UIView()
        headerView.backgroundColor = .systemGray5
        headerView.tag = section // Use the section index as the tag

        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGesture)

        // Add a label for the section title
        let label = UILabel()
        label.text = groupedChannels[section].groupFolderName
        label.frame = CGRect(x: 16, y: 0, width: tableView.bounds.width - 50, height: 40)
        headerView.addSubview(label)

        // Add a dropdown icon (arrow)
        let arrowLabel = UILabel()
        arrowLabel.text = expandedSections[section] == true ? "▲" : "▼" // Up or down arrow
        arrowLabel.frame = CGRect(x: tableView.bounds.width - 40, y: 0, width: 20, height: 40)
        arrowLabel.textAlignment = .center
        headerView.addSubview(arrowLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // MARK: - Header Tap Handling

    @objc private func handleHeaderTap(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }

        // Toggle the expanded state
        expandedSections[section] = !(expandedSections[section] ?? false)

        // Reload the section
        channelTableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }}

