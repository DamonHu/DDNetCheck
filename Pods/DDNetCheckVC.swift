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
        //优先使用主项目翻译
        let mainValue = NSLocalizedString(self, comment: "")
        if mainValue != self {
            return mainValue
        }
        //使用自己的bundle
        if let bundlePath = Bundle(for: DDNetCheck.self).path(forResource: "DDNetCheck", ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: self, comment: "")
        }
        return self
    }
}

//参考网站测速
public enum TestWeb: CaseIterable {
    case apple
    case amazon
    case baidu
    case aliyun
}

public class DDNetCheckVC: UIViewController {
    private var url: String
    private var checkTool = DDNetCheck()
    private var list = [[DDNetCheckTableViewCellModel]]()
    
    public init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self._createUI()
        self._loadData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self._startCheck()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.checkTool.stop()
    }
    
    //MARK: UI
    private lazy var mTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.scrollsToTop = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
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
        mTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func _loadData() {
        self.list.removeAll()
        //网站状态
        var webList = [DDNetCheckTableViewWebCellModel]()
        let model1 = DDNetCheckTableViewWebCellModel(title: "Server Connection Status".ZXLocaleString, image: UIImageHDBoundle(named: "isConnected"))
        let model2 = DDNetCheckTableViewWebCellModel(title: "Response Time".ZXLocaleString, image: UIImageHDBoundle(named: "ping"))
        webList.append(model1)
        webList.append(model2)
        //参考网站状态
        let testList = TestWeb.allCases.map { web in
            let model = DDNetCheckTableViewTestCellModel()
            model.testWeb = web
            return model
        }
        //手机状态
        let platformList = DDNetCheckType.allCases.map { type in
            let model = DDNetCheckTableViewPlatformCellModel()
            model.checkType = type
            return model
        }
        //列表
        self.list.append(webList)
        self.list.append(testList)
        self.list.append(platformList)
    }
    
    func _startCheck() {
        //网站状态
        self.checkTool.checkServer(url: URL(string: self.url)) { [weak self] status in
            guard let self = self else { return }
            let model = self.list[0][0]
            switch status {
            case .success:
                model.status = .success
            default:
                model.status = .text(status.reason(), false)
            }
            DispatchQueue.main.async {
                self.mTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
        
        self.checkTool.ping(url: self.url) { [weak self] response, error in
            guard let self = self else { return }
            let model = self.list[0][1]
            var text = "Failed".ZXLocaleString
            if let response = response, response.responseTime.second > 0 {
                text = "\(Int(response.responseTime.second * 1000))ms"
                model.status = .text(text, true)
            } else {
                model.status = .text(text, false)
            }
            
            DispatchQueue.main.async {
                self.mTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
        }
        
        //网站测试
        let sectionList1: [DDNetCheckTableViewTestCellModel] = self.list[1].compactMap { model in
            return model as? DDNetCheckTableViewTestCellModel
        }
        for index in 0..<sectionList1.count {
            let model = sectionList1[index]
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index)) {
                self.checkTool.ping(url: "https://\(model.getTitle())") { [weak self] response, error in
                    guard let self = self else { return }
                    var text = "Failed".ZXLocaleString
                    if let response = response, response.responseTime.second > 0 {
                        text = "\(Int(response.responseTime.second * 1000))ms"
                        model.status = .text(text, true)
                    } else {
                        model.status = .text(text, false)
                    }
                    DispatchQueue.main.async {
                        self.mTableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
                    }
                }
            }
            
        }
        
        //手机状态
        let sectionList2: [DDNetCheckTableViewPlatformCellModel] = self.list[2].compactMap { model in
            return model as? DDNetCheckTableViewPlatformCellModel
        }
        self.checkTool.checkPlatform { [weak self] type, isSuccess in
            guard let self = self, let index = sectionList2.firstIndex(where: { model in
                return model.checkType == type
            }) else { return }
            
            let model = sectionList2[index]
            model.status = isSuccess ? .success : .failed
            
            
            DispatchQueue.main.async {
                self.mTableView.reloadRows(at: [IndexPath(row: index, section: 2)], with: .none)
            }
        }
    }
}

extension DDNetCheckVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = list[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DDNetCheckTableViewCell") as! DDNetCheckTableViewCell
        cell.selectionStyle = .none
        cell.updateUI(image: model.getImage(), title: model.getTitle())
        cell.updateUI(status: model.status)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "App Server Connection Test".ZXLocaleString
        } else if section == 1 {
            return "Common Website Network Test".ZXLocaleString
        } else {
            return "Device Network Status".ZXLocaleString
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
