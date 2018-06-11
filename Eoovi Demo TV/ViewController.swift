//
//  ViewController.swift
//  Eoovi Demo TV
//
//  Created by Paul Gardiner on 05/06/2018.
//  Copyright © 2018 Paul Gardiner. All rights reserved.
//

import UIKit
import AVKit


struct VideoItemProfile {
    let title: String?
    let description: String?
    let meta_cover_image: String?
    let createdAt: String?
}

struct VideoItemLocation {
    let uri: String?
}

struct VideoItemThumbnail {
    let uri: String?
}

struct VideoItem {
    let id: String?
    let profile: VideoItemProfile?
    let location: VideoItemLocation?
    let thumbnails: [VideoItemThumbnail]?
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var loadingTextLabel: UILabel!
    
    var videoItems: [VideoItem] = [];
    var loaded = false
    let pagingScrollView = UIScrollView()
    
    let playerViewerController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.collectionView.isScrollEnabled = false;
        self.getTvItems();
        
    }
    
    
    func getTvItems() {
        print("GETTING TV ITEMS")
        
//        let url = URL(string:"http://api.eoovi.com/v/list");
        let url = URL(string: "http://api.eoovi.com/v/list");
        
        self.loader.color = UIColor.white
        self.loader.startAnimating()
        
        let task = URLSession.shared.dataTask(with: url!)  { data, response, error in
            guard error == nil else {
                print("ERROR");
                return;
            }
            
            guard let data = data else {
                print("DATA IS EMPTY");
                return;
            }
        
            
            self.processJSON(data:data)
        }
        
        task.resume();
    }
    
    func processJSON(data: Data) {
        
        let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
        let items = json["payload"] as! [[String:Any]]
        var vitem: [VideoItem] = [];
        for item in items {
            let id = item["id"] as! String
            let thumbs = item["thumbs"] as! [[String:Any]]
            var tarr: [VideoItemThumbnail] = [];
            
            
            for thumb in thumbs {
                let uri = thumb["uri"]! as! String
                let thm = VideoItemThumbnail(uri: uri)
                tarr.append(thm)
            }
            
            let locations = item["locations"]! as! [String:Any]
            let hls_index = locations["hls_index"]! as! [String:Any]
            let location = hls_index["uri"] as! String
            let loc = VideoItemLocation(uri: location)
            
            let profile = item["profile"] as! [String:Any]
            let ptitle = profile["title"] as! String
            let pdesc  = profile["description"]! as! String
            let cover  = profile["meta_cover_image"]! as! String
            let created = profile["createdAt"] as! String
            
            let vprof = VideoItemProfile(title: ptitle, description: pdesc , meta_cover_image: cover, createdAt: created)
            
            let nitem = VideoItem(id: id, profile: vprof, location: loc, thumbnails: tarr)
            vitem.append(nitem)
            
        }
        
        self.videoItems = vitem.reversed();
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.loader.stopAnimating()
            
            self.collectionView.updateFocusIfNeeded()
            
            self.collectionView.frame.size.width = self.view.frame.size.width
            
            let width = self.collectionView.frame.width
            let calc = Float(self.videoItems.count) * Float(width) + Float(width)
            
            let pageSize = self.view.frame.size.width - 200  / 3
            
            self.collectionView.contentInset = UIEdgeInsetsMake(0, (self.view.frame.size.width-pageSize)/2, 0, (self.view.frame.size.width-pageSize)/2);
            
            self.collectionView.contentSize = CGSize(width: Int(calc), height: Int(self.collectionView!.frame.size.height));
            
            super.setNeedsFocusUpdate()
            super.updateFocusIfNeeded()
        }
        
        
     }
 
    // COLLECTION VIEW
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if(!self.collectionView.isScrollEnabled) {
            if(context.nextFocusedView is UICollectionViewCell) {
                if let cell: UICollectionViewCell = context.nextFocusedView as! CollectionViewCell {
                    let indexPath: IndexPath = self.collectionView!.indexPath(for: cell) as! IndexPath
                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoItems.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let item: VideoItem = self.videoItems[indexPath.row] as VideoItem
        
        print("ITEM SELECTED")
        
        let url = URL(string: item.location!.uri!)
        let player = AVPlayer(url:url!)
        self.playerViewerController.player = player;
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerViewerController.player?.currentItem)

        
        present(self.playerViewerController, animated:true) {
            player.play();
        }
        
    }

    @objc func playerDidFinishPlaying() {
       self.playerViewerController.dismiss(animated: true, completion: {})
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = Int(self.collectionView.frame.size.width / 3)
        let totalSpacingWidth = (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2 `
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)

    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 50.0, bottom: 0.0, right: 50.0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView?.image = UIImage(named: "empty");
        
        let item: VideoItem = self.videoItems[indexPath.row] as VideoItem
        cell.setLabel(string: item.profile!.title!)
        cell.setImage(url: item.profile!.meta_cover_image!)
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

