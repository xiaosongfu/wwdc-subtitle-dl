//
//  parser.swift
//  wwdc2020-dl
//
//  Created by synix on 2020/12/25.
//

import Foundation
import Combine
import Alamofire

func getMp4Url(in htmlContent: String, quality: String) -> String? {
    do {
        let regex = try NSRegularExpression(pattern: "https://.*.mp4")
        let matches = regex.matches(in: htmlContent, options: [], range: NSRange(location: 0, length: htmlContent.count))
        
        return matches
            .map { htmlContent.substring(with: $0.range) }
            .filter { URL(string: $0)?.lastPathComponent.contains(quality) == true }
            .first
    } catch {
        return nil
    }
}

func getM3U8Url(in htmlContent: String) -> String? {
    do {
        let regex = try NSRegularExpression(pattern: "https://.*.m3u8")
        let matches = regex.matches(in: htmlContent, options: [], range: NSRange(location: 0, length: htmlContent.count))

        return matches
            .map { htmlContent.substring(with: $0.range) }
            .first
    } catch {
        return nil
    }
}

func getWebvttsUrl(in m3u8Content: String, m3u8Url: String, language: String) -> URL? {
    do {
        // wwdc2018 : #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"简体中文\",DEFAULT=NO,AUTOSELECT=NO,FORCED=NO,LANGUAGE=\"Chinese\",URI=\"subtitles/zho/prog_index.m3u8\"
//        let regex = try NSRegularExpression(pattern: "EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\".*\",DEFAULT=.*,AUTOSELECT=.*,FORCED=.*,LANGUAGE=\"(.*)\",URI=\"(.*)\"")
        
        // wwdc2019 : #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"Chinese\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"zho\",URI=\"subtitles/zho/prog_index.m3u8\"\n
        let regex = try NSRegularExpression(pattern: "EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\".*\",DEFAULT=.*,AUTOSELECT=.*,FORCED=.*,LANGUAGE=\"(.*)\",URI=\"(.*)\"")
        
        // wwdc2020 : #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="简体中文",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="zh",URI="cc/zh/zh.m3u8"
//        let regex = try NSRegularExpression(pattern: "LANGUAGE=\"(.*)\",URI=\"(.*)\"")
        
        // wwdc2021 : #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"zho\",NAME=\"简体中文\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/zho/prog_index.m3u8\",FORCED=NO\
//        let regex = try NSRegularExpression(pattern: "EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"(.*)\",NAME=\".*\",AUTOSELECT=.*,DEFAULT=.*,URI=\"(.*)\"")
        
        let matches = regex.matches(in: m3u8Content, options: [], range: NSRange(location: 0, length: m3u8Content.count))
        
        let subtitlePath = matches
            .filter { m3u8Content.substring(with: $0.range(at: 1)) == language }
            .map { m3u8Content.substring(with: $0.range(at: 2)) }
            .first

        if let m3u8Url = URL(string: m3u8Url), let subtitlePath = subtitlePath {
            let webvttsUrl = m3u8Url.deletingLastPathComponent().appendingPathComponent(subtitlePath)
            return webvttsUrl
        } else {
            return nil
        }
    } catch {
        return nil
    }
}

func getWebvvtUrlArray(in webvtts: String, webvttsUrl: URL) -> [String]? {
    do {
        let regex = try NSRegularExpression(pattern: ".*.webvtt")
        let matches = regex.matches(in: webvtts, options: [], range: NSRange(location: 0, length:webvtts.count))
        return matches
            .map { webvtts.substring(with: $0.range) }
            .map { webvttsUrl.deletingLastPathComponent().appendingPathComponent($0).absoluteString }
    } catch {
        return nil
    }
}

func parseWebvvtToSrt(webvvt: String) -> [String]? {
    do {
        var results: [String] = []

        let webvvtHeaderRegex = try NSRegularExpression(pattern: "^WEBVTT$")
        let timeStampRegex = try NSRegularExpression(pattern: "^X-TIMESTAMP-MAP=.*$")
        let cueTimeRegex = try NSRegularExpression(
            pattern: "^(\\d{2}:\\d{2}:\\d{2}\\.\\d{3}\\s*-->\\s*\\d{2}:\\d{2}:\\d{2}\\.\\d{3}).*$")

        let lines = webvvt.components(separatedBy: "\n")
        var subtitle: [String] = []

        for line in lines {
            if webvvtHeaderRegex.numberOfMatches(
                in: line, options: [], range: NSRange(location: 0, length: line.count)) > 0 {
                continue
            } else if timeStampRegex.numberOfMatches(
                        in: line, options: [], range: NSRange(location: 0, length: line.count)) > 0 {
                continue
            } else if line.isEmpty {
                continue
            } else if cueTimeRegex.numberOfMatches(
                        in: line, options: [], range: NSRange(location: 0, length: line.count)) > 0 {
                if let match = cueTimeRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                    if !subtitle.isEmpty {
                        results.append(subtitle.joined(separator: "\n"))
                        subtitle.removeAll()
                    }
                    subtitle.append(line.substring(with: match.range(at: 1)))
                }
            } else {
                subtitle.append(line)
            }
        }
        return results
    } catch  {
        return nil
    }
}
