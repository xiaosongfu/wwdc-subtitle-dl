//
//  main.swift
//  wwdc-video-list
//
//  Created by xiaosongfu on 2021/6/16.
//

import Foundation
import Alamofire
import SwiftSoup

let wwdc2020Url = "https://developer.apple.com/videos/"
let wwdc2020HtmlSourceFile = "wwdc2020.html"
let wwdc2020JsonResultFile = "wwdc2020.json"

// https://developer.apple.com/videos/play/wwdc2020/10028/
let baseUrl = "https://developer.apple.com"
let wwdc2020VideoPlayUrl = "/videos/play/wwdc2020/"

loadHtmlTextFromWeb(url: wwdc2020Url) { html in
//loadHtmlTextFromLocalFile(fileName: wwdc2020HtmlSourceFile) { html in
    do {
        
        var videoGroups: [VideoGroup] = []
        
        let doc: Document = try SwiftSoup.parse(html)
        let elements: Elements = try doc.select("section.section-block")
        for element in elements.array().dropLast() {
            
            var videos: [VideoGroup.Video] = []
            
            let rows = try element.select("div.row")
            
            let groupName = try rows.first()!.select("h4").text()
            // print("groupName: \(groupName)")
            
            for row in rows.array().dropFirst() {
                let cols = try row.select("div.column")
                for col in cols.array() {
                    let playUrl = try col.select("a").first()!.attr("href") // "/videos/play/wwdc2020/10028/"
                    let id = extractVideoId(videoPlayUrl: playUrl, droped: wwdc2020VideoPlayUrl)
                    let name = try col.select("h4").text()
                    let duration = try col.select("span.video-duration").text()
                    let albumUrl = try col.select("img").attr("src")
                    
                    videos.append(
                        VideoGroup.Video(
                            id: id,
                            name: name,
                            duration: duration,
                            //                            albumUrl: albumUrl,
                            playUrl: baseUrl + playUrl
                        )
                    )
                    
                    // print("\(id) - \(name) - \(duration) - \(albumUrl) - \(playUrl)")
                    
                    // 下载封面图片
                    //                    downloadAlbumImage(imageUrl: albumUrl, fileName: "\(id).png")
                }
            }
            
            videoGroups.append(VideoGroup(groupName: groupName, videos: videos))
        }
        
        guard let content = try? JSONEncoder().encode(videoGroups) else {
            print("encode to json failed.")
            return
        }
        
        writeResultToFile(data: content, fileName: wwdc2020JsonResultFile)
        
        
    } catch {
        print(error)
    }
}
// 不要让进程结束，等待图片下载完成
//RunLoop.main.run()


// videoPlayUrl is like: "/videos/play/wwdc2020/10028/"
func extractVideoId(videoPlayUrl: String, droped: String) -> String {
    var copy  = videoPlayUrl
    
    let endIndex1 = copy.index(copy.startIndex, offsetBy: (droped.count - 1))
    copy.removeSubrange(copy.startIndex...endIndex1)
    
    let endIndex2 = copy.index(copy.endIndex, offsetBy: -1)
    copy.remove(at: endIndex2)
    
    return copy
}

func downloadAlbumImage(imageUrl: String, fileName: String) {
    let destination: DownloadRequest.Destination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in:.userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    AF.download(imageUrl, to: destination)
        .downloadProgress(queue: DispatchQueue.global(qos: .background)) { progress in
            print("\(fileName) download progress: \(Int(progress.fractionCompleted * 100))")
        }
        .response(queue: DispatchQueue.global(qos: .background)) { _ in
            print("\(fileName) download success")
        }
}

// MARK: prepare html source

func loadHtmlTextFromWeb(url: String, completion: @escaping (String)-> Void){
    AF.request("https://abc.com").responseString(queue: .global(qos: .background), encoding: String.Encoding.utf8) { resp in
        switch resp.result {
            case .success(let html):
                debugPrint(html)
                completion(html)
            case .failure(let err):
                debugPrint(err)
        }
    }
}

func loadHtmlTextFromLocalFile(fileName: String, completion: @escaping (String) -> Void) {
    guard let url = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        print("can't access download dir")
        return
    }
    
    guard let xx = FileManager.default.contents(atPath: url.path + "/wwdc2020.html") else {
        print("can't read \(fileName) file")
        return
    }
    
    guard let html = String(data: xx, encoding: .utf8) else {
        return
    }
    
    completion(html)
}

// MARK: write json result to file

func writeResultToFile(data: Data, fileName: String) {
    guard let url = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        print("can't access download dir")
        return
    }
    
    if FileManager.default.createFile(atPath: url.path + "/\(fileName)", contents: data, attributes: nil) {
        print("write success.")
    } else {
        print("write faild.")
    }
}
