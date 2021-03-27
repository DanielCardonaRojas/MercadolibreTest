//
//  ViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import Combine



class SearchResultsViewController: UIViewController {
    let viewModel: SearchViewModel = SearchViewModel()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupCollectionView()
        
    }
    
    
    // MARK: - Helpers
    func isIndexPathRequiringFetch(_ indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.products.count
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
      let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
      let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
      return Array(indexPathsIntersection)
    }
    
    private func calculateIndexPathsToReload(from newItems: [ProductSearchResult]) -> [IndexPath] {
        let startIndex = viewModel.products.count - newItems.count
        let endIndex = startIndex + newItems.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    // MARK: - Configurations
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
        collectionView.register(ProductSearchResultCell.self, forCellWithReuseIdentifier: "\(ProductSearchResultCell.self)")
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
    }
    

}

// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("Prefetching")
        let unFetchedIndexPaths = indexPaths.filter(isIndexPathRequiringFetch)
        
        if !unFetchedIndexPaths.isEmpty {
            DispatchQueue.main.async {
                self.viewModel.fetch { newItems in
                    let newIndexPaths = self.calculateIndexPathsToReload(from: newItems)
                    let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPaths)
                    self.collectionView.reloadItems(at: indexPathsToReload)
                }
            }

        }
    }
    
    
}


// MARK: -
extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
}
// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

}

// MARK: - UICollectionViewDataSource
extension SearchResultsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.isEmpty ? 0 : viewModel.totalItems ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(ProductSearchResultCell.self)",
            for: indexPath
        ) as! ProductSearchResultCell
        
        let product = viewModel.products[safe: indexPath.row]
        cell.configure(with: product, index: indexPath.row)

        return cell
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let queryString = searchBar.text else {
            return
        }
        
        viewModel.search(queryString, completion: {
            self.collectionView.setContentOffset(.zero, animated: true)
            self.collectionView.reloadData()
        })
    }

}
