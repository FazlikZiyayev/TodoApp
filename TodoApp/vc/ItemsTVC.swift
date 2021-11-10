//
//  ItemsTVC.swift
//  TodoApp
//
//  Created by Fazlik Ziyaev on 10/11/21.
//

import UIKit
import CoreData

class ItemsTVC: UITableViewController {

    let itemsCellIdentifier = "itemCell"
    var items = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedCategory
        
        load()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New item", message: nil, preferredStyle: .alert)
        var nameTf = UITextField()
        
        alert.addTextField { tf in
            nameTf = tf
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            self.add(name: nameTf.text!)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - CRUD operation
    func add(name: String){
        let newItem = Item(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        newItem.categoryName = selectedCategory
        
        save()
        load()
    }
    
    func load() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "categoryName MATCHES %@", selectedCategory)
        let sort = NSSortDescriptor(key: "categoryName", ascending: true)
        
        request.predicate = predicate
        request.sortDescriptors = [sort]
        
        do{
            items = try context.fetch(request)
        }catch{
            print("Error while loading categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    func delete(item: Item) {
        context.delete(item)
        
        save()
        load()
    }
    
    func update(item: Item, newName: String) {
        item.name = newName
        item.createdAt = Date()
        
        save()
        load()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func deleteAll(){

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)

        } catch {
            print("Error while deleting all elements \(error)")
        }
        
        save()
        load()
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sheet = UIAlertController(title: "Item", message: nil, preferredStyle: .actionSheet)
        
        //update
        sheet.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            let alert = UIAlertController(title: "New item name", message: nil, preferredStyle: .alert)
            var nameTF = UITextField()
            
            alert.addTextField { tf in
                nameTF = tf
            }
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
                self.update(item: self.items[indexPath.row], newName: nameTF.text!)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        //delete
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.delete(item: self.items[indexPath.row])
        }))
        
        //cancel
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemsCellIdentifier)
        cell?.textLabel?.text = items[indexPath.row].name
        return cell!
    }
}
