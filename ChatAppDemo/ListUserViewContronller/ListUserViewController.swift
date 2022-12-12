//
//  ListUserViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit

class ListUserViewController: UIViewController {
    static func instance(_ currentUser: UserRespone) -> ListUserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listUserScreen") as! ListUserViewController
        vc.presenter = ListUserPresenter(view: vc, data: currentUser)
        return vc
    }
     lazy var presenter = ListUserPresenter(with: self)
     lazy var presenterCell = ListCellPresenter()
    @IBOutlet private var userTableView: UITableView!
    @IBOutlet private weak var searchUser: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.getUser()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    private func setupUI() {
        setupUITable()
        setupSearchUser()
    }
    private func setupUITable() {
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.tableFooterView = UIView()
        userTableView.separatorStyle = .none
    }
    private func setupSearchUser() {
        searchUser.layer.cornerRadius = 8
        searchUser.layer.masksToBounds = true
        searchUser.attributedPlaceholder = NSAttributedString(string: "Search User", attributes: [.foregroundColor: UIColor.brown])
        searchUser.addTarget(self, action: #selector(handelTextField(_:)), for: .editingChanged)
        
    }
    @objc func handelTextField(_ textfield: UITextField)  {
        presenter.searchUser(textfield.text!)
    }
}
extension ListUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfUser()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = userTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ListUserTableViewCell
        if let index = presenter.cellForUsers(at: indexPath.row) {
            cell.updateUI(index)
            cell.lbNameUser.attributedText = presenterCell.setHigligh(searchUser.text!, index.name)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = presenter.cellForUsers(at: indexPath.row) else { return}
        guard let currentUser = presenter.currentUserId() else { return }
        let vc = DetailViewViewController.instance(data, currentUser: currentUser)
        vc.title = data.name
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, _, _ in
            self.presenter.deleteUser(indexPath.row) {
                self.userTableView.reloadData()
            }
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}
extension ListUserViewController: ListUserPresenterDelegate {
    func showSearchUser() {
        self.userTableView.reloadData()
    }
    
    func showUsersList() {
        self.userTableView.reloadData()
    }
    func deleteUser(at index: Int) {
//        self.userTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.userTableView.reloadData()
    }
    
}

