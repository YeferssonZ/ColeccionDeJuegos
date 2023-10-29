//
//  ViewController.swift
//  ZunigaColeccionDeJuegos
//
//  Created by Yefersson Guillermo Zuñiga Justo on 23/10/23.
//
import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var juegos: [Juego] = []
    
    var context: NSManagedObjectContext! // Agrega el contexto de Core Data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        
        // Configura el contexto de Core Data
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        }
        
        // Agrega un botón de edición a la barra de navegación
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return juegos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let juego = juegos[indexPath.row]
        cell.textLabel?.text = juego.titulo
        cell.detailTextLabel?.text = juego.categoria // Muestra la categoría
        cell.imageView?.image = UIImage(data: (juego.imagen!))
        return cell
    }
    
    // Agrega la función para manejar la eliminación de filas
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let juego = juegos[indexPath.row]
            context.delete(juego)
            juegos.remove(at: indexPath.row)
            do {
                try context.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error al eliminar el juego: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let juegoMovido = juegos.remove(at: sourceIndexPath.row)
        juegos.insert(juegoMovido, at: destinationIndexPath.row)
        
        for (index, juego) in juegos.enumerated() {
            juego.orden = Int16(index)
        }
        
        do {
            try context.save()
        } catch {
            print("Error al guardar cambios en Core Data: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let fetchRequest: NSFetchRequest<Juego> = Juego.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "orden", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            juegos = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Error al cargar juegos: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let juego = juegos[indexPath.row]
        performSegue(withIdentifier: "juegoSegue", sender: juego)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! JuegosViewController
        siguienteVC.juego = sender as? Juego
    }
}

