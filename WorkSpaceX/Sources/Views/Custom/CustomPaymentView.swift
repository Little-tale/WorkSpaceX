//
//  CustomPaymentView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import SwiftUI
import WebKit
import iamport_ios


struct CustomPaymentView: UIViewControllerRepresentable {
   
    var iamPort: IamportPayment
    var userCode: String
    
    var result: (IamportResponse?) -> Void
    var onClose: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let view = PaymentViewController(
            iamPort: iamPort,
            userCode: userCode,
            result: result,
            onClose: onClose
        )
        return view
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class PaymentViewController: UIViewController, WKNavigationDelegate {
    
    var iamPort: IamportPayment
    var userCode: String
    var result: (IamportResponse?) -> Void
    var onClose: () -> Void
    
    init(iamPort: IamportPayment, userCode: String, result: @escaping (IamportResponse?) -> Void, onClose: @escaping () -> Void) {
        self.iamPort = iamPort
        self.userCode = userCode
        self.result = result
        self.onClose = onClose
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("PaymentView viewDidLoad")

        view.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentView viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentView viewDidAppear")
        requestPayment()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("PaymentView viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("PaymentView viewDidDisappear")
        onClose()
    }


    // 아임포트 SDK 결제 요청
    func requestPayment() {
        
        let userCode = userCode
        Iamport.shared.useNavigationButton(enable: true)
        let payment = iamPort
        Iamport.shared.payment(viewController: self,
            userCode: userCode, payment: payment) { [weak self] response in
            self?.result(response)
        }
    }

}



//struct CustomPaymentView: UIViewControllerRepresentable {
//    
//    @Binding var iamPort: IamportPayment?
//    
//    var result: (IamportResponse?) -> Void
//    
//    func makeUIViewController(context: Context) -> PaymentViewController {
//        let viewController = PaymentViewController(
//            iamPort: $iamPort,
//            result: result
//        )
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: PaymentViewController, context: Context) {
//        if iamPort == nil {
//            uiViewController.dismiss(animated: true, completion: nil)
//        }
//    }
//}
//
//class PaymentViewController: UIViewController, WKNavigationDelegate {
//    
//    @Binding var iamPort: IamportPayment?
//    
//    var result: (IamportResponse?) -> Void
//    
//    init(iamPort: Binding<IamportPayment?>, result: @escaping (IamportResponse?) -> Void) {
//        self._iamPort = iamPort
//        self.result = result
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private lazy var wkWebView: WKWebView = {
//        var view = WKWebView()
//        view.backgroundColor = UIColor.clear
//        view.navigationDelegate = self
//        return view
//    }()
//    
//    private func attachWebView() {
//        view.addSubview(wkWebView)
//        wkWebView.frame = view.frame
//
//        wkWebView.translatesAutoresizingMaskIntoConstraints = false
//        wkWebView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        wkWebView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//        wkWebView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        wkWebView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//    }
//    
//    private func removeWebView() {
//        view.willRemoveSubview(wkWebView)
//        wkWebView.stopLoading()
//        wkWebView.removeFromSuperview()
//        wkWebView.uiDelegate = nil
//        wkWebView.navigationDelegate = nil
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("viewDidLoad")
//        view.backgroundColor = UIColor.white
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("viewDidAppear")
//        attachWebView()
//        requestPayment()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print("viewWillDisappear")
//        removeWebView()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("viewDidDisappear")
//        Iamport.shared.close()
//        if iamPort != nil {
//            iamPort = nil
//        }
//    }
//    
//    func requestPayment() {
//        guard let iamPort = iamPort else { return }
//    
//        let userCode = APIKey.userCode
//
//        Iamport.shared.paymentWebView(webViewMode: wkWebView, userCode: userCode, payment: iamPort) { [weak self] iamportResponse in
//            self?.result(iamportResponse)
//            self?.iamPort = nil
//        }
//    }
//}
