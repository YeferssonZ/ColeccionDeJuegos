//
//  JuegosViewController.swift
//  ZunigaColeccionDeJuegos
//
//  Created by Yefersson Guillermo Zuñiga Justo on 23/10/23.
//
import UIKit
import CoreData

class JuegosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var JuegoImageView: UIImageView!
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var agregarActualizarBoton: UIButton!
    @IBOutlet weak var eliminarBoton: UIButton!
    @IBOutlet weak var categoriaPicker: UIPickerView!
    @IBOutlet weak var categoriaLabel: UILabel!

    var imagePicker = UIImagePickerController()
    var juego: Juego?
    var selectedCategory: String?

    var genres: [String] = ["Acción", "Terror", "Carreras", "Multijugador", "Aventura", "Deportes"]

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        categoriaPicker.dataSource = self
        categoriaPicker.delegate = self

        if juego != nil {
            JuegoImageView.image = UIImage(data: (juego!.imagen!) as Data)
            tituloTextField.text = juego!.titulo
            selectedCategory = juego!.categoria
            agregarActualizarBoton.setTitle("Actualizar", for: .normal)
            categoriaLabel.text = selectedCategory
        } else {
            eliminarBoton.isHidden = true
            categoriaLabel.isHidden = true
        }
    }

    @IBAction func fotosTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if juego != nil {
            juego!.titulo = tituloTextField.text
            juego!.imagen = JuegoImageView.image?.jpegData(compressionQuality: 0.50)
            juego!.categoria = selectedCategory
        } else {
            let juego = Juego(context: context)
            juego.titulo = tituloTextField.text
            juego.imagen = JuegoImageView.image?.jpegData(compressionQuality: 0.50)
            juego.categoria = selectedCategory
        }

        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al guardar el juego: \(error)")
        }
    }

    @IBAction func eliminarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(juego!)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagenSeleccionada = info[.originalImage] as? UIImage
        JuegoImageView.image = imagenSeleccionada
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genres.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = genres[row]
        categoriaLabel.text = selectedCategory
    }
}
