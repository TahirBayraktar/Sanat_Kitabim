//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Tahir Bayraktar on 24.08.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearsText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting=""
    var chosenPaintingid:UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//      Tableviewdeki şeçilen satırın id ile veritabanındaki bilgileri gösterir
        if chosenPainting != ""{
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            
            let idString = chosenPaintingid?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@",idString!)
            fetchRequest.returnsObjectsAsFaults=false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count>0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearsText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data:imageData)
                            imageView.image = image
                        }
                        
                    }
                }
            }catch{
                print("error")
            }
            
        }else{
            saveButton.isHidden=false
            saveButton.isEnabled=false
        }
        
        
//      viewe tıkladığımızda klavyeyinin kapanmasını sağlıyor
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyword))
        view.addGestureRecognizer(gestureRecognizer)
        
//      imageviewe tıklandığında select image func cağır
        imageView.isUserInteractionEnabled=true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func selectImage(){
        
        let picker=UIImagePickerController()
        picker.delegate=self
//      nereden fotograf secicez onu seciyoz
        picker.sourceType  = .photoLibrary
//      düzenlenmesini sağlıyoz
        picker.allowsEditing=true
//      pickerımızı göster
        present(picker, animated: true, completion: nil)
        
    }
//    galeriden resim sectikten sonra galeriyi kapatmamızı sağlayan func
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//      editlenen image i any olarak alıyor imagei UIImage e cast ediyor
        imageView.image=info[.editedImage] as? UIImage
        saveButton.isEnabled=true
//      fotograf sectikten sonra galeriyi kapat
        self.dismiss(animated: true, completion: nil)
    }
//    klavyeyi kapatma fonksiyonu
    @objc func hideKeyword(){
        view.endEditing(true)
    }
  
    
// save buttonuna tıkladığımızda verileri veritabanına kaydet
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//      veritabanı Painting olana ekle
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        
//        Attributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year=Int(yearsText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        
//        image'i dataya cevirme
//        image i sıkıştır yüzde 50isini veritabanında tut
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
//      veritabanına kaydet
        do{
            try
                context.save()
                print("succes")
        }catch{
            print("error")
        }
//      bütün uygulamaya newdata mesajı yolla 
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
//      save tıkladıktan sonra geri git
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}
