//
//  WindowController.swift
//  Soundbar
//

import Cocoa
import AVFoundation


fileprivate extension NSTouchBarCustomizationIdentifier {
    
    static let touchBar = NSTouchBarCustomizationIdentifier("digital.fino.Soundbar")
}

class WindowController: NSWindowController, NSTouchBarDelegate {
    
    var player: AVAudioPlayer?
    var files = [String: String]()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    func playSound(sender: NSButton) {
        let fileUrl = getUrlFromTitle(title: sender.title)
        
        do {
            player = try AVAudioPlayer(contentsOf: fileUrl)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getTitleFromUrl(url: URL) -> String {
        return url.lastPathComponent.replacingOccurrences(of: ".mp3", with: "")
    }
    
    func getUrlFromTitle(title: String) -> URL {
        let file = self.files[title]!
        return URL.init(string: file)!
    }
    
    func getResourceFolderUrl() -> URL {
        let sounds = Bundle.main.resourcePath! + "/sounds/"
        return URL.init(string: sounds)!
    }
    
    func getMusicFolderUrl() -> URL? {
        do {
            let musicUrl = try FileManager.default.url(for: .musicDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let soundbarMusicUrl = musicUrl.absoluteURL.absoluteString + "/soundbar/"
            return URL.init(string: soundbarMusicUrl)!
        } catch let error {
            print(error.localizedDescription)
        }
        return URL.init(string: "")!
    }
    
    func readFolder(source: URL) -> [NSTouchBarItemIdentifier] {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: source, includingPropertiesForKeys: nil, options: [])
            let mp3Files = directoryContents.filter { file in file.lastPathComponent.contains(".mp3") }
            for file in mp3Files {
                let title = getTitleFromUrl(url: file)
                self.files[title] = file.absoluteURL.absoluteString
            }
            return mp3Files.flatMap { file in NSTouchBarItemIdentifier(getTitleFromUrl(url: file)) }
        } catch let error {
            print(error.localizedDescription)
        }
        return []
    }
    
    
    @available(OSX 10.12.1, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .touchBar
        
        let musicUrl = getMusicFolderUrl()
        let resourceUrl = getResourceFolderUrl()
        let musicItems = musicUrl != nil ? readFolder(source: musicUrl!) : []
        let resourceItems = readFolder(source: resourceUrl)
        touchBar.defaultItemIdentifiers = [NSTouchBarItemIdentifier("test")]
        //touchBar.defaultItemIdentifiers = musicItems + resourceItems
        
        return touchBar
        
    }
    
    @available(OSX 10.12.1, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        let scrollView = NSScrollView()
        let clipView = NSClipView()
        let scrollerLeft = NSScroller()
        let scrollerRight = NSScroller()
        let contentView = NSView()
        
        let buttonWidth = 70;
        let contentWidth = self.files.count * buttonWidth;
        let height = 35;
        
        //scrollView.frame = NSRect(x: 0, y: 0, width: 500, height: 30)
        clipView.frame = NSRect(x: 0, y: 0, width: contentWidth, height: height)
        contentView.frame = NSRect(x: 0, y: 0, width: contentWidth, height: height)
        touchBarItem.view.frame = NSRect(x: 0, y: 0, width: contentWidth, height: height)
        
        clipView.addSubview(contentView)
        clipView.addSubview(scrollerLeft)
        clipView.addSubview(scrollerRight)
        scrollView.documentView = clipView
        touchBarItem.view = scrollView

        var i = 0;
        for (key, value) in self.files {
            let button = NSButton(title: key, target: self, action: #selector(playSound))
            let buttonFrame = NSRect(x: buttonWidth * i, y: 0, width: buttonWidth - 10, height: height - 5)
            button.frame = buttonFrame
            contentView.addSubview(button)
            i += 1
        }
        
        return touchBarItem
        
        /*let frameSize = NSSize(width: touchBarItem.view.frame.width, height: touchBarItem.view.frame.height)
        scrollView.setBoundsSize(frameSize)
        scrollView.autoresizingMask = .viewWidthSizable
        touchBarItem.view = scrollView
        return touchBarItem*/
        //return NSGroupTouchBarItem.groupItem(withIdentifier: NSTouchBarItemIdentifier(identifier.rawValue), items: touchBarItems)
        
        /*let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        let button = NSButton(title: identifier.rawValue, target: self, action: #selector(playSound))
        touchBarItem.view = button
        return touchBarItem*/
        
    }
    
    
}
