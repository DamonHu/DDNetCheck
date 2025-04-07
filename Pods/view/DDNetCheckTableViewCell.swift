//
//  DDNetCheckTableViewCell.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

class DDNetCheckTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func createUI() {
        self.contentView.addSubview(mIconImageView)
        mIconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        mIconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16).isActive = true
        mIconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        mIconImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.contentView.addSubview(mTitleLabel)
        mTitleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        mTitleLabel.leftAnchor.constraint(equalTo: self.mIconImageView.rightAnchor, constant: 10).isActive = true
        
        self.contentView.addSubview(mNetCheckStatusView)
        mNetCheckStatusView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        mNetCheckStatusView.leftAnchor.constraint(equalTo: mTitleLabel.rightAnchor, constant: 10).isActive = true
    }
    
    func updateUI(image: UIImage?, title: String?) {
        mIconImageView.image = image
        mTitleLabel.text = title
        self.mNetCheckStatusView.mLoadingIndicator.startAnimating()
    }
    
    func updateUI(status: CheckStatus) {
        self.mNetCheckStatusView.status = status
    }
    
    
    //MARK: UI
    lazy var mIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var mTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    lazy var mNetCheckStatusView: DDNetCheckStatusView = {
        let view = DDNetCheckStatusView()
        return view
    }()
}
