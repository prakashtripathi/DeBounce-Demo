//
//  ViewController.swift
//  DeBounce Demo
//
//  Created by Prakash Tripathi on 28/03/23.
//

import UIKit

enum apiError : Error{
    case urlError
    case dataError
    case responseError
    case decodingError
    case message(Error)
    
}

class ViewController: UIViewController {

    @IBOutlet var tableview : UITableView!
    @IBOutlet var searchbar : UISearchBar!
    var tableData :  ApiModel? {
        didSet {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
    }
    var workItem : DispatchWorkItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.dataSource = self
        self.searchbar.delegate = self
        // Do any additional setup after loading the view.
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let queue = DispatchQueue(label: "backgroundque", qos: .background)
        
        queue.async {
            self.getDataFromApi(query: "love") {[weak self] response in
                switch response {
                case .success(let model) :
                    self?.tableData = model
                    
                    
                    break
                case .failure(let error ) :
                    print(error.localizedDescription)
                }
            
            }
        }
    }
    


    func getDataFromApi(query : String, completion : @escaping(Result<ApiModel,apiError>) -> Void){
        
        let url  = URL(string: "https://dummyjson.com/posts/search?q=\(query)")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
          
            print("api called ")
            guard let data, error == nil else{
                           completion(.failure(.dataError))
                           return
                       }
                       guard let response = response as? HTTPURLResponse,
                             200...499 ~= response.statusCode else{
                           completion(.failure(.responseError))
                           return
                       }
                       
                       do {
                           let apiResponse = try JSONDecoder().decode(ApiModel.self, from: data)
                           completion(.success(apiResponse))
                           
                       } catch (let error) {
                           completion(.failure(.message(error)))
                           
                       }
            
        }.resume()
        
    }


}


extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.posts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let text = self.tableData?.posts[indexPath.row].title
        cell.textLabel?.text = text ?? ""
        return cell
    }
    
    
    
    
}


extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        workItem?.cancel()
        
        let searchItem = DispatchWorkItem{
            self.getDataFromApi(query: searchText) {[weak self] response in
                switch response {
                case .success(let model) :
                    self?.tableData = model
                    
                    
                    break
                case .failure(let error ) :
                    print(error.localizedDescription)
                }
            
            }
        }
        
        self.workItem = searchItem
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: searchItem)
        
        
        
    }
}
