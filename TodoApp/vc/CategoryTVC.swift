//
//  ViewController.swift
//  TodoApp
//
//  Created by Fazlik Ziyaev on 10/11/21.
//

import UIKit
import CoreData

class CategoryTVC: UITableViewController {

    let categoryCellIdentifier = "categoryCell"
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryName = ""
    let segueToItems = "GoToItemsTVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
    }

    @IBAction func addButtonPrressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: nil, preferredStyle: .alert)
        var nameTF = UITextField()
        
        alert.addTextField { tf in
            nameTF = tf
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            self.add(name: nameTF.text!)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CRUD operation
    func add(name: String){
        let newCategory = Category(context: context)
        newCategory.name = name
        categories.append(newCategory)
        
        save()
        load()
    }
    
    func load() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        }catch{
            print("Error while loading categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    func delete(category: Category) {
        context.delete(category)
        
        save()
        load()
    }
    
    func update(category: Category, newName: String) {
        category.name = newName
        
        save()
        load()
    }
    
    func deleteAll(){

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)

        } catch {
            print("Error while deleting all elements \(error)")
        }
        
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
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        categoryName = categories[indexPath.row].name!
        
        let sheet = UIAlertController(title: "Category", message: nil, preferredStyle: .actionSheet)
        
        //perform segue
        sheet.addAction(UIAlertAction(title: "Go to section", style: .default, handler: { _ in
            self.performSegue(withIdentifier: self.segueToItems, sender: self)
        }))
        
        //update
        sheet.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            let alert = UIAlertController(title: "New category name", message: nil, preferredStyle: .alert)
            var nameTF = UITextField()
            
            alert.addTextField { tf in
                nameTF = tf
            }
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
                self.update(category: self.categories[indexPath.row], newName: nameTF.text!)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        //delete
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.delete(category: self.categories[indexPath.row])
        }))
        
        //cancel
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
    }
    
    //MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier)
        cell?.textLabel?.text = categories[indexPath.row].name
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ItemsTVC
        destination.selectedCategory = self.categoryName
    }
}

