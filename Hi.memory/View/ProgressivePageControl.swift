//
//  ProgressivePageControl.swift
//  Himemory
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

class ProgressivePageControl: UIView {

    // default is 0
    var numberOfPages: Int = 0 {
        didSet {
            updatePageView()
        }
    }
    
    // default is 0. value pinned to 0..numberOfPages-1
    private(set) var currentPage: Int = 0

    // hide the the indicator if there is only one page. default is NO
    var hidesForSinglePage: Bool = false
    
    var pageIndicatorTintColor: UIColor?
    
    var currentPageIndicatorTintColor: UIColor?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    private var progressViews: [UIProgressView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func turn(to page: Int, progress: Double, animated: Bool? = nil) {
        guard page < numberOfPages else { return }
        
        currentPage = page
        
        // 把 index 后面的进度清空
        progressViews.safe[page + 1..<progressViews.count]?.forEach {
            $0.setProgress(0.0, animated: false)
        }
        
        // 当从第 0 个往后退，退到最后一个时，需要考虑把前面的进度都填满
        (progressViews.safe[0..<page]?.filter {
                $0.progress != 1.0
            })?
            .forEach {
                $0.setProgress(1.0, animated: false)
            }
        
        // 设置当前 item 的进度
        guard let progressView = progressViews.safe[page], progress >= 0.0 else { return }
        
        let validProgress = min(Float(progress), 1.0)
        progressView.setProgress(validProgress, animated: animated ?? (progressView.progress < validProgress))
    }
    
    func size(forNumberOfPages pageCount: Int) -> CGSize {
        return CGSize(width: bounds.width / CGFloat(pageCount), height: bounds.height)
    }
    
    private func setup() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate(stackView.hi.edges())
    }
    
    private func addPageView() {
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = currentPageIndicatorTintColor
        progressView.trackTintColor = pageIndicatorTintColor
        progressView.progress = 0.0
        
        UIView.performWithoutAnimation {
            stackView.addArrangedSubview(progressView)
        }
        
        progressViews.append(progressView)
    }
    
    private func updatePageView() {
        
        progressViews.forEach {
            $0.setProgress(0.0, animated: false)
        }
        
        let pageCount = progressViews.count
        
        guard pageCount != numberOfPages else {
            return
        }
        
        if (pageCount > numberOfPages) {
            progressViews.dropLast(pageCount - numberOfPages).forEach {
                stackView.removeArrangedSubview($0)
            }
        } else {
            Array(0..<numberOfPages - pageCount).forEach { _ in
                addPageView()
            }
        }
    }
}
