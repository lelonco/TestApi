//
//  TaskListTableViewCell.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {
    var task: Task? = nil {
        didSet {
            self.updateUIComponets()
        }
    }
    var isConstarintsUpdated = false
    private let taskTitleLabel = UILabel()
    private let dueTolabel = UILabel()
    private let priorityImageView = UIImageView()
    private let priporityLabel = UILabel()
    private let enterToPreviewImage = UIImageView(image: UIImage(systemName: "chevron.forward")?.withRenderingMode(.alwaysTemplate))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [taskTitleLabel,dueTolabel,priorityImageView,enterToPreviewImage,priporityLabel].forEach({ self.contentView.addSubview($0) })
        taskTitleLabel.text = "Title"
        dueTolabel.text = "Due to: 01/12/13"
        priporityLabel.text = "High"
        priorityImageView.image = UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysTemplate)
        priorityImageView.tintColor = .black
        enterToPreviewImage.tintColor = .black
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        
        taskTitleLabel.autoPinEdge(toSuperviewMargin: .top)
        taskTitleLabel.autoPinEdge(toSuperviewMargin: .leading)
        taskTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        taskTitleLabel.autoPinEdge(.trailing, to: .leading, of: enterToPreviewImage,withOffset: -15, relation: .lessThanOrEqual)

        dueTolabel.autoPinEdge(.top, to: .bottom, of: taskTitleLabel,withOffset: 5)
        dueTolabel.autoPinEdge(toSuperviewMargin: .leading)
        
        priorityImageView.autoPinEdge(.leading, to: .trailing, of: dueTolabel,withOffset: 10)
        priorityImageView.autoAlignAxis(.horizontal, toSameAxisOf: dueTolabel)
        
        priporityLabel.autoPinEdge(.leading, to: .trailing, of: priorityImageView,withOffset: 5)
        priporityLabel.autoAlignAxis(.horizontal, toSameAxisOf: priorityImageView)

        enterToPreviewImage.autoPinEdge(toSuperviewMargin: .trailing)
        enterToPreviewImage.autoVCenterInSuperview()

    }
    
    func updateUIComponets() {
        guard let task = task else { return }
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "EEEE, d MMM , yyyy"
        taskTitleLabel.text = task.title
        dueTolabel.text = dateFormater.string(from: Date(timeIntervalSince1970: TimeInterval(task.dueBy)))
        priporityLabel.text = task.priority?.rawValue
        priorityImageView.image = UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysTemplate)
        
    }
}
