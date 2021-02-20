
import UIKit
import Network

class ViewController: UIViewController {

    @IBOutlet weak var connect: UIButton!
    @IBOutlet weak var sendConnectionData: UIButton!
    var group: NWConnectionGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    /*
     From the iPhone 11 Pro simulator side:
     
     2021-02-17 17:11:10.399767-0800 MulticastTest[49964:2029188] [] nw_listener_socket_inbox_create_socket setsockopt SO_NECP_LISTENUUID failed [2: No such file or directory]
     2021-02-17 17:11:10.399975-0800 MulticastTest[49964:2029188] [] nw_listener_socket_inbox_create_socket IP_DROP_MEMBERSHIP 224.0.0.1:28650 failed [49: Can't assign requested address]
     [NWConnectionGroup][state] group entered state waiting(POSIXErrorCode: Network is down)
     [NWConnectionGroup][state] waiting - The operation couldn’t be completed. (Network.NWError error 0.)
     [NWConnectionGroup][state] waiting - debugDescription: Optional("[G1 udp, indefinite]")
     [NWConnectionGroup][state] waiting - parameters: Optional(udp, indefinite)
     [NWConnectionGroup][state] group entered state ready
     [NWConnectionGroup][state] established
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.229:63004)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPad
     [NWConnectionGroup][setReceiveHandler] received: Optional(18) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.229:63004)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPad
     [NWConnectionGroup][setReceiveHandler] received: Optional(18) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     2021-02-17 17:11:30.164934-0800 MulticastTest[49964:2031622] [] nw_protocol_get_quic_image_block_invoke dlopen libquic failed
     [NWConnectionGroup][sendData] complete with error nil
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.153:57274)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPhone11ProSim
     [NWConnectionGroup][setReceiveHandler] received: Optional(28) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.153:57274)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPhone11ProSim
     [NWConnectionGroup][setReceiveHandler] received: Optional(28) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][sendData] complete with error nil
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.153:57274)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPhone11ProSim
     [NWConnectionGroup][setReceiveHandler] received: Optional(28) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.153:57274)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPhone11ProSim
     [NWConnectionGroup][setReceiveHandler] received: Optional(28) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][sendData] complete with error nil
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.153:57274)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPhone11ProSim
     [NWConnectionGroup][setReceiveHandler] received: Optional(28) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.153:57274)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPhone11ProSim
     [NWConnectionGroup][setReceiveHandler] received: Optional(28) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.229:63004)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPad
     [NWConnectionGroup][setReceiveHandler] received: Optional(18) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.229:63004)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPad
     [NWConnectionGroup][setReceiveHandler] received: Optional(18) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.229:63004)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPad
     [NWConnectionGroup][setReceiveHandler] received: Optional(18) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true
     [NWConnectionGroup][setReceiveHandler] message from Optional(192.168.107.229:63004)
     [NWConnectionGroup][setReceiveHandler] content decoded as utf8 string: helloAll_from_iPad
     [NWConnectionGroup][setReceiveHandler] received: Optional(18) bytes
     [NWConnectionGroup][setReceiveHandler] isComplete: true

     
     */

    @IBAction func setup() {
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
        group?.start(queue: .main)
        
    }
    
    @IBAction func sendData() {
        let groupSendContent = Data("helloAll_from_iPhone11ProSim".utf8)
        group?.send(content: groupSendContent) { (error) in
            print("[NWConnectionGroup][sendData] complete with error \(String(describing: error?.localizedDescription))")
        }
    }
    
}

