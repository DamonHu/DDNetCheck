//
//  DDNetCheckStatusView.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

enum CheckStatus {
    case wait
    case checking
    case success
    case failed
    case text(String, Bool)
}

class DDNetCheckStatusView: UIView {
    var status = CheckStatus.wait {
        didSet {
            self.mLabelView.isHidden = true
            switch status {
            case .wait:
                self.mLoadingIndicator.isHidden = true
                self.mStatusImageView.isHidden = true
            case .checking:
                self.mLoadingIndicator.isHidden = false
                self.mStatusImageView.isHidden = true
            case .success:
                self.mLoadingIndicator.isHidden = true
                self.mStatusImageView.isHidden = false
                self.mStatusImageView.image = UIImage(named: "icon-success")
            case .failed:
                self.mLoadingIndicator.isHidden = true
                self.mStatusImageView.isHidden = false
                self.mStatusImageView.image = UIImage(named: "icon-failed")
            case .text(let text, let isSuccess):
                self.mLoadingIndicator.isHidden = true
                self.mStatusImageView.isHidden = true
                self.mLabelView.isHidden = false
                self.mLabelView.backgroundColor = isSuccess ?
                self.mTitleLabel.text = text
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.addSubview(mLoadingIndicator)
        mLoadingIndicator.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mLoadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(mStatusImageView)
        mStatusImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mStatusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        mStatusImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        mStatusImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.addSubview(mLabelView)
        mLabelView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        mLabelView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mLabelView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        mLabelView.heightAnchor.constraint(equalToConstant: 23).isActive = true
        
        mLabelView.addSubview(mTitleLabel)
        mTitleLabel.centerYAnchor.constraint(equalTo: mLabelView.centerYAnchor).isActive = true
        mTitleLabel.leftAnchor.constraint(equalTo: mLabelView.leftAnchor, constant: 10).isActive = true
        mTitleLabel.rightAnchor.constraint(equalTo: mLabelView.rightAnchor, constant: -10).isActive = true
        mTitleLabel.heightAnchor.constraint(equalTo: mLabelView.heightAnchor).isActive = true
    }
    


    //MARK: UI
    lazy var mLoadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = true
        return loadingIndicator
    }()
    
    lazy var mStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var mLabelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = UIColor(red: 63.0 / 255.0, green: 125.0 / 255.0, blue: 88.0 / 255.0, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()
    
    lazy var mTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
}
