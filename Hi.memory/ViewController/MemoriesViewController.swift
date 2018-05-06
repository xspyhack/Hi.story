//
//  MemoriesViewController.swift
//  Himemory
//
//  Created by bl4ckra1sond3tre on 05/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa

public class MemoriesViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.hi.register(reusableCell: Card.self)
        collectionView.hi.register(reusableCell: TextCard.self)
        collectionView.hi.register(reusableCell: PhotoCard.self)
        collectionView.hi.register(reusableCell: VideoCard.self)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var pageControl: ProgressivePageControl = {
        let pageControl = ProgressivePageControl(frame: .zero)
        pageControl.alpha = 0.0
        return pageControl
    }()
    
    private var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private lazy var dateView: DateView = {
        let view = DateView(frame: .zero)
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        view.layer.cornerRadius = 8.0
        view.alpha = 0.0
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageEdgeInsets = UIEdgeInsets(all: 10)
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    private var isStatusBarHidden = false
    
    private var viewModel: MemoriesViewModel
    
    private let bag = DisposeBag()
    
    public init(viewModel: MemoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        
        pageControl.numberOfPages = viewModel.count
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
        
        let tap = UITapGestureRecognizer()
        collectionView.addGestureRecognizer(tap)
        
        tap.rx.event//.throttle(2.0, scheduler: MainScheduler.instance)
            .filter { [unowned self] _ in !self.viewModel.animating }
            .map { [unowned self] sender in
                sender.location(in: self.view).x
            }
            .map { [unowned self] x in
                return x < self.view.bounds.midX ? -1 : 1
            }
            .filter { [unowned self] delta in
                return self.validateIndex(self.viewModel.index.value + delta)
            }
            .subscribe(onNext: { delta in
                self.viewModel.index.value += delta
            })
            .disposed(by: bag)
        
        viewModel.index.asObservable()
            .filter(validateIndex)
            .do(onNext: { [weak self] _ in
                self?.viewModel.animating = true
            })
            .subscribe(onNext: { [weak self] index in
                self?.turnTo(index)
            })
            .disposed(by: bag)
    }
    
    private func validateIndex(_ index: Int) -> Bool {
        return index >= 0 && index < viewModel.count
    }
    
    private func turnTo(_ index: Int) {
        guard let memory = viewModel.memories.safe[index] else {
            return
        }
        
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        
        let dateViewModel = DateViewModel(createdAt: memory.date.timeIntervalSince1970, color: UIColor.red)
        dateView.configure(withPresenter: dateViewModel)
        
        viewModel.animating = false
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isStatusBarHidden = true

        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { finished in
            UIView.animate(withDuration: 0.25) {
                self.pageControl.alpha = 1.0
                self.dateView.alpha = 1.0
            }
        })
    }
    
    override public var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Methods
    
    private func setupSubViews() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(collectionView.hi.edges())
        
        view.addSubview(pageControl)
        pageControl.hi.left(with: 10).isActive = true
        pageControl.hi.right(with: -10).isActive = true
        pageControl.hi.top(safeAreaLayout: true).isActive = true
        pageControl.hi.height(with: 20).isActive = true
        
        view.addSubview(dateView)
        dateView.hi.width(with: 108).isActive = true
        dateView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateView.hi.top(with: 24, safeAreaLayout: true).isActive = true
        dateView.hi.height(with: 30).isActive = true
        
        view.addSubview(closeButton)
        closeButton.centerYAnchor.constraint(equalTo: dateView.centerYAnchor).isActive = true
        closeButton.hi.right(with: -20).isActive = true
        closeButton.hi.width(with: 44.0).isActive = true
        closeButton.hi.height(with: 44.0).isActive = true
    }
}


// MARK: - UICollectionViewDataSource

extension MemoriesViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let memory = viewModel.memories.safe[indexPath.row] else {
            let cell: Card = collectionView.hi.dequeueReusableCell(for: indexPath)
            return cell
        }
        
        switch memory.content {
        case .text(let text):
            let cell: TextCard = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withText: text)
            return cell
        case .photo(let photo):
            let cell: PhotoCard = collectionView.hi.dequeueReusableCell(for: indexPath)
            let viewModel = PhotoCardModel(photo: photo, size: view.bounds.size)
            cell.configure(withPresenter: viewModel)
            return cell
        case .video(let url):
            let cell: VideoCard = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withVideo: url)
            return cell
        case .audio(let url):
            let cell: AudioCard = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withAudio: url)
            return cell
        }
    }
}


// MARK: - UICollectionViewDelegate

extension MemoriesViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MemoriesViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height)
    }
}
