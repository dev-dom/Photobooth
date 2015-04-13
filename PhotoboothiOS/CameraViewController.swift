import UIKit
import MobileCoreServices
import PhotoboothiOS


class CameraViewController: UIViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate /*, UITextViewDelegate */ {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var statusTextField: UITextView!
    @IBOutlet weak var sendTweetButton: UIButton!
    
    /* We will use this variable to determine if the viewDidAppear:
    method of our view controller is already called or not. If not, we will
    display the camera view */
    var beenHereBefore = false
    var controller: UIImagePickerController?
    
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    func cameraSupportsMedia(mediaType: String,
        sourceType: UIImagePickerControllerSourceType) -> Bool{
            
            let availableMediaTypes =
            UIImagePickerController.availableMediaTypesForSourceType(sourceType) as
            [String]?
            
            if let types = availableMediaTypes{
                for type in types{
                    if type == mediaType{
                        return true
                    }
                }
            }
            
            return false
    }
    
    func doesCameraSupportTakingPhotos() -> Bool{
        return cameraSupportsMedia(kUTTypeImage as String, sourceType: .Camera)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if beenHereBefore {
            /* Only display the picker once as the viewDidAppear: method gets
            called whenever the view of our view controller gets displayed */
            return;
        } else {
            beenHereBefore = true
        }
        
//        self.showPhotoModal();
        
    }
    
    func showPhotoModal() {
        
        controller = UIImagePickerController()
            
        if let theController = controller{
                
            if isCameraAvailable() && doesCameraSupportTakingPhotos(){
                theController.sourceType = .Camera
                theController.cameraDevice = .Front
            } else {
                theController.sourceType = .PhotoLibrary
            }
            
            theController.mediaTypes = [kUTTypeImage as String]
            
            theController.allowsEditing = true
            theController.delegate = self
            
            presentViewController(theController, animated: true, completion: nil)
        }
            
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
            println("Picker returned successfully")
            
            picker.dismissViewControllerAnimated(true, completion: {
                
                let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
                
                if let type:AnyObject = mediaType {
                    
                    if type is String {
                        let stringType = type as String
                        
                        //                    if stringType == kUTTypeMovie as String {
                        //                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as NSURL
                        //                        if let url = urlOfVideo {
                        //                            println("Video URL = \(url)")
                        //                        }
                        //                    }
                        
                        if stringType == kUTTypeImage as String {
                            
                            /* Let's get the metadata. This is only for images. Not videos */
                            let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
                            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                            
                            if let theImage = image {
                                
                                // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                                self.imageView.image = image
                                
                                println("Image = \(theImage)")
                            }
                        }
                        
                    }
                }
                
            })
            
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("Picker was cancelled")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTouchUpInsidePhotoButton(sender: AnyObject) {

        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        println("didTouchUpInsidePhotoButton")
        
        self.showPhotoModal()
        
    }
    
    // hide keyboard for UITextView
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func didTouchUpInsideTweetButton(sender: AnyObject) {

        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }

        let status = self.statusTextField.text
        let uiImage = self.imageView.image
        let imageData = UIImageJPEGRepresentation(uiImage, 0.5)
        
        if status != nil && imageData != nil {

            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.swifter.postStatusUpdate(self.statusTextField.text, media:imageData, inReplyToStatusID: nil, lat: nil, long: nil, placeID: nil, displayCoordinates: nil, trimUser: nil, success: {
                (status: Dictionary<String, JSONValue>?) in
                
                    self.showTweets();

                }, failure: failureHandler)

        }

        println("didTouchUpInsideTweetButton")

    }
    
    @IBAction func showSettings(sender: AnyObject) {

        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as UIViewController
            self.showViewController(controller, sender: self)
        });

    }
    
    @IBAction func showTweets(){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = TweetViewController()
            self.showViewController(controller, sender: self)

        });
        
    }
    
    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}