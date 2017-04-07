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
            appLogoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AboutViewController.tappedLogo)))
        }
    }
    @IBOutlet private weak var appLogoImageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sloganLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sloganLabel: UILabel!
    @IBOutlet private weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            footerViewBottomConstraint.constant = -30.0
        }
    }
    
    @IBOutlet private weak var aboutTableView: UITableView! {
        didSet {
            aboutTableView.hi.register(reusableCell: AboutCell.self)
            aboutTableView.rowHeight = Constant.rowHeight
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
        
        sloganLabel.isHidden = true
        sloganLabel.text = "The real story, we call it history"
        sloganLabelTopConstraint.constant = -12.0
        
        appLogoImageViewTopConstraint.constant = 100.0
        appNameLabelTopConstraint.constant = 10.0
        
        let motionEffect = UIMotionEffect.hi.twoAxiesShift(40.0)
        appLogoImageView.addMotionEffect(motionEffect)
        appNameLabel.addMotionEffect(motionEffect)
        sloganLabel.addMotionEffect(motionEffect)
        appVersionLabel.addMotionEffect(motionEffect)
        
        appNameLabel.textColor = UIColor.hi.tint
        
        if let
            releaseVersionNumber = Bundle.releaseVersionNumber,
            let buildVersionNumber = Bundle.buildVersionNumber {
            appVersionLabel.text = "Version" + " " + releaseVersionNumber + " (\(buildVersionNumber))"
        }
        
        aboutTableViewHeightConstraint.constant = Constant.rowHeight * CGFloat(Row.count)
        
        aboutTableView.layer.shadowOpacity = 1.0
        aboutTableView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        aboutTableView.layer.shadowRadius = 10
        aboutTableView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if sloganLabel.isHidden {
            sloganLabel.isHidden = false
            sloganLabelTopConstraint.constant = 8.0
            appLogoImageViewTopConstraint.constant = 80.0
        } else {
            sloganLabel.isHidden = true
            sloganLabelTopConstraint.constant = -8.0
            appLogoImageViewTopConstraint.constant = 100.0
        }
        
        if footerViewBottomConstraint.constant == -30.0 {
            footerViewBottomConstraint.constant = 0.0
        } else {
            footerViewBottomConstraint.constant = -30.0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func tappedLogo() {
        
        guard let realm = try? Realm() else { return }
        
        if let author = realm.objects(User.self).filter("username = '\(Configuration.author)'").first {
            let viewModel = ProfileViewModel(user: author)
            performSegue(withIdentifier: .showProfile, sender: viewModel)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate enum Row: Int {
        //case review
        //case recommend
        //case privacyPolicy
        //case termsOfService
        case acknowledgements
        
        var annotation: String {
            
            switch self {
            //case .review: return "Review"
            //case .recommend: return "Recommend"
            //case .privacyPolicy: return "Privacy Policy"
            //case .termsOfService: return "Terms of Service"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch Row(rawValue: indexPath.row) {
        case .acknowledgements?:
            performSegue(withIdentifier: .showAcknowledgements, sender: nil)
        default:
            break
        }
    }
}

extension AboutViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showProfile
        case showAcknowledgements
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .showProfile:
            let vc = segue.destination as? ProfileViewController
            vc?.viewModel = sender as? ProfileViewModel
        default:
            break
        }
    }
}

