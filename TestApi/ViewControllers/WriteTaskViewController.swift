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
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
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
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsUpdateConstraints()
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
    
    @objc
    func prioritySelected(sender: UIButton) {
        print(sender.titleLabel?.text)
    }
    
    @objc
    func notificationButtonTapped() {
        print("notificationButtonTapped")
    }
    
}
