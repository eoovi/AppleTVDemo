//
//  CollectionViewCell.swift
//  Eoovi Demo TV
//
//  Created by Paul Gardiner on 05/06/2018.
//  Copyright © 2018 Paul Gardiner. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var activity: UIActivityIndicatorView?
    
    func setLabel(string: String) {
        self.titleLabel?.text = string
        self.titleLabel?.alpha = 0;
        self.activity?.color = UIColor.white
    }
    
    func setImage(url: String) {
        let url = URL(string: url)
    
        self.imageView?.setNeedsFocusUpdate()
        
        self.activity?.startAnimating()
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.imageView?.image = UIImage(data: data!)
                self.activity!.stopAnimating()
            }
        }
    
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if(self.isFocused) {
            self.titleLabel?.alpha = 1;
        } else {
            self.titleLabel?.alpha = 0;
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
