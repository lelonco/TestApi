//
//  ViewController.swift
//  TestApi
//
//  Created by Yaroslav on 12.12.2020.
//

import UIKit
import PureLayout

class ViewController: BaseViewController {

    let networkManager = NetworkManager.shared
    var didConstraintsSetup = false
    var didLoginModeEnabled = true {
        didSet {
            self.loginRegisterButton.setTitle(didLoginModeEnabled ? "Login":"Register", for: .normal)
        }
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in"
        label.textAlignment = .center
        return label
    }()
    let emailTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "E-mail"
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftView = UIView.hSpacer(width: 10)
        textField.leftViewMode = .always

        textField.autoSetDimension(.height, toSize: 40)
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()

        textField.isSecureTextEntry = true
        textField.placeholder = "Password"
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftView = UIView.hSpacer(width: 10)
        textField.leftViewMode = .always
        textField.autoSetDimension(.height, toSize: 40)
        
        return textField
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .lightGray
        button.autoSetDimension(.height, toSize: 40)
        
        button.layer.cornerRadius = 15
        return button
    }()
    
    let loginRegisterRow: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "Login/Register"
        
        let enableSwich = UISwitch()
        
        [label,enableSwich].forEach({ view.addSubview($0) })
        
        enableSwich.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        enableSwich.isOn = true
        label.autoPinEdge(toSuperviewEdge: .leading,withInset: 20)
        label.autoPinEdge(toSuperviewEdge: .top)
        label.autoPinEdge(toSuperviewEdge: .bottom)
        
        enableSwich.autoPinEdge(toSuperviewEdge: .trailing)
        enableSwich.autoPinEdge(toSuperviewEdge: .top)
        enableSwich.autoPinEdge(toSuperviewEdge: .bottom)
        return view
    }()
    
    let contentStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        stack.alignment = .fill
        
        return stack
    }()
  
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
    
        
        [emailTextField,passwordTextField,loginRegisterRow,loginRegisterButton].forEach({ contentStack.addArrangedSubview($0) })
        
        [titleLabel,contentStack].forEach({ self.view.addSubview($0) })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginRegisterButton.addTarget(self, action: #selector(loginRegisterTapped), for: .touchUpInside)
        emailTextField.text = "sample@sample.com"
        passwordTextField.text = "123123131321"

        // Do any additional setup after loading the view.
    }


    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard !self.didConstraintsSetup else { return }
        
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 150)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading,withInset: 20)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing,withInset: 20)

        contentStack.autoPinEdge(toSuperviewEdge: .leading,withInset: 20)
        contentStack.autoPinEdge(toSuperviewEdge: .trailing,withInset: 20)
        contentStack.autoPinEdge(.top, to: .bottom, of: titleLabel,withOffset: 50)
        
        didConstraintsSetup = true
    }
    
    @objc
    func loginRegisterTapped() {
        if didLoginModeEnabled {
            login()
        } else {
            register()
        }
    }
    
    
    func register() {

        let user = User(email: emailTextField.text!, password: passwordTextField.text!)
        
        let request = RequestBuilder.registerNewUser(newUser: user)
        networkManager.makeRequest(request) { (response, responeObject) in
            guard let frontViewController = UIApplication.topViewController() as? BaseViewController else { return }

            switch (response as? HTTPURLResponse)?.statusCode {
            case 201:
                if let dict = (try! JSONSerialization.jsonObject(with: responeObject as! Data, options: [])) as? [String:Any],
                   let token = dict["token"] as? String {
                    self.saveAccountAcess(token: token)
                }
            case 404:
                self.presentAlert(title: "Error", message: "Something went wrong 404")
            default:
                let decoder = JSONDecoder()
                let errorMessage = try! decoder.decode(ErrorMesasge.self, from: responeObject as! Data)
                DispatchQueue.main.async {
                    frontViewController.presentAlert(title: errorMessage.message ?? "", message: errorMessage.fields?.description() ?? "")
                }
            }
        } failure: { (error) in
            if !Reachability.shared.isConnected {
                self.saveAccountAcess(token: nil)
            }
            assertionFailure(error.localizedDescription)
        }
    }
    
    func login() {
        let user = User(email: emailTextField.text!, password: passwordTextField.text!)
        let request = RequestBuilder.authorize(user: user)
        networkManager.makeRequest(request) { (response, responeObject) in
            guard let frontViewController = UIApplication.topViewController() as? BaseViewController else { return }
            switch (response as? HTTPURLResponse)?.statusCode {
            case 200:
                if let dict = (try! JSONSerialization.jsonObject(with: responeObject as! Data, options: [])) as? [String:Any],
                   let token = dict["token"] as? String {
                    self.saveAccountAcess(token: token)
                }
            case 403,422:
                let decoder = JSONDecoder()
                let errorMessage = try! decoder.decode(ErrorMesasge.self, from: responeObject as! Data)
                print(errorMessage.getErrorMessage())
                DispatchQueue.main.async {
                    frontViewController.presentAlert(title: errorMessage.message ?? "", message: errorMessage.fields?.description() ?? "") {
                        if frontViewController != self {
                            UserDefaults.standard.setValue(false, forKey: Constants.didRegistred)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.didRegistredNotification), object: nil)
                        }
                    }
                }
                
            default:
//                let decoder = JSONDecoder()
//                let errorMessage = try! decoder.decode(ErrorMesasge.self, from: responeObject as! Data)
//                print(errorMessage.getErrorMessage())
//                DispatchQueue.main.async {
//                    self.presentAlert(title: errorMessage.message ?? "", message: errorMessage.fields?.description() ?? "")
//                }
                assertionFailure("Something went wrong status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            }
        } failure: { (error) in
            if !Reachability.shared.isConnected {
                self.saveAccountAcess(token: nil)
            }
//            assertionFailure(error.localizedDescription)
        }
    }
    func saveAccountAcess(token: String?) {
        DispatchQueue.main.async {
            TaskManager.shared.cleanQueue()
            guard let email = self.emailTextField.text,
                  let password = self.passwordTextField.text else {
                return
            }
            
            var dateComp = DateComponents()
            dateComp.hour = 24
            let calendar = Calendar.current
            let expierDate = calendar.date(byAdding: dateComp, to: Date())
            let accountAccess = AccountAccess(user:User(email:email,password:password), token: token, expierDate: expierDate)
            let mode:EnteringMode = self.didLoginModeEnabled ? .login : .register
            accountAccess.enteringMode = mode
            KeychainManager.removeSecureInfo()
            KeychainManager.save(account: accountAccess)
            UserDefaults.standard.setValue(true, forKey: Constants.didRegistred)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.didRegistredNotification), object: nil)
            TaskManager.shared.startExecute()

        }
    }
    @objc
    func switchValueChanged(sender:UISwitch) {
        didLoginModeEnabled = sender.isOn
    }
}

