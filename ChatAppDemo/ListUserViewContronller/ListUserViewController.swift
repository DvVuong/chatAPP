//
//  ListUserViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit

class ListUserViewController: UIViewController {
    static func instance(_ currentUser: User) -> ListUserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listUserScreen") as! ListUserViewController
        vc.presenter = ListUserPresenter(with: vc, data: currentUser)
        return vc
    }
    
    private var presenter: ListUserPresenter!
    lazy var presenterCell = ListCellPresenter()
    @IBOutlet private weak var messageTable: UITableView!
    @IBOutlet private weak var searchUser: UITextField!
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var btSetting: UIButton!
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var imgState: UIImageView!
    @IBOutlet private weak var listUser: UICollectionView!
    @IBOutlet private weak var lbNewMessageNotification: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupListUserCollectionTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        setupMessagetable()
        setupSearchUser()
        setupImageForCurrentUser()
        setupBtSetting()
        setupLbNameUser()
        self.presenter.fetchUser {
            self.presenter.fetchMessageForUser {
                self.messageTable.reloadData()
            }
            self.listUser.reloadData()
        }
        setuplbNewMessageNotification()
    
       
    }
    private func setupMessagetable() {
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.separatorStyle = .none
    }
    
    private func setupListUserCollectionTable() {
        listUser.delegate = self
        listUser.dataSource = self
        
    }
    
    private func setupSearchUser() {
        searchUser.layer.cornerRadius = 8
        searchUser.layer.masksToBounds = true
        searchUser.attributedPlaceholder = NSAttributedString(string: "Search User", attributes: [.foregroundColor: UIColor.brown])
        searchUser.addTarget(self, action: #selector(handelTextField(_:)), for: .editingChanged)
        
    }
    private func setupImageForCurrentUser() {
        guard let currentuser = presenter.getcurrentUser() else { return }
        avatar.layer.cornerRadius = avatar.frame.height / 2
        avatar.layer.masksToBounds = true
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor.black.cgColor
        avatar.contentMode = .scaleToFill
        ImageService.share.fetchImage(with: currentuser.picture) { [weak self] image in
            DispatchQueue.main.async {
                self?.avatar.image = image
            }
        }
    }
    
    private func setupLbNameUser() {
        guard let currentuser = presenter.getcurrentUser() else { return }
        lbNameUser.text = currentuser.name
    }
    
    private func setuplbNewMessageNotification() {
        lbNewMessageNotification.isHidden = true
    }
    
    private func setupBtSetting() {
        btSetting.setTitle("", for: .normal)
        btSetting.addTarget(self, action: #selector(didTapSetting(_:)), for: .touchUpInside)
    }
   
    @objc func handelTextField(_ textfield: UITextField)  {
        presenter.searchUser(textfield.text!)
    }
    
    @objc func didTapSetting(_ sender: Any) {
       guard let user = presenter.getcurrentUser() else {return}
        let vc = SettingViewController.instance(user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: TableView
extension ListUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // show Label Message Notification
        if presenter.getNumberOfMessage() == 0 {
            lbNewMessageNotification.isHidden = false
        } else {
            lbNewMessageNotification.isHidden = true
        }
        
        return presenter.getNumberOfMessage()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = messageTable.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ListUserTableViewCell
        let currentUser = presenter.getcurrentUser()
        let reciverUser = presenter.getUsers(indexPath.row)
        let message = presenter.cellForMessage(indexPath.item)
        cell.updateUI(currentUser, message: message, reciverUser: reciverUser )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = presenter.getcurrentUser() else { return }
        guard let reciverUser = presenter.getUsers(indexPath.row) else { return }
        guard let message = presenter.cellForMessage(indexPath.item) else {return}
        
        if message.sendId == currentUser.id || message.receiverID == reciverUser.id {
            let user = User(name: message.receivername, id: message.receiverID, picture: message.avatarReciverUser, email: "", password: "", isActive: false)
            let vc = DetailViewViewController.instance(user, currentUser: currentUser)
            navigationController?.pushViewController(vc, animated: true)
            return
            
        } else {
            let user = User(name: message.nameSender, id: message.sendId, picture: message.avataSender, email: "", password: "", isActive: false)
            let vc = DetailViewViewController.instance(user, currentUser: currentUser)
            navigationController?.pushViewController(vc, animated: true)
        }

        if message.receiverID == currentUser.id {
            //presenter.setState(currentUser, reciverUser: reciverUser)
        }
               
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, _, _ in
            self.presenter.deleteUser(indexPath.row) { [weak self] in
                self?.messageTable.reloadData()
            }
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}
// MARK: CollectionView

extension ListUserViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getNumberOfUser()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = listUser.dequeueReusableCell(withReuseIdentifier: "listUserCell", for: indexPath) as! ListUserCollectionViewCell
        cell.updateUI(presenter.getCellForUsers(at: indexPath.item))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = presenter.getCellForUsers(at: indexPath.item) else {return}
        guard let currentUser = presenter.getcurrentUser() else {return}
        let vc = DetailViewViewController.instance(user, currentUser: currentUser)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
}





extension ListUserViewController: ListUserPresenterDelegate {
    func showSearchUser() {
        self.messageTable.reloadData()
        self.listUser.reloadData()
    }
    func deleteUser(at index: Int) { 
        self.messageTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.messageTable.reloadData()
    }
    func showStateMassage() {
        self.messageTable.reloadData()
        self.listUser.reloadData()
    }
    
}


