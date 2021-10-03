//
//  NotesViewController.swift
//  notes
//
//  Created by pavel on 27.09.21.
//

import UIKit

class NotesViewController: UIViewController {
    
    private var notesTableView = UITableView()
    private let cellId = "cell"
    private var height = CGFloat(70)
    var models = [(title: "MY FIRST NOTE", note: "This is my first note.")]
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNavController() //navigationController
        createTableView() //tableView
        constraintsTableView() //constaints TableView
    }
    
    
    //MARK: - save text and title notes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let textNote = UserDefaults.standard.object(forKey: "text\(index)") as? String  {
            models[index].note = textNote
            notesTableView.reloadData()
        }

        if let titleNote = UserDefaults.standard.object(forKey: "title\(index)") as? String {
            models[index].title = titleNote
            notesTableView.reloadData()
        }
    }
    
    
    //MARK: - update navigationBar + action rightBarButton
    func updateNavController() {
        //Navigation Controller
        let titleLabel = UILabel()
        titleLabel.text = "Notes"
        titleLabel.textColor = .white
        title = titleLabel.text
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        view.backgroundColor = .black
        
        //item
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(clickRightButton))
        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
        
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    
    //MARK: - click "+" button
    @objc func clickRightButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "detail") as? DetailViewController else {return}
        vc.title = "New Note"
        vc.completion = { title, note in
            self.models.append((title, note))
            self.notesTableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - create tableView + constraints
    func createTableView() {
        notesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.layer.cornerRadius = 15
        notesTableView.backgroundColor = #colorLiteral(red: 0.1726491451, green: 0.1723766625, blue: 0.1811300516, alpha: 1)
        notesTableView.separatorColor = .systemGray
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notesTableView)
    }
    
    
    func constraintsTableView() {
        let constraints = [notesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
                           notesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                           notesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                           notesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
}


//MARK: - UITableViewDataSource, UITableViewDelegate
extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return models.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        // show ">"
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        cell.accessoryView = imageView
        
        cell.backgroundColor = #colorLiteral(red: 0.1726491451, green: 0.1723766625, blue: 0.1811300516, alpha: 1)
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 2
        cell.tintColor = .systemGray
        cell.selectionStyle = .none
        cell.textLabel?.text = models[indexPath.row].title
        cell.detailTextLabel?.text = models[indexPath.row].note
    
        return cell
    }
    
    
    //height row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return height
    }
    
    
    //didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notesTableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.row]
        index = indexPath.row
        
        // show textView (DetailViewController)
        guard let vc = storyboard?.instantiateViewController(identifier: "detail") as? DetailViewController else {return}
        vc.title = model.title
        vc.note = model.note
        vc.index = index
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //delete
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            models.remove(at: indexPath.row)
            notesTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
