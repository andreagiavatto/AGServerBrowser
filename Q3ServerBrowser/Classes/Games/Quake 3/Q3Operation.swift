//
//  Q3Operation.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 24/10/2017.
//

import Foundation
import CocoaAsyncSocket

let socketDelegateQueue = DispatchQueue(label: "com.socket.delegate.queue", attributes: [.concurrent])

class Q3Operation: Operation {
    
    let ip: String
    let port: UInt16
    let requestMarker: [UInt8]
    let responseMarker: [UInt8]
    
    fileprivate(set) var data = Data()
    fileprivate(set) var executionTime: TimeInterval = 0.0
    fileprivate(set) var error: Error?
    fileprivate var startTime: TimeInterval?
    private var socket: GCDAsyncUdpSocket?
    
    required init(ip: String, port: UInt16, requestMarker: [UInt8], responseMarker: [UInt8]) {
        self.ip = ip
        self.port = port
        self.requestMarker = requestMarker
        self.responseMarker = responseMarker
        
        super.init()
        
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: socketDelegateQueue)
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        
        guard isCancelled == false else {
            finish()
            return
        }
        
        self._executing = true
        
        let data = Data(bytes: self.requestMarker)
        do {
            self.socket?.send(data, toHost: self.ip, port: self.port, withTimeout: 10, tag: 42)
            try self.socket?.receiveOnce()
        } catch(let error) {
            self.finish()
        }
    }
    
    func finish() {
        _executing = false
        _finished = true
        socket?.close()
        socket = nil
    }
}

extension Q3Operation: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        let endTime = CFAbsoluteTimeGetCurrent()
        self.data.append(data)
        
        let prefix = String(bytes: responseMarker, encoding: .ascii)
        let asciiRep = String(data: self.data, encoding: .ascii)
        
        if
            let asciiRep = asciiRep,
            let prefix = prefix,
            asciiRep.hasPrefix(prefix),
            let startTime = startTime
        {
            let start = self.data.index(self.data.startIndex, offsetBy: responseMarker.count)
            var end = self.data.endIndex
            self.data = self.data.subdata(in: start..<end)
            executionTime = endTime - startTime
        }
        
        finish()
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        self.error = error
        if !_finished {
            finish()
        }
    }
}