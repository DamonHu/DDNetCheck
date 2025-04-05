//
//  DDNetCheckVC.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

func UIImageHDBoundle(named: String?) -> UIImage? {
    guard let name = named else { return nil }
    guard let bundlePath = Bundle(for: DDNetCheck.self).path(forResource: "DDNetCheck", ofType: "bundle") else { return UIImage(named: name) }
    guard let bundle = Bundle(path: bundlePath) else { return UIImage(named: name) }
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

extension String{
    var ZXLocaleString: String {
        guard let bundlePath = Bundle(for: DDNetCheck.self).path(forResource: "DDNetCheck", ofType: "bundle") else { return NSLocalizedString(self, comment: "") }
        guard let bundle = Bundle(path: bundlePath) else { return NSLocalizedString(self, comment: "") }
        let msg = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        return msg
    }
}

class DDNetCheckVC: UIViewController {
    private var url: String
    private var checkTool: DDNetCheck
    private let list = DDNetCheckType.allCases
    
    init(url: String) {
        self.url = url
        self.checkTool = DDNetCheck(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._createUI()
        self._loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.checkTool.stop()
    }
    
    //MARK: UI
    private lazy var mTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.scrollsToTop = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.register(DDNetCheckTableViewCell.self, forCellReuseIdentifier: "DDNetCheckTableViewCell")
        tableView.rowHeight = 60
        return tableView
    }()
}

private extension DDNetCheckVC {
    func _createUI() {
        self.view.backgroundColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1)
        
        self.view.addSubview(self.mTableView)
        mTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        mTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        mTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        mTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func _loadData() {
        self.checkTool.checkNetStatus { [weak self] type, isSuccess in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let index = self.list.firstIndex(of: type), let cell = self.mTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DDNetCheckTableViewCell else {
                    return
                }
                cell.updateUI(type: type, status: isSuccess ? .success : .failed)
            }
        }
        
        self.checkTool.ping { [weak self] type, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let index = self.list.firstIndex(of: type), let cell = self.mTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DDNetCheckTableViewCell, let response = response else {
                    return
                }
                var text = "error"
                if response.responseTime.second > 0 {
                    text = "\(Int(response.responseTime.second * 1000))ms"
                }
                cell.updateUI(type: type, status: .text(text))
            }
        }
    }
}

extension DDNetCheckVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DDNetCheckTableViewCell") as! DDNetCheckTableViewCell
        cell.updateUI(type: type, status: .checking)
        return cell
    }
}
