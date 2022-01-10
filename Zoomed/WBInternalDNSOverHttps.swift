//
//  WBInternalDNSOverHttps.swift
//  Zoomed
//
//  Created by jungao on 2021/11/18.
//

import Foundation
import Network
import System
import SwiftTrace

//#import <sys/kdebug_signpost.h>

@available(iOS 14.0, *)
class WBIDNSOverHttps : NSObject {

    static let workQueue = DispatchQueue(label: "DoH")

    @objc
    class func handleTLS(allowInsecure: Bool)
    {
//        let options = NWProtocolTLS.Options()
////        let queue = DispatchQueue(label: "DoH")
////        let sec_protocol_verify_t vt = ()
//        sec_protocol_options_set_verify_block(options.securityProtocolOptions, { (sec_protocol_metadata, sec_trust, sec_protocol_verify_complete) in
//            let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
//            var error: CFError?
//            if SecTrustEvaluateWithError(trust, &error)
//            {
//                sec_protocol_verify_complete(true)
//            }
//            else
//            {
//                if allowInsecure == true
//                {
//                    sec_protocol_verify_complete(true)
//                }
//                else
//                {
//                    sec_protocol_verify_complete(false)
//                }
//            }
//        }, workQueue)
    }

    @objc
    class func configAllLinkInAppDoH()
    {
        clearCache()
        //设置在App范围内使用加密DNS,设置阿里云公共DNS解析 https://dns.intra.weibo.cn/dns-query https://dns.weibo.cn/dns-query 10.210.100.214
        // @"https://1chuidingyin.com/dns-query";//
        if let aliurl = URL(string: "https://1chuidingyin.com/dns-query")//https://dns.alidns.com/dns-query
        {
            let address1 = NWEndpoint.hostPort(host: "127.0.0.1", port: 443)//223.5.5.5
//            let tempP = NSTemporaryDirectory()
//            let unixSocketPath = String.init(format: "%@%@", arguments: [tempP,"unix.client.socket"])//[NSString stringWithFormat:@"%@%@",tt,@"unix.socket"];

//            let unixAddress = NWEndpoint.unix(path: unixSocketPath)
//            let address2 = NWEndpoint.hostPort(host: "223.6.6.6", port: 443)//223.6.6.6
//            let address3 = NWEndpoint.hostPort(host: "2400:3200::1", port: 443)//2400:3200::1
//            let address4 = NWEndpoint.hostPort(host: "2400:3200:baba::1", port: 443)//2400:3200:baba::1

//            kdebug_signpost_start(100, 0, 0, 0, 4)
            let pcd = NWParameters.PrivacyContext.default;
            pcd.requireEncryptedNameResolution(true, fallbackResolver: .https(aliurl, serverAddresses: [address1]))
        }
    }

    @objc
    class func configAllLinkInAppDoHNormal()
    {
        clearCache()
        //设置在App范围内使用加密DNS,设置阿里云公共DNS解析
        if let aliurl = URL(string: "https://dns.alidns.com/dns-query")
        {
            let address1 = NWEndpoint.hostPort(host: "10.211.1.108", port: 443)//223.5.5.5
            let address2 = NWEndpoint.hostPort(host: "223.6.6.6", port: 443)//223.6.6.6
//            let address3 = NWEndpoint.hostPort(host: "2400:3200::1", port: 443)//2400:3200::1
//            let address4 = NWEndpoint.hostPort(host: "2400:3200:baba::1", port: 443)//2400:3200:baba::1
            NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: .https(aliurl, serverAddresses: [address1,address2]))
        }
    }

    @objc
    class func configAllLinkInAppDoHAndLocalDNS()
    {
        clearCache()
        //设置在App范围内使用加密DNS,设置阿里云公共DNS解析
        if let aliurl = URL(string: "https://10.223.69.24:8080/dns-query")//https://dns.alidns.com/dns-query https://dns.weibo.cn/dns-query
        {
            let address1 = NWEndpoint.hostPort(host: "10.223.69.24", port: 8080)//223.5.5.5
//            let address2 = NWEndpoint.hostPort(host: "10.210.100.214", port: 443)//223.6.6.6
//            let address3 = NWEndpoint.hostPort(host: "2400:3200::1", port: 443)//2400:3200::1
//            let address4 = NWEndpoint.hostPort(host: "2400:3200:baba::1", port: 443)//2400:3200:baba::1
            NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: .https(aliurl, serverAddresses: [address1]))
        }
    }


    @objc
    class func clearAllLinkInAppDoH()
    {
        //清除在App范围内使用加密DNS,设置阿里云公共DNS解析
        NWParameters.PrivacyContext.default.requireEncryptedNameResolution(false, fallbackResolver: nil)
    }

    class func clearCache()
    {
        NWParameters.PrivacyContext.default.flushCache();
    }
}
