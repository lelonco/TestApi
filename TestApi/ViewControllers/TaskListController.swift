//
//  TaskListController.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation
import UIKit

class TaskListController: UIViewController  {
    let reuseIdentifier = "TaskListControllerCellReuse"
    var isConstartintsSetuped = false
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let refreshControl = UIRefreshControl()

    var networkManager = NetworkManager.shared
    
    var dataSource: [Task] = Array.init(repeating: Task(id: 2, title: "Title", dueBy: 1231312, priority: .high, taskDescription: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello"), count: 200)
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
        let request = RequestBuilder.getTasksRequest(page: 0, sortedBy: "title", sortingType: .asc)
        networkManager.makeRequest(request) { (response, object) in
            print(try! JSONSerialization.jsonObject(with: object as! Data, options: []))
            
            
        } failure: { (error) in
            assertionFailure(error.localizedDescription)
        }

        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.viewControllers.removeAll(where: { $0.self == ViewController().self })
    }
    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard !isConstartintsSetuped else { return }
        tableView.autoPinEdgesToSuperviewMargins()
        
        isConstartintsSetuped = true
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
