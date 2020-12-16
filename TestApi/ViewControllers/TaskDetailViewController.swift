//
//  TaskDetailViewController.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
    
    var task: Task {
        didSet {
            self.updateUIComponets()
        }
    }
    
    var isConstarintsSetuped = false
    
    let scrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceHorizontal = false
        scroll.isScrollEnabled = true
        return scroll
    }()
    
    let contentView = UIView()
    let headerContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        return view
    }()
    let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    let dueByLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    let prioritySectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Priority"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    let priorityImageView = UIImageView(image: UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysTemplate))
    
    let priorityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    let notificationSectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Notification"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    let notifyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    let priorityRow: UIView = {
        let view = UIView()
        return view
    }()
    let descriptionRow = UIView()
    let notifyRow = UIView()
    init(with task:Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.title = task.title
        self.view.backgroundColor = .white
        [prioritySectionLabel,priorityLabel,priorityImageView].forEach({ self.priorityRow.addSubview($0) })
        [desctiptionSectionLabel,descriptionLabel].forEach({ self.descriptionRow.addSubview($0) })
        [notificationSectionLabel,notifyLabel].forEach({ self.notifyRow.addSubview($0) })
        headerContainer.addSubview(headerStack)
        [titleLabel,dueByLabel].forEach({ self.headerStack.addArrangedSubview($0) })
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.distribution = .fill
        contentStack.alignment = .fill
        contentStack.spacing = 15
        
        [headerContainer,priorityRow,descriptionRow,notifyRow].forEach({ contentStack.addArrangedSubview($0)})
        contentView.addSubview(contentStack)
//        contentView.backgroundColor = .blue
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15) )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUIComponets()
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1) {
            self.headerContainer.layer.shadowColor = UIColor.black.cgColor
            self.headerContainer.layer.shadowOffset = CGSize(width: 0, height: 6)
            self.headerContainer.layer.shadowOpacity = 0.05
            self.headerContainer.layer.shadowRadius = 5
            self.headerContainer.layer.shadowPath =  UIBezierPath(roundedRect: self.headerContainer.bounds, cornerRadius: 15).cgPath

            self.headerContainer.layer.masksToBounds = false
        }

    }
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        guard !isConstarintsSetuped else { return }
        
        scrollView.autoPinEdgesToSuperviewEdges()
        
        contentView.autoPinEdge(toSuperviewEdge: .top)
        contentView.autoPinEdge(toSuperviewEdge: .leading)
        contentView.autoPinEdge(toSuperviewEdge: .bottom)
        contentView.autoSetDimension(.width, toSize: (UIApplication.shared.windows.first?.frame.width)!)
 
        headerStack.autoPinEdgesToSuperviewEdges()
    
        prioritySectionLabel.autoPinEdge(toSuperviewEdge: .leading)
        prioritySectionLabel.autoVCenterInSuperview()
        
        priorityImageView.autoVCenterInSuperview()
        priorityImageView.autoPinEdge(.leading, to: .trailing, of: prioritySectionLabel, withOffset: 40, relation: .greaterThanOrEqual)
        
        priorityLabel.autoVCenterInSuperview()
        priorityLabel.autoPinEdge(.leading, to: .trailing, of: priorityImageView, withOffset: 10)
        priorityLabel.autoPinEdge(toSuperviewEdge: .trailing)
        priorityLabel.autoPinEdge(toSuperviewEdge: .bottom,withInset: 15)

        
        desctiptionSectionLabel.autoPinEdge(toSuperviewEdge: .leading)
        desctiptionSectionLabel.autoPinEdge(toSuperviewEdge: .top)

        descriptionLabel.autoPinEdge(.top, to: .bottom, of: desctiptionSectionLabel, withOffset: 10)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 15)

        notificationSectionLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 15)
        notificationSectionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 15)
        
        notifyLabel.autoVCenterInSuperview()
        notifyLabel.autoPinEdge(.leading, to: .trailing, of: prioritySectionLabel, withOffset: 40, relation: .greaterThanOrEqual)
        notifyLabel.autoPinEdge(toSuperviewEdge: .trailing)

        isConstarintsSetuped = true
    }
    
    func updateUIComponets() {
        
        titleLabel.text = task.title
        dueByLabel.text = task.dueBy?.description
        priorityLabel.text = task.priority?.rawValue
        descriptionLabel.text = task.taskDescription
        notifyLabel.text = task.dueBy?.description
    }
}
