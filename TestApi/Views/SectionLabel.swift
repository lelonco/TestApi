//
//  SectionLabel.swift
//  TestApi
//
//  Created by Yaroslav on 19.12.2020.
//

import Foundation
import UIKit

class SectionLabel: UILabel {
    
    init(with text: String) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = .darkGray
        self.font = .systemFont(ofSize: 19, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
