//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Tahir Bayraktar on 24.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingid : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        
        getData()
        
//  navigationcontrollera(telefonun üst kısmı) sağ tarafına + buttonu ekle ve tıklanınca addButtonClicked funcını çalıstır.
    navigationController?.navigationBar.topItem?.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
    }
//    her viewcontroller acıldığında cağrılır
    override func viewWillAppear(_ animated: Bool) {
//        new data mesajını alınca getData yı calıştıracak
        NotificationCenter.default.addObserver(self, selector: #selector(getData) , name: NSNotification.Name("newData"), object: nil)
    }
//  diğer seque ye gitmemizi sağlar
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
// verileri veritabanından cekmemizi sağlayan func
    @objc func getData(){
//      viewwillapperda get data tekrar calıstığı için dizide 2 kere gözükmemesi için sil
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        fetchRequest.returnsObjectsAsFaults=false
        
        do{
            let results = try context.fetch(fetchRequest)
//          cektiğimiz veriler any dizi olduğu için object olarak cast ediyoruz
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                }
                self.tableView.reloadData()
                    
            }
                    
        }catch{
                print("error")
            }
        
    }
// tableview uzunluğunu belirleme
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
//tableview satırlayında isimleri göstermek
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=UITableViewCell()
        
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = contentc
//        cell.textLabel?.text=nameArray[indexPath.row] (artık desteklenmiyor)
        return cell
        
    }
    
//  seque olursa secilen satırın id isini DetailsVC e aktar
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting=selectedPainting
            destinationVC.chosenPaintingid=selectedPaintingid
        }
    }
//    tıklanılan satırın değerlerini al ve diğer sekmeye geç
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingid = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
//  tableviewde satırları sola kaydırarak satırı ve veritabanındaki verileri siler
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do{
        let results = try context.fetch(fetchRequest)
            if results.count>0{
                for result in results as! [NSManagedObject]{
                    if let id = result.value(forKey: "id") as? UUID{
                        if id == idArray[indexPath.row]{
                            context.delete(result)
                            nameArray.remove(at:indexPath.row)
                            idArray.remove(at:indexPath.row)
                            self.tableView.reloadData()
                            
                            do{
                                try context.save()
                            }catch{
                                print("error")
                            }
                            break
                            
                            
                        }
                        
                    }
                }
            }
        }catch{
            print("error")
        }
    }
}

