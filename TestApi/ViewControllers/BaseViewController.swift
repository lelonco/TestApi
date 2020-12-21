//
//  BaseViewController.swift
//  TestApi
//
//  Created by Yaroslav on 19.12.2020.
//

import UIKit


class BaseViewController: UIViewController {
    
    var bottomLayoutView: UIView? = nil
    var bottomLayoutConstraint: NSLayoutConstraint? = nil
    var bottomOffset:CGFloat = 0.0
    var shouldIgnoreKeyboardChanges = false
    var shouldBottomViewReserveSpaceForKeyboard = false
    var shouldAnimateBottomLayout = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrame(_:)),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Sizes
    class func ScaleFromIPhone5To7Plus(_ iPhone5Value: CGFloat, _ iPhone7PlusValue: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width

        let kIPhone7PlusScreenWidth: CGFloat = 414.0
        let kIPhone7ScreenWidth: CGFloat = 375.0
        
        if screenWidth < kIPhone7PlusScreenWidth && screenWidth < kIPhone7ScreenWidth {
            return iPhone5Value
        } else {
            return iPhone7PlusValue
        }
    }
    
     // MARK: - Keyboard handling

    @discardableResult
    func autoPinView(toBottomOfViewControllerOrKeyboard view: UIView?, withOffset:CGFloat = 0) -> NSLayoutConstraint? {

        bottomLayoutView = view
        bottomLayoutConstraint = view?.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: withOffset)
        bottomOffset = withOffset
        return bottomLayoutConstraint
    }

    @objc
    func keyboardWillShow(_ notification: Notification?) {
        handleKeyboardNotificationBase(notification)
    }
    @objc
    func keyboardDidShow(_ notification: Notification?) {
        handleKeyboardNotificationBase(notification)
    }
    @objc
    func keyboardWillHide(_ notification: Notification?) {
        handleKeyboardNotificationBase(notification)
    }
    @objc
    func keyboardDidHide(_ notification: Notification?) {
        handleKeyboardNotificationBase(notification)
    }
    @objc
    func keyboardWillChangeFrame(_ notification: Notification?) {
        handleKeyboardNotificationBase(notification)
    }
    @objc
    func keyboardDidChangeFrame(_ notification: Notification?) {
        handleKeyboardNotificationBase(notification)
    }
    @objc
    func handleKeyboardNotificationBase(_ notification: Notification?) {

        if shouldIgnoreKeyboardChanges {
            return
        }

        let userInfo = notification?.userInfo

        let keyboardEndFrameValue = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if keyboardEndFrameValue == nil {
            assertionFailure("Missing keyboard end frame")
            return
        }

        let keyboardEndFrame = keyboardEndFrameValue?.cgRectValue
        let keyboardEndFrameConverted = view.convert(keyboardEndFrame ?? CGRect.zero, from: nil)
        // Adjust the position of the bottom view to account for the keyboard's
        // intrusion into the view.
        //
        // On iPhoneX, when no keyboard is present, we include a buffer at the bottom of the screen so the bottom view
        // clears the floating "home button". But because the keyboard includes it's own buffer, we subtract the length
        // (height) of the bottomLayoutGuide, else we'd have an unnecessary buffer between the popped keyboard and the input
        // bar.
        let offset = CGFloat(-max(0, (view.frame.height - self.view.safeAreaInsets.bottom - (keyboardEndFrameConverted.origin.y + bottomOffset))))

        let updateLayout = { [self] in
            if shouldBottomViewReserveSpaceForKeyboard && offset >= 0 {
                // To avoid unnecessary animations / layout jitter,
                // some views never reclaim layout space when the keyboard is dismissed.
                //
                // They _do_ need to relayout if the user switches keyboards.
                return
            }
            bottomLayoutConstraint?.constant = offset
            bottomLayoutView?.superview?.layoutIfNeeded()
        }
        
        if shouldAnimateBottomLayout {
            updateLayout()
        } else {
            // UIKit by default animates all changes in response to keyboard events.
            // We want to suppress those animations if the view isn't visible,
            // otherwise presentation animations don't work properly.
            UIView.performWithoutAnimation(updateLayout)
        }
    }
    
    
    func presentAlert(title:String, message: String, complition: (() -> ())? = nil) {
        
        let allertCOntrller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            complition?()
        }
        
        allertCOntrller.addAction(cancel)
        self.present(allertCOntrller, animated: true, completion: nil)
    }
    
}
