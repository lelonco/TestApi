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

class TaskListController: UIViewController  {
    let reuseIdentifier = "TaskListControllerCellReuse"
    var didConstraintsSetup = false
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let refreshControl = UIRefreshControl()

    var networkManager = NetworkManager.shared
    let databaseStorage = DatabaseManager.shared
    var dataSource:  Results<Task>!
    var notificationToken: NotificationToken?
    
//        Array.init(repeating: Task(id: 2, title: "Title", dueBy: 1231312, priority: .high, taskDescription: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello"), count: 200)
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
//        databaseStorage.objects(Task.self).forEach { (task) in
//            try! self.databaseStorage.write {
//                self.databaseStorage.delete(task)
//            }
//        }
        let request = RequestBuilder.getTasksRequest(page: 0, sortedBy: "title", sortingType: .asc)
        //        networkManager.makeRequest(request) { (response, object) in
        //            print(try! JSONSerialization.jsonObject(with: object as! Data, options: []))
        //
        //
        //        } failure: { (error) in
        //            assertionFailure(error.localizedDescription)
        //        }
        updateBarButtons()
        
        self.view.setNeedsUpdateConstraints()
        dataSource = databaseStorage.objects(Task.self)
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
    
    deinit {
        notificationToken?.invalidate()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.viewControllers.removeAll(where: { $0.self == ViewController().self })
    }
    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard !didConstraintsSetup else { return }
        tableView.autoPinEdgesToSuperviewMargins()
        
        didConstraintsSetup = true
    }
    
    func updateBarButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTaskTapped))
        self.navigationItem.setLeftBarButton(addButton, animated: true)
        
    }
    
    @objc
    func addNewTaskTapped() {
        
//        for _ in 0..<1 {
            do {
                try self.databaseStorage.write {
                    let task = Task(id: nil,
                                    title: Lorem.title,
                                    dueBy: Date().millisecondsSince1970,
                                    priority: TaskPriority.allCases.randomElement(),
                                    taskDescription: Lorem.paragraphs(Int.random(in: 0...10)))
                    self.databaseStorage.add(task)
                    print(task.description)
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
//        }
        
        //        let vc = WriteTaskViewController()
        //
        //        self.navigationController?.pushViewController(vc, animated: true)
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
}

extension TaskListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
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
