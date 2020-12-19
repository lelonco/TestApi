//
//  WriteTaskViewController.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation
import UIKit

class WriteTaskViewController: UIViewController {
    var didConstraintsSetup = false
    var task: Task? = nil
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isScrollEnabled = true
        scroll.alwaysBounceHorizontal = false
        
        return scroll
    }()
    
    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 30)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.spacing = 15
        return stack
    }()
    
    let titleSectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Title"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    
    let prioritySectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Priority"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    
    let desctiptionSectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Description"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    
    let notificationSectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Notification"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    let titleTextView: UITextView = {
        let textView = UITextView()
//        textView.layer.borderWidth = 1
//        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 15
        textView.autoSetDimension(.height, toSize: 40,relation: .greaterThanOrEqual)
        textView.isScrollEnabled = false
        
        return textView
    }()
    
    let priorityButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.alignment = .fill
        
        return stack
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.autoSetDimension(.height, toSize: 40,relation: .greaterThanOrEqual)
        textView.isScrollEnabled = false
//        textView.layer.borderWidth = 1
//        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 15
        return textView
    }()
    
    let notificationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("10 min before", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let titleRow : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .fill

        return stack
    }()
    let priorityRow : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill

        return stack
    }()
    let descriptionRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        
        return stack
    }()
    let notifyRow = UIView()

    let databaseStorage = DatabaseManager.shared
    
    init(with task: Task? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.task = task
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        TaskPriority.allCases.forEach({
            let button = UIButton()
            button.setTitle($0.rawValue, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(prioritySelected), for: .touchUpInside)
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            self.priorityButtonsStack.addArrangedSubview(button)
        })
        [titleSectionLabel, titleTextView].forEach({ self.titleRow.addArrangedSubview($0) })
        [prioritySectionLabel,priorityButtonsStack].forEach({ self.priorityRow.addArrangedSubview($0) })
        [desctiptionSectionLabel,descriptionTextView].forEach({ self.descriptionRow.addArrangedSubview($0) })
        [notificationSectionLabel,notificationButton].forEach({ self.notifyRow.addSubview($0) })

        [titleRow,priorityRow,descriptionRow,notifyRow].forEach({ self.contentStack.addArrangedSubview($0) })
        self.scrollView.keyboardDismissMode = .interactive
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        if let task = task {
            titleTextView.text = task.title
            descriptionTextView.text = task.taskDescription
//            notificationButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsUpdateConstraints()
        updateBarButtons()
    }
    
    override func updateViewConstraints() {
        guard !didConstraintsSetup else {
            super.updateViewConstraints()
            return
        }
        
        scrollView.autoPinEdgesToSuperviewEdges()
        
        contentStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),excludingEdge: .trailing)
        contentStack.autoSetDimension(.width, toSize: (UIApplication.shared.windows.first?.frame.width)!)
        
        [notificationSectionLabel,notificationButton].forEach { (view) in
            view.autoPinEdge(toSuperviewEdge: .top)
            view.autoPinEdge(toSuperviewEdge: .bottom)
        }
        notificationSectionLabel.autoPinEdge(toSuperviewEdge: .leading)
        notificationSectionLabel.autoPinEdge(.trailing, to: .leading, of: notificationButton,withOffset: -20, relation: .greaterThanOrEqual)
        notificationButton.autoPinEdge(toSuperviewEdge: .trailing)
        notificationButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        didConstraintsSetup = true
        super.updateViewConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        [titleTextView,descriptionTextView].forEach { (view) in
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 6)
            view.layer.shadowOpacity = 0.07
            view.layer.shadowRadius = 4
//            view.layer.shadowPath =  UIBezierPath(roundedRect: view.bounds, cornerRadius: 15).cgPath
            view.layer.masksToBounds = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [titleTextView,descriptionTextView].forEach { (view) in
//            view.layer.shadowColor = UIColor.black.cgColor
//            view.layer.shadowOffset = CGSize(width: 0, height: 6)
//            view.layer.shadowOpacity = 0.07
//            view.layer.shadowRadius = 4
            view.layer.shadowPath =  UIBezierPath(roundedRect: view.bounds, cornerRadius: 15).cgPath
//            view.layer.masksToBounds = false
        }
       
    }
    
    func updateBarButtons() {
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.setLeftBarButton(addButton, animated: true)
        
    }
    
    @objc
    func prioritySelected(sender: UIButton) {
        print(sender.titleLabel?.text ?? "")
    }
    
    @objc
    func notificationButtonTapped() {
        print("notificationButtonTapped")
    }
    
    
    @objc
    func backButtonTapped() {
        
        if !hasUnsavedChanges() {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.databaseStorage.objects(Task.self).forEach({
                                                            print($0.description)
            
        })
        let alertController = UIAlertController(title: "Attention!", message: "You have unsave changes", preferredStyle: .actionSheet)
        let saveAndClose = UIAlertAction(title: "Save", style: .default) { (_) in
            do {
                try self.databaseStorage.write {
                    if let task = self.task {
                        task.taskDescription = self.descriptionTextView.text
                        task.title = self.titleTextView.text
                        task.wasEdited = true
                    } else {
                        self.databaseStorage.add(Task(id: nil, title: self.titleTextView.text, dueBy: Date().millisecondsSince1970, priority: .high, taskDescription: self.descriptionTextView.text))

                    }
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }

            self.navigationController?.popViewController(animated: true)
        }
        let discard = UIAlertAction(title: "Discard", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        [saveAndClose,discard,cancel].forEach({ alertController.addAction($0) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func hasUnsavedChanges() -> Bool {
        if let task = task {
            return self.titleTextView.text != task.title || self.descriptionTextView.text != task.taskDescription ?? ""
        }
        return !self.titleTextView.text.isEmpty || !self.descriptionTextView.text.isEmpty
    }
    
}
