//
//  ViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import Combine

class SearchResultsViewController: UIViewController {
    lazy var viewModel: SearchViewModel = {
        let vm = SearchViewModel()
        vm.delegate = self
        return vm
    }()

    @IBOutlet var collectionView: UICollectionView!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        let search = UISearchController(searchResultsController: nil)
        search.searchBar.searchBarStyle = .prominent
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.delegate = self
        self.navigationItem.searchController = search
        (UIApplication.shared.delegate as? AppDelegate)?.setStatusBar()

    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print("Will transition to \(newCollection)")
        (UIApplication.shared.delegate as? AppDelegate)?.setStatusBar()
    }

    // MARK: - Helpers
    let loadingController = LoadingViewController()

    func showSpinner() {
        addChild(loadingController)
        loadingController.view.frame = view.frame
        view.addSubview(loadingController.view)
        view.bringSubviewToFront(loadingController.view)
        loadingController.didMove(toParent: self)
    }

    func hideSpinner() {
        loadingController.willMove(toParent: nil)
        loadingController.view.removeFromSuperview()
        loadingController.removeFromParent()
    }

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

// MARK: - UICollectionViewDataSourcePrefetching
extension SearchResultsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
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

// MARK: SearchViewModelDelegate
extension SearchResultsViewController: SearchViewModelDelegate {
    func didNotFindResults(for query: String) {
        hideSpinner()
        ToastManager.sharedInstance.queue(toast: "No se encontraron resultados")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
}
// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel.products[safe: indexPath.row] else {
            return
        }

        let vc = UIStoryboard.main.instantiate(ProductDetailsViewController.self)!
        vc.itemId = item.id
        navigationController?.pushViewController(vc, animated: true)

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
        showSpinner()
        viewModel.search(queryString, completion: {
            self.hideSpinner()
            self.collectionView.setContentOffset(.zero, animated: true)
            self.collectionView.reloadData()
        })
    }

}
