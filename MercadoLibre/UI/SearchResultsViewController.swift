//
//  ViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import Combine



class SearchResultsViewController: UIViewController {
    
    enum Section: Hashable {
        case main
    }
    
    let viewModel: SearchViewModel = SearchViewModel()
    lazy var dataSource: UICollectionViewDiffableDataSource = makeDataSource()
    private var cancellables = Set<AnyCancellable>()
    

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupCollectionView()
        
        viewModel.search("Motorola").receive(on: RunLoop.main).sink(receiveCompletion: { completion in

        }, receiveValue: { searchResults in
            self.updateCollectionView(products: searchResults.results)
            
        }).store(in: &cancellables)
    }
    
    
    // MARK: - Helpers
    
    private func updateCollectionView(products: [ProductSearchResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductSearchResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(products, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    


    // MARK: - Configurations
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 250, height: 50)
        flowLayout.sectionInset = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
        collectionView.register(ProductSearchResultCell.self, forCellWithReuseIdentifier: "\(ProductSearchResultCell.self)")
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .white
        collectionView.delegate = self
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, ProductSearchResult> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collection, indexPath, order in
            let cell = self.collectionView.dequeueReusableCell(
                withReuseIdentifier: "\(ProductSearchResultCell.self)",
                for: indexPath
            ) as! ProductSearchResultCell
            
            cell.configure(with: order)
            return cell
            
        })
        
    }


}


// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultsViewController: UISearchBarDelegate {
    
}
