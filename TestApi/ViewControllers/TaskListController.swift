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

    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        [tableView].forEach({ self.view.addSubview($0) })
        tableView.register(TaskListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

extension TaskListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TaskListTableViewCell else {
            assertionFailure("Cant cast cell")
            return UITableViewCell()
        }
        return cell
    }
    
    
    
    
}
