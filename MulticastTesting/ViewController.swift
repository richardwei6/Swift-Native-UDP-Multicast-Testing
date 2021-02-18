//
//  ViewController.swift
//  MulticastTesting
//
//  Created by Richard Wei on 2/17/21.
//

import UIKit
import Network

class ViewController: UIViewController {

    var group : NWConnectionGroup?;
    
    @objc func sendData(){
        group?.send(content: "Test".data(using: .utf8)){ (error) in
            print("[NWConnectionGroup][sendData] complete with error \(String(describing: error?.localizedDescription))");
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let multicast = try? NWMulticastGroup(for: [ .hostPort(host: "224.0.0.1", port: 28650) ]) else {
            fatalError("[NWConnectionGroup] Could not create NWMulticastGroup")
        }
        
        group = NWConnectionGroup(with: multicast, using: .udp)
        
        
        group?.setReceiveHandler(maximumMessageSize: 16384, rejectOversizedMessages: true) { (message, content, isComplete) in
            print("[NWConnectionGroup][setReceiveHandler] message from \(String(describing: message.remoteEndpoint))")
            if let contentData = content,
               let strMessage = String(bytes: contentData, encoding: .utf8) {
                print("[NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: \(strMessage)")
            }
            print("[NWConnectionGroup][setReceiveHandler] received: \(String(describing: content?.count)) bytes")
            print("[NWConnectionGroup][setReceiveHandler] isComplete: \(isComplete)")
            let sendContent = Data("ack".utf8)
            message.reply(content: sendContent)
        }
        
        group?.stateUpdateHandler = { (newState) in
            print("[NWConnectionGroup][state] group entered state \(String(describing: newState))")
            switch newState {
            case .ready:
                // Setup the receive method to ensure data is captured on the incoming connection.
                print("[NWConnectionGroup][state] established")
                
            case .setup:
                print("[NWConnectionGroup][state] setup")
            case .waiting(let error):
                
                print("[NWConnectionGroup][state] waiting - \(error.localizedDescription)")
                print("[NWConnectionGroup][state] waiting - debugDescription: \(String(describing: self.group?.debugDescription))")
                print("[NWConnectionGroup][state] waiting - parameters: \(String(describing: self.group?.parameters))")
                
            case .failed(let error):
                print("[NWConnectionGroup][state] failed: \(error.localizedDescription)")
            case .cancelled:
                print("[NWConnectionGroup][state] cancelled ")
                
            default:
                break
            }
        }
        group?.start(queue: .main);
        
        let testButton = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 50));
        testButton.backgroundColor = UIColor.blue;
        testButton.addTarget(self, action: #selector(sendData), for: .touchUpInside);
        
        self.view.addSubview(testButton);
        
    }


}

