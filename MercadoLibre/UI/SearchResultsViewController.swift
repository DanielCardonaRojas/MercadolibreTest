//
//  ViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import Combine

class SearchResultsViewController: UIViewController {

    enum Status {
        case loadedContent, loading, empty, iddle
    }

    lazy var viewModel: ProductSearchViewModel = {
        let vm = ProductSearchViewModel()
        vm.delegate = self
        return vm
    }()

    private var status: Status = .iddle {
        didSet {
            renderStatus(status)
        }
    }

    lazy var loadingController = LoadingViewController()

    lazy var emptyStateView: UIView = {
        let nib = UINib(nibName: "EmptySearchResultsView", bundle: nil)
        let backgroundView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()

    private var isGrid: Bool = false

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

        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate {
            emptyStateView.relativeTo(view, positioned: .inset(by: 0))
        }
        emptyStateView.isHidden = true

    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print("Will transition to \(newCollection)")
        isGrid = UIDevice.current.orientation.isLandscape
        collectionView.collectionViewLayout.invalidateLayout()
        view.setNeedsLayout()
        (UIApplication.shared.delegate as? AppDelegate)?.setStatusBar()
    }

    // MARK: - Helpers

    private func renderStatus(_ status: Status) {
        switch status {
        case .loading:
            showSpinner()
        case .loadedContent:
            hideSpinner()
            collectionView.isHidden = false
            hideEmptyState()
        case .empty:
            hideSpinner()
            collectionView.isHidden = true
            showEmptyState()
        case .iddle:
            break
        }
    }

    private func showSpinner() {
        addChild(loadingController)
        loadingController.view.frame = view.frame
        view.addSubview(loadingController.view)
        view.bringSubviewToFront(loadingController.view)
        loadingController.didMove(toParent: self)
    }

    private func hideSpinner() {
        loadingController.willMove(toParent: nil)
        loadingController.view.removeFromSuperview()
        loadingController.removeFromParent()
    }

    private func showEmptyState() {
        emptyStateView.isHidden = false
    }

    private func hideEmptyState() {
        emptyStateView.isHidden = true
    }

    private func isIndexPathRequiringFetch(_ indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.products.count
    }

    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
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
        flowLayout.sectionInset = UIEdgeInsets(top: 24, left: 12, bottom: 0, right: 12)
        collectionView.register(ProductSearchResultCell.self, forCellWithReuseIdentifier: "\(ProductSearchResultCell.self)")
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false

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
extension SearchResultsViewController: ProductSearchViewModelDelegate {
    func didNotFindResults(for query: String) {
        renderStatus(.empty)
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let queryString = searchBar.text else {
            return
        }
        renderStatus(.loading)
        viewModel.search(queryString, completion: { newItems in
            self.renderStatus(newItems.isEmpty ? .empty : .loadedContent)
            self.collectionView.setContentOffset(.zero, animated: true)
            self.collectionView.reloadData()
            self.collectionView.backgroundView = nil
        })
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = isGrid ? 2 : 1
        return CGSize(width: collectionView.frame.width / itemsPerRow - 30, height: 70)
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
