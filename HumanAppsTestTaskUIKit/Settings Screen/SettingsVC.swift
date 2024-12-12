import UIKit

final class SettingsVC: UIViewController {
    
    private var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self

        configureConstraints()
        setupUI()
        cellRegistraition()
    }
    
    private func configureConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
    }
    
    private func cellRegistraition() {
        tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.register(TitleSubtitleCell.self, forCellReuseIdentifier: "TitleSubtitleCell")
        tableView.register(TitleSwitchCell.self, forCellReuseIdentifier: "TitleSwitchCell")
    }
}


extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Info", message: "Daniel Klyshko", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = data[indexPath.row]
   
        switch cellData.type {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.titleLabel.text = cellData.title
            return cell
        case .titleSubtitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleSubtitleCell", for: indexPath) as! TitleSubtitleCell
            cell.titleLabel.text = cellData.title
            cell.subtitleLabel.text = cellData.subtitle
            return cell
        case .titleSwitch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleSwitchCell", for: indexPath) as! TitleSwitchCell
            cell.titleLabel.text = cellData.title
            return cell
        }
    }
    
}
