//
//  AboutViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 28/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift

final class AboutViewController: BaseViewController {
    
    @IBOutlet private weak var appLogoImageView: UIImageView! {
        didSet {
            appLogoImageView.isUserInteractionEnabled = true
            appLogoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AboutViewController.tapLogo)))
        }
    }
    @IBOutlet private weak var appLogoImageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var appVersionLabel: UILabel!
    
    @IBOutlet private weak var aboutTableView: UITableView! {
        didSet {
            aboutTableView.hi.register(reusableCell: AboutCell.self)
        }
    }
    @IBOutlet private weak var aboutTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var copyrightLabel: UILabel!
    
    fileprivate struct Constant {
        static let rowHeight: CGFloat = 60.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About"
        
        appLogoImageViewTopConstraint.constant = 20.0
        appNameLabelTopConstraint.constant = 10.0
        
        let motionEffect = UIMotionEffect.hi.twoAxiesShift(40.0)
        appLogoImageView.addMotionEffect(motionEffect)
        appNameLabel.addMotionEffect(motionEffect)
        appVersionLabel.addMotionEffect(motionEffect)
        
        appNameLabel.textColor = UIColor.hi.tint
        
        if let
            releaseVersionNumber = Bundle.releaseVersionNumber,
            let buildVersionNumber = Bundle.buildVersionNumber {
            appVersionLabel.text = "Version" + " " + releaseVersionNumber + " (\(buildVersionNumber))"
        }
        
        aboutTableViewHeightConstraint.constant = Constant.rowHeight * CGFloat(Row.count - 1) + 1.0
    }
    
    func tapLogo() {
        
        guard let realm = try? Realm() else { return }
        
        if let author = realm.objects(User.self).filter("username = 'blessingsoft'").first {
            let viewModel = ProfileViewModel(user: author)
            performSegue(withIdentifier: .showProfile, sender: viewModel)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate enum Row: Int {
        case review = 1
        case recommend
        case privacyPolicy
        case termsOfService
        case acknowledgements
        
        var annotation: String {
            
            switch self {
            case .review: return "Review"
            case .recommend: return "Recommend"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .acknowledgements: return "Acknowledgements"
            }
        }
        
        static var count: Int {
            return Row.acknowledgements.rawValue + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }
        
        let cell: AboutCell = tableView.hi.dequeueReusableCell(for: indexPath)
        cell.annotationLabel.text = row.annotation
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 1
        default:
            return Constant.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch Row(rawValue: indexPath.row) {
            
        case .review?:
            //UIApplication.shared.yep_reviewOnTheAppStore()
            break
        case .recommend?:
            break
        case .privacyPolicy?:
            break
        case .termsOfService?:
            break
        case .acknowledgements?:
            break
        default:
            break
        }
    }
}

extension AboutViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showProfile
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .showProfile:
            let vc = segue.destination as? ProfileViewController
            vc?.viewModel = sender as? ProfileViewModel
        }
    }
}

