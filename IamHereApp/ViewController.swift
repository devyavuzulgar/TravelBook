//
//  ViewController.swift
//  IamHereApp
//
//  Created by Yavuz Ulgar on 12.01.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var places = [String]()
    var id = [UUID]()
    var choosenPlace = ""
    var choosenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Topbar Eklemeler
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        tableView.delegate = self
        tableView.dataSource = self
     
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func getData() {
        
        places.removeAll(keepingCapacity: false)
        id.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
           let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let titles = result.value(forKey: "title") as? String {
                    places.append(titles)
                }
                if let idS = result.value(forKey: "id") as? UUID {
                    id.append(idS)
                }
                self.tableView.reloadData()
            }
        } catch {
            print("Error")
        }
    }
    
    @objc func addButton(){
        performSegue(withIdentifier: "toAddVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var context = cell.defaultContentConfiguration()
        context.text = places[indexPath.row]
        cell.contentConfiguration = context
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenPlace = places[indexPath.row]
        choosenId = id[indexPath.row]
        performSegue(withIdentifier: "toIamVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toIamVC" {
            let goVC = segue.destination as! ViewControllerIAM
            goVC.selectedId = choosenId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let ids = result.value(forKey: "id") as? UUID {
                        if ids == id[indexPath.row] {
                            context.delete(result)
                            places.remove(at: indexPath.row)
                            id.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do {
                                try context.save()
                                print("deleted")
                            } catch {
                                print("error")
                            }
                        }
                    }
                }
                
            } catch {
                print("hata")
            }
        }
    }
}

