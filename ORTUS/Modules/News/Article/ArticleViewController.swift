//
//  ArticleViewController.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 21/03/19.
//  Copyright (c) 2019 Firdavs. All rights reserved.
//

import UIKit
import Carbon
import SafariServices

class ArticleViewController: TranslatableModule, ModuleViewModel, AlertPresentable {
    var viewModel: ArticleViewModel
    
    var translateBarButtonItem: UIBarButtonItem!
    
    weak var articleView: ArticleView! { return view as? ArticleView }
    weak var tableView: UITableView! { return articleView.tableView }
    
    let headerView = ArticleHeaderComponentView()
    
    private let kTableHeaderHeight: CGFloat = 260
    
    lazy var adapter: ArticleTableViewAdapter = {
        let adapter = ArticleTableViewAdapter()
        adapter.delegate = self
        
        return adapter
    }()
    
    lazy var renderer = Renderer(
        adapter: adapter,
        updater: UITableViewUpdater()
    )
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    init(viewModel: ArticleViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    override func loadView() {
        view = ArticleView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventLogger.log(.openedArticle(
            id: viewModel.article.id,
            title: viewModel.article.title
        ))
        
        prepareNavigationItem()
        prepareHeaderView()
        prepareData()
        
        render()
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: UIScreen.main.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.alpha = 1
        UIApplication.shared.statusBarView?.backgroundColor = .clear
    }
    
    override func prepareLocales() {
        
    }
    
    func render() {
        renderer.render {
            Section(id: "article") {
                ArticleContentComponent(
                    id: viewModel.article.id,
                    article: viewModel.article,
                    onContentChange: { [unowned self] in
                        self.updateTableView()
                    },
                    onLinkActivated: { [unowned self] url in
                        self.handle(url)
                    }
                )
            }
        }
    }
    
    func updateTableView() {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func handle(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { (success) in
            if !success {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true)
            }
        }
    }
    
    @objc func translate() {
        alert(type: .info, message: "This will be available soon!")
    }
    
    @objc func back() {
        viewModel.router.close()
    }
    
    fileprivate func updateStatusBar(offset: CGFloat) {
        let statusBarCurrentStyle = statusBarStyle
        
        if offset >= 1 {
            statusBarStyle = .default
        } else {
            statusBarStyle = .lightContent
        }
        
        if statusBarStyle != statusBarCurrentStyle {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

extension ArticleViewController {
    func prepareNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        
//        translateBarButtonItem = UIBarButtonItem(image: UIImage(named: "translate"), style: .plain, target: self, action: #selector(translate))
//        navigationItem.rightBarButtonItem = translateBarButtonItem
    }
    
    func prepareHeaderView() {
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: 260, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -260)
        
        updateHeaderView()
    }
    
    func prepareData() {
        renderer.target = tableView
        
        if let imageURL = viewModel.article.imageURL {
            headerView.imageView.kf.setImage(with: URL(string: imageURL))
        }
        
        headerView.titleLabel.text = viewModel.article.title
        headerView.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
}

extension ArticleViewController: ArticleTableViewAdapterDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = (scrollView.contentOffset.y + 260) / 180
        
        if offset > 1 {
            offset = 1
            
            navigationController?.navigationBar.alpha = offset
        } else {
            navigationController?.navigationBar.alpha = offset
        }

        updateStatusBar(offset: offset)
        updateHeaderView()
    }
}
