//
//  ViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import Combine

class SearchResultsViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    enum Status {
        case loadedContent, loading, empty, iddle, typingSearch
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
    lazy var suggestionsController: SuggestionsViewController = {
        let vc = SuggestionsViewController()
        vc.onSuggestionSelected = self.onSuggestionSelected
        return vc
    }()

    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.searchBarStyle = .prominent
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.delegate = self
        search.searchBar.placeholder = "Buscar en Mercadolibre"
        return search
    }()

    lazy var emptyStateView: UIView = {
        let nib = UINib(nibName: "EmptySearchResultsView", bundle: nil)
        let backgroundView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()

    private var isGrid: Bool = false

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        self.navigationItem.searchController = searchController
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

    private func renderStatus(_ status: Status) {
        switch status {
        case .loading:
            showSpinner()
            hideSuggestions()
        case .loadedContent:
            hideSpinner()
            collectionView.isHidden = false
            hideEmptyState()
        case .empty:
            hideSpinner()
            collectionView.isHidden = true
            showEmptyState()
        case .iddle:
            hideSpinner()
            hideEmptyState()
            hideSuggestions()
            collectionView.isHidden = false
        case .typingSearch:
            hideSpinner()
            collectionView.isHidden = true
            hideEmptyState()
            showSuggestions()

        }
    }

    // MARK: - Actions

    private func onSuggestionSelected(_ suggestion: Suggestion) {
        search(suggestion.suggestedQuery)
        searchController.searchBar.endEditing(true)

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

    // MARK: - Helpers
    private func search(_ string: String) {
        renderStatus(.loading)
        viewModel.search(string, completion: { newItems in
            self.renderStatus(newItems.isEmpty ? .empty : .loadedContent)
            self.collectionView.setContentOffset(.zero, animated: true)
            self.collectionView.reloadData()
            self.collectionView.backgroundView = nil
        })

    }

    private func showSuggestions() {
        addChild(suggestionsController)
        suggestionsController.view.frame = view.frame
        view.addSubview(suggestionsController.view)
        view.bringSubviewToFront(suggestionsController.view)
        suggestionsController.didMove(toParent: self)
    }

    private func hideSuggestions() {
        suggestionsController.willMove(toParent: nil)
        suggestionsController.view.removeFromSuperview()
        suggestionsController.removeFromParent()
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

    func handleNetworkError(_ error: Error) {
        ToastManager.sharedInstance.queue(toast: "Oops algo and mal, intentalo luego")
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let queryString = searchBar.text else {
            return
        }

        search(queryString)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        renderStatus(.iddle)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        renderStatus(.typingSearch)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        suggestionsController.viewModel.query = searchText
        suggestionsController.viewModel.getSuggestions()
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
