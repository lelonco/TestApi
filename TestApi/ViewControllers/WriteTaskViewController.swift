//
//  WriteTaskViewController.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation
import UIKit
import RealmSwift

class WriteTaskViewController: BaseViewController {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    var didConstraintsSetup = false
    var task: Task? = nil
    var selectedPriority: String? = nil {
        didSet {
            let selectedItem = priorityButtonsStack.arrangedSubviews.first { (view) -> Bool in
                guard let button = view as? UIButton else { return false }
                return button.titleLabel?.text == selectedPriority
            } as? UIButton
            prevSelection?.isSelected = false
            selectedItem?.isSelected = true
            prevSelection = selectedItem
        }
    }
    var prevSelection: UIButton? = nil
    let dateFormater: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "EEEE d MMM , yyyy"
        
        return formater
    }()
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
    
    let titleSectionLabel = SectionLabel(with:"Title")
    let prioritySectionLabel = SectionLabel(with:"Priority")
    let desctiptionSectionLabel = SectionLabel(with:"Description")

    
    let notificationSectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Notification"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    let titleTextView = ShadowTextView()
    
    let priorityButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.alignment = .fill
        
        return stack
    }()
    
    let descriptionTextView = ShadowTextView()
    
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
    
    let dateRow: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        
        return stack
    }()
    
    let dateSectionTitle = SectionLabel(with:"Due by:")

    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 15, weight: .medium)
        textField.textColor = .darkGray
        textField.placeholder = "Date..."
        textField.textAlignment = .right
        return textField
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.minimumDate = Date()
        picker.datePickerMode = .dateAndTime
        picker.timeZone = NSTimeZone.local
        picker.tintColor = .darkGray

        return picker
    }()
    
    let pickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.tintColor = .darkGray

        return toolbar
    }()

    
    let notifyRow = UIView()

    let databaseStorage = DatabaseManager.shared
    
    init(with task: Task? = nil) {
        super.init()
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
            button.setTitleColor(.lightGray, for: .normal)
            button.addTarget(self, action: #selector(prioritySelected), for: .touchUpInside)
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            button.setTitleColor(.black, for: .selected)
            self.priorityButtonsStack.addArrangedSubview(button)
        })
        [titleSectionLabel, titleTextView].forEach({ self.titleRow.addArrangedSubview($0) })
        [prioritySectionLabel,priorityButtonsStack].forEach({ self.priorityRow.addArrangedSubview($0) })
        [desctiptionSectionLabel,descriptionTextView].forEach({ self.descriptionRow.addArrangedSubview($0) })
        [notificationSectionLabel,notificationButton].forEach({ self.notifyRow.addSubview($0) })
        [dateSectionTitle,dateTextField].forEach({ self.dateRow.addArrangedSubview($0) })
        [titleRow,priorityRow,descriptionRow,dateRow,notifyRow].forEach({ self.contentStack.addArrangedSubview($0) })
        self.scrollView.keyboardDismissMode = .interactive
        self.view.addSubview(scrollView)
        self.view.addSubview(datePicker)
        self.view.addSubview(pickerToolbar)
        scrollView.addSubview(contentStack)
        
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = pickerToolbar
        if let task = task {
            titleTextView.text = task.title
            descriptionTextView.text = task.taskDescription
            dateTextField.text = dateFormater.string(from: Date(timeIntervalSince1970: TimeInterval(task.dueBy)))
            selectedPriority = task.priorityString
        }

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDoneTapped))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(datePickerCancelTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        pickerToolbar.items = [doneButton,flexSpace,cancelButton]
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
        
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) , excludingEdge: .bottom)

        self.autoPinView(toBottomOfViewControllerOrKeyboard: scrollView, withOffset: -20)
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
    
    func updateBarButtons() {
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.setLeftBarButton(addButton, animated: true)
    }
    
    @objc
    func prioritySelected(sender: UIButton) {
        self.selectedPriority = sender.currentTitle

    }
    
    @objc
    func notificationButtonTapped(sender: UIButton) {

    }
    
    
    @objc
    func backButtonTapped() {
        
        if !hasUnsavedChanges() {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.databaseStorage.objects(Task.self).forEach({print($0.description)})
        let alertController = UIAlertController(title: "Attention!", message: "You have unsave changes", preferredStyle: .actionSheet)
        let saveAndClose = UIAlertAction(title: "Save", style: .default) { (_) in
            self.saveTask()
            self.navigationController?.popViewController(animated: true)
        }
        let discard = UIAlertAction(title: "Discard", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        [saveAndClose,discard,cancel].forEach({ alertController.addAction($0) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveTask() {
        do {
            try self.databaseStorage.write {
                if let task = self.task {
                    task.taskDescription = self.descriptionTextView.text
                    task.title = self.titleTextView.text
                    task.dueBy = Int64((self.dateFormater.date(from: self.dateTextField.text!))?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
                    task.wasEdited = true
                    self.databaseStorage.add(task, update: .all)
                } else {
                    let dateFromString = self.dateFormater.date(from: self.dateTextField.text ?? "") ?? Date()
                    self.task = Task(id: nil, title: self.titleTextView.text, dueBy: Int64(dateFromString.timeIntervalSince1970), priority: .high, taskDescription: self.descriptionTextView.text)
                    self.databaseStorage.add(self.task!)

                }
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
        storeNotification()
    }
    
    func hasUnsavedChanges() -> Bool {
        if let task = task {
            return self.titleTextView.text != task.title ||
            self.descriptionTextView.text != task.taskDescription ?? "" ||
                self.dateTextField.text! != dateFormater.string(from: Date(timeIntervalSince1970: TimeInterval(task.dueBy)))
        }
        return !self.titleTextView.text.isEmpty || !self.descriptionTextView.text.isEmpty || !self.dateTextField.text!.isEmpty
    }
    
    @objc
    func datePickerDoneTapped() {

        dateTextField.text = dateFormater.string(from: datePicker.date)
        dateTextField.resignFirstResponder()

    }
    
    @objc
    func datePickerCancelTapped() {
        dateTextField.resignFirstResponder()
    }

    func storeNotification() {
        var dateComp = DateComponents()
        dateComp.calendar = Calendar.current
        dateComp.minute = 10
        guard let task = self.task,
              let notificationDate = Calendar.current.date(byAdding: dateComp,
                                                           to: Date(timeIntervalSince1970: TimeInterval(task.dueBy))) else { return }
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [task.taskUUID])
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [task.taskUUID])
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "You have a task that expires soon"
        notificationContent.body = self.task?.title ?? ""
        let notificationCalendar = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from:notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationCalendar, repeats: false)
        let request = UNNotificationRequest(identifier: self.task!.taskUUID,
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}
