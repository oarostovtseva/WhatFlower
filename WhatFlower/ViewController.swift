//
//  ViewController.swift
//  WhatFlower
//
//  Created by Olena Rostovtseva on 17.08.2020.
//  Copyright © 2020 orost. All rights reserved.
//

import SDWebImage
import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionView: UITextView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage {
            //imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert CI Image")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

    private func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading CoreML Model Failed")
        }

        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed Process the Image")
            }
            if let firstResult = results.first {
                let flower = firstResult.identifier.capitalized
                self.navigationItem.title = flower
                NetworkManager.getFlowerDescriptionWiki(flowerTitle: flower) { wikiResult in
                    self.descriptionView.text = wikiResult.descriptionText
                    self.imageView.sd_setImage(with: URL(string: wikiResult.imageUrl))
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
