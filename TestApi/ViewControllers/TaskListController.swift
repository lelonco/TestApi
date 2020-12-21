//
//  TaskListController.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation
import UIKit
import LoremSwiftum
import RealmSwift

class TaskListController: BaseViewController  {
    let reuseIdentifier = "TaskListControllerCellReuse"
    var didConstraintsSetup = false
    let userNotificationCenter = UNUserNotificationCenter.current()

    
    let tableView = UITableView(frame: .zero, style: .plain)
    let refreshControl = UIRefreshControl()

    var taskManager = TaskManager.shared
    var networkManager = NetworkManager.shared
    let databaseStorage = DatabaseManager.shared
    var dataSource:  Results<Task>!
    var notificationToken: NotificationToken?
    var isAsc = true
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        [tableView].forEach({ self.view.addSubview($0) })
        tableView.register(TaskListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        
        self.title = "Task list"
        tableView.allowsSelection = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNotificationCenter.delegate = self
        refreshControl.addTarget(self, action: #selector(fetchRemotlyTasks), for: .valueChanged)

        updateBarButtons()
        
        self.view.setNeedsUpdateConstraints()
        dataSource = databaseStorage.objects(Task.self).sorted(byKeyPath: "title", ascending: isAsc)
        notificationToken = dataSource.observe { [weak self] (changes) in
            guard let self = self else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self.tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestNotificationAuthorization()
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    

    deinit {
        notificationToken?.invalidate()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard !didConstraintsSetup else { return }
        tableView.autoPinEdgesToSuperviewMargins()
        
        didConstraintsSetup = true
    }
    
    func updateBarButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTaskTapped))
        let sortButton =  UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortTapped))
        self.navigationItem.setLeftBarButton(addButton, animated: true)
        self.navigationItem.setRightBarButton(sortButton, animated: true)
    }
    
    @objc
    func sortTapped() {
        isAsc.toggle()
        dataSource = dataSource.sorted(byKeyPath: "title", ascending: isAsc)
        self.tableView.reloadData()
    }
    
    @objc
    func addNewTaskTapped() {

//        do {
//            try self.databaseStorage.write {
//                let task = Task(id: nil,
//                                title: Lorem.title,
//                                dueBy: Int64(Date().timeIntervalSince1970),
//                                priority: TaskPriority.allCases.randomElement(),
//                                taskDescription: Lorem.paragraphs(Int.random(in: 0...10)))
//                self.databaseStorage.add(task)
//                print(task.description)
//            }
//        } catch {
//            assertionFailure(error.localizedDescription)
//        }
        
                let vc = WriteTaskViewController()
        
                self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc
    func fetchRemotlyTasks(sender: UIRefreshControl) {
        guard sender.isRefreshing else { return }
        self.taskManager.fetchRemoteCaller(sortedBy: "title", sortingType: .asc) {
            self.refreshControl.endRefreshing()
        }
    }
}


extension TaskListController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TaskListTableViewCell else { return }
        cell.task = dataSource[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TaskDetailViewController(with: dataSource[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension TaskListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Edit") { (_, _, editAction) in
            let vc = WriteTaskViewController(with: self.dataSource[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
            editAction(true)
        }
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, editAction) in
            let task = self.dataSource[indexPath.row]
            try! self.databaseStorage.write {
                if let taskId = task.id.value {
                    self.databaseStorage.add(DeleteRemotelyJobRecord(taskId:taskId))
                }
                self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [task.taskUUID])
                self.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [task.taskUUID])
                self.databaseStorage.delete(task)
            }
            editAction(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TaskListTableViewCell else {
            assertionFailure("Cant cast cell")
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension TaskListController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}
