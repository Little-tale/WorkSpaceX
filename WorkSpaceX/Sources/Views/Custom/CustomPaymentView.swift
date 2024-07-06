//
//  CustomPaymentView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import SwiftUI
import iamport_ios

struct IamportPaymentView: UIViewControllerRepresentable {
    
    @Binding var iamPort: IamportPayment?
    let userCode: String
    var result: (IamportResponse?) -> Void
    var onClose: () -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = IamportPaymentViewController(iamPort: iamPort!, userCode: userCode, result: result, onClose: onClose)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.delegate = context.coordinator
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: IamportPaymentView
        var isFirstAppearance = true
        
        init(_ parent: IamportPaymentView) {
            self.parent = parent
        }
        
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            if isFirstAppearance {
                isFirstAppearance = false
                return
            }
            
            // 네비게이션 스택에 있는 뷰 컨트롤러들이 `viewController` 하나만 남아있을 때 감지
            if navigationController.viewControllers.count == 1 {
                parent.onClose()
            }
        }
    }
}

class IamportPaymentViewController: UIViewController {

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
        // 결제 요청
        Iamport.shared.payment(
            navController: self.navigationController!,
            userCode: userCode,
            payment: iamPort,
            paymentResultCallback: { [weak self] response in
                self?.result(response)
                self?.dismiss(animated: true, completion: nil)
            }
        )
    }
}
