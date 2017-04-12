//
//  GroupImagesViewController.swift
//  Kutumblink
//
//  Created by Apple on 24/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

protocol GroupImagesViewControllerDelegate {
    func updateGroupImage(image:UIImage)
}

class GroupImagesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let reuseIdentifier = "KLPhotoCollectionViewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 5

    var arrLogoImages:NSMutableArray = []
    var groupImageDelegate:GroupImagesViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = navigationBarColor
        self.navigationItem.title = "Select Group Image"

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(onTouchCancelButton))
        self.navigationItem.leftBarButtonItem = cancelButton

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        for index in 1...48
        {
            arrLogoImages.add(String(format:"logo%i",index))
        }
    }
    func onTouchCancelButton() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    //2
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return arrLogoImages.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! KLPhotoCollectionViewCell
        //2
        let imageName:String = arrLogoImages.object(at: indexPath.row) as! String
        let image:UIImage = UIImage (named:imageName)!
        cell.btnImageViewlogo.setBackgroundImage(image, for: .normal)
        cell.btnImageViewlogo.isUserInteractionEnabled = false

        //3
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         print("selected")
        let imageName:String = arrLogoImages.object(at: indexPath.row) as! String
        let image:UIImage = UIImage (named:imageName)!
        self.groupImageDelegate.updateGroupImage(image: image)
        self.navigationController?.dismiss(animated: true, completion: nil)

    }
    @IBAction func cameraAction(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(myPickerController, animated: true, completion: nil)
        }

    }
 
    @IBAction func galleryAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Dismiss the picker.
 
        dismiss(animated: true , completion: {
            self.groupImageDelegate.updateGroupImage(image: selectedImage)
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
      }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
    }
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }

    
 }


extension GroupImagesViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

