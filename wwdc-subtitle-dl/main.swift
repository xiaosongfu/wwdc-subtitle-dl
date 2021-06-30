//
//  main.swift
//  wwdc-subtitle-dl
//
//  Created by xiaosongfu on 2021/6/10.
//

import Foundation
import ArgumentParser

struct WWDCDownloadCommander: ParsableCommand {
    @Argument(help: "Session id of wwdc 2020.")
    var sessionId: String
    
    //    // wwdc2018 eng Chinese
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"eng\",URI=\"subtitles/eng/prog_index.m3u8\"\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"日本語\",DEFAULT=NO,AUTOSELECT=NO,FORCED=NO,LANGUAGE=\"Japanese\",URI=\"subtitles/jpn/prog_index.m3u8\"\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"简体中文\",DEFAULT=NO,AUTOSELECT=NO,FORCED=NO,LANGUAGE=\"Chinese\",URI=\"subtitles/zho/prog_index.m3u8\"\n
    
    //    // wwdc2019 eng zho
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"eng\",URI=\"subtitles/eng/prog_index.m3u8\"\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subsC\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"eng\",URI=\"subtitles/engc/prog_index.m3u8\"\n\n\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"Japanese\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"jpn\",URI=\"subtitles/jpn/prog_index.m3u8\"\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subsC\",NAME=\"Japanese\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"jpn\",URI=\"subtitles/jpnc/prog_index.m3u8\"\n\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"Chinese\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"zho\",URI=\"subtitles/zho/prog_index.m3u8\"\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subsC\",NAME=\"Chinese\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"zho\",URI=\"subtitles/zhoc/prog_index.m3u8\"\n\n

    //    // wwdc2020 en zh
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="cc/en/en.m3u8"
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="日本語",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="ja",URI="cc/ja/ja.m3u8"
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="简体中文",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="zh",URI="cc/zh/zh.m3u8"
    
    //    // wwdc2021 eng zho
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"kor\",NAME=\"한국어\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/kor/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"jpn\",NAME=\"日本語\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/jpn/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"zho\",NAME=\"简体中文\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/zho/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"eng\",NAME=\"English\",AUTOSELECT=YES,DEFAULT=YES,URI=\"subtitles/eng/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"fra\",NAME=\"Français\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/fra/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"rus\",NAME=\"Русский\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/rus/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"deu\",NAME=\"Deutsch\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/deu/prog_index.m3u8\",FORCED=NO\n
    //    #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",LANGUAGE=\"spa\",NAME=\"Español\",AUTOSELECT=YES,DEFAULT=NO,URI=\"subtitles/spa/prog_index.m3u8\",FORCED=NO\n"
    
    @Option(name: .shortAndLong, help: "Language of subtitle you want")
    var language: String = ""
    
    func run() throws {
        print("""
        Receive: sessionId = \(sessionId), language = \(language)
        """)
        
        let dl = WWDCDownloader(sessionId: sessionId)
        dl.downloadSrt(language: language, quality: "hd", completion: {})
    }
}

WWDCDownloadCommander.main()
RunLoop.main.run()
