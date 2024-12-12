import UIKit
import GPUImage

final class ImageEditorVC: UIViewController {

    private let saveButton = UIButton()
    private let loadButton = UIButton()
    private let photoContainer = UIView()
    private let imageView = UIImageView()
    private let segmentControl = UISegmentedControl(items: ["None", "Sepia", "Mono", "Sketch"])

    private var pinchGesture: UIPinchGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!

    private var originalImage: UIImage?
    private var filteredImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(photoContainer)
        photoContainer.addSubview(imageView)
        view.addSubview(saveButton)
        view.addSubview(loadButton)
        view.addSubview(segmentControl)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
        
        configureConstraints()
        setupUI()
    }
    
    private func configureConstraints() {
        photoContainer.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            photoContainer.widthAnchor.constraint(equalToConstant: 300),
            photoContainer.heightAnchor.constraint(equalToConstant: 300),

            imageView.centerXAnchor.constraint(equalTo: photoContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: photoContainer.centerYAnchor),
            imageView.widthAnchor.constraint(greaterThanOrEqualTo: photoContainer.widthAnchor),
            imageView.heightAnchor.constraint(greaterThanOrEqualTo: photoContainer.heightAnchor),

            loadButton.topAnchor.constraint(equalTo: photoContainer.bottomAnchor, constant: 20),
            loadButton.leadingAnchor.constraint(equalTo: photoContainer.leadingAnchor),
            loadButton.widthAnchor.constraint(equalToConstant: 220),
            loadButton.heightAnchor.constraint(equalToConstant: 60),

            saveButton.topAnchor.constraint(equalTo: photoContainer.bottomAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: photoContainer.trailingAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 60),
            saveButton.heightAnchor.constraint(equalToConstant: 60),

            segmentControl.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalToConstant: 300),
            segmentControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .white

        photoContainer.backgroundColor = .white
        photoContainer.layer.borderColor = UIColor.systemGreen.cgColor
        photoContainer.layer.borderWidth = 2
        photoContainer.layer.cornerRadius = 20
        photoContainer.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        loadButton.setTitle("Load Image", for: .normal)
        loadButton.setTitleColor(.systemBlue, for: .normal)
        loadButton.layer.borderWidth = 2
        loadButton.layer.borderColor = UIColor.systemBlue.cgColor
        loadButton.layer.cornerRadius = 20
        loadButton.addTarget(self, action: #selector(loadImage), for: .touchUpInside)
        
        saveButton.setImage(UIImage(systemName: "arrow.down.to.line"), for: .normal)
        saveButton.tintColor = .white
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 20
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        
        segmentControl.tintColor = .white
        segmentControl.backgroundColor = .systemBlue
        segmentControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
    }

    private func cropImageToContainer() -> UIImage? {
        guard let originalImage = originalImage else { return nil }

        let scale = originalImage.size.width / imageView.bounds.width
        let containerBounds = photoContainer.convert(photoContainer.bounds, to: imageView)

        let cropRect = CGRect(
            x: containerBounds.origin.x * scale,
            y: containerBounds.origin.y * scale,
            width: containerBounds.size.width * scale,
            height: containerBounds.size.height * scale
        )

        guard let cgImage = originalImage.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }
    
    private func cropImageToContainerAfterFilter(filteredImage: UIImage) -> UIImage? {
        guard let cgImage = filteredImage.cgImage else { return nil }

        let scale = CGFloat(cgImage.width) / imageView.bounds.width
        let containerBounds = photoContainer.convert(photoContainer.bounds, to: imageView)

        let cropRect = CGRect(
            x: containerBounds.origin.x * scale,
            y: containerBounds.origin.y * scale,
            width: containerBounds.size.width * scale,
            height: containerBounds.size.height * scale
        )

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: filteredImage.scale, orientation: filteredImage.imageOrientation)
    }

    
    private func applyFilter(to image: UIImage) {
        let selectedIndex = segmentControl.selectedSegmentIndex

        let inputImage = PictureInput(image: image)
        let output = PictureOutput()

        output.imageAvailableCallback = { [weak self] filteredImage in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.filteredImage = self.cropImageToContainerAfterFilter(filteredImage: filteredImage)
                self.imageView.image = self.filteredImage
            }
        }

        let filter: BasicOperation?
        switch selectedIndex {
        case 1:
            filter = SepiaToneFilter()
        case 2:
            filter = Luminance()
        case 3:
            filter = SketchFilter()
        default:
            imageView.image = originalImage
            filteredImage = nil
            return
        }

        if let filter = filter {
            inputImage --> filter --> output
        } else {
            inputImage --> output
        }

        inputImage.processImage(synchronously: true)
    }

    
    
    @objc private func filterChanged() {
            guard let originalImage = originalImage else { return }
            applyFilter(to: originalImage)
    }
    
    @objc private func saveImage() {
        let imageToSave: UIImage?

        if let filteredImage = filteredImage {
            imageToSave = cropImageToContainerAfterFilter(filteredImage: filteredImage)
        } else {
            imageToSave = cropImageToContainer()
        }

        guard let image = imageToSave else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageAlert(_:didFinishSavingWithError:contextInfo:)), nil)
    }


    @objc private func loadImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func imageAlert(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: nil, message: error == nil ? "Image saved!" : "Failed to save image.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }

        let translation = gesture.translation(in: photoContainer)

        imageView.center = CGPoint(
            x: imageView.center.x + translation.x,
            y: imageView.center.y + translation.y
        )

        gesture.setTranslation(.zero, in: photoContainer)
    }
    
}

extension ImageEditorVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            originalImage = selectedImage
            imageView.image = selectedImage
            imageView.transform = .identity
            segmentControl.selectedSegmentIndex = 0
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
