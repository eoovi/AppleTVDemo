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
    
    var loaded = false;
    
    let pagingScrollView = UIScrollView()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.getTvItems();
        
    }
    
    func getTvItems() {
        print("GETTING TV ITEMS")
        
//        let url = URL(string:"http://api.eoovi.com/v/list");
        let url = URL(string: "http://localhost:8080/v/list");
        
        self.loader.startAnimating()
        self.loadingTextLabel.alpha = 1;
        
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
        self.collectionView.reloadData()
        self.loadingTextLabel.alpha = 0;
        
        self.collectionView.frame.size.width = self.view.frame.size.width
        
        let width = self.collectionView.frame.width
        let calc = Float(self.videoItems.count) * Float(width) + Float(width)
        
        print("DOWNLOADED")
        print(calc)
        
        let pageSize = self.view.frame.size.width - 100
        
        self.collectionView.contentInset = UIEdgeInsetsMake(0, (self.view.frame.size.width-pageSize)/2, 0, (self.view.frame.size.width-pageSize)/2);
        
        self.collectionView.contentSize = CGSize(width: Int(calc), height: Int(self.collectionView!.frame.size.height));
        
     }
    
    // COLLECTION VIEW

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.width
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoItems.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item: VideoItem = self.videoItems[indexPath.row] as VideoItem
        
        print("ITEM SELECTED")
        
        let url = URL(string: item.location!.uri!)
        let player = AVPlayer(url:url!)
        let controller = AVPlayerViewController()
        controller.player = player;
        
        present(controller, animated:true) {
            player.play();
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = Int(self.collectionView.frame.size.width)
        let totalSpacingWidth = (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2 - 5
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)

    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//
//        let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
//        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
//
//        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//
//        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
//
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 50
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

