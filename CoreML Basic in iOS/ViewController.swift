//
//  ViewController.swift
//  CoreML Basic in iOS
//
//  Created by Hamed on 7/2/1400 AP.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private lazy var imageView: UIImageView = {
       let image = UIImageView()
//        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        image.image = UIImage(systemName: "photo")
        image.layer.cornerRadius = 20
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 2
        image.layer.masksToBounds = true
        return image
    }()
    
    private lazy var label: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "Select an Image"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top+20, width: view.frame.size.width-40, height: 300)
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top+(view.frame.size.width-40)+10, width: view.frame.size.width-40, height: 100)
    }
    
    
    @objc private func didTapImage(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
    private func analyzeImage(image: UIImage?){
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else { return }
        do {
            let config = MLModelConfiguration()
            let model = try GoogLeNetPlaces(configuration: config)
            let input = GoogLeNetPlacesInput(sceneImage: buffer)
            
            let output = try model.prediction(input: input)
            let text = output.sceneLabel
            label.text = text
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // cancelled
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        analyzeImage(image: image)
        
    }
}

