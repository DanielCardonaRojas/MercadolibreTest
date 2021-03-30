//
//  SuggestionsViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import UIKit

class SuggestionsViewController: UIViewController {
    enum Section: Hashable {
        case main
    }

    var onSuggestionSelected: ((Suggestion) -> Void)?

    lazy var viewModel: SuggestionsViewModel  = {
        let vm = SuggestionsViewModel()
        vm.delegate = self
        return vm
    }()

    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        return tv
    }()

    private lazy var diffableDataSource = self.makeDiffableDatasource()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateTableView(suggestions: [])
    }

    private func setupViews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate {
            tableView.relativeTo(view, positioned: .inset(by: 0))
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
    }

    private func makeDiffableDatasource() -> UITableViewDiffableDataSource<Section, Suggestion> {
        let datasource = UITableViewDiffableDataSource<Section, Suggestion>(tableView: tableView) { (tableView, indexpath, suggestion) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexpath)
            cell.textLabel?.text = suggestion.suggestedQuery
            cell.selectionStyle = .none
            return cell
        }

        datasource.defaultRowAnimation = .fade

        return datasource
    }

    private func updateTableView(suggestions: [Suggestion]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Suggestion>()
        snapshot.appendSections([.main])
        snapshot.appendItems(suggestions, toSection: .main)
        diffableDataSource.apply(snapshot)
    }

}

// MARK: - SuggestionsViewModelDelegate
extension SuggestionsViewController: SuggestionsViewModelDelegate {
    func didFetchSuggestions(_ suggestions: [Suggestion]) {
        updateTableView(suggestions: suggestions)
    }
}

// MARK: - TableViewDelegate

extension SuggestionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected suggestion")
        if let suggestion = viewModel.suggestions[safe: indexPath.row] {
            onSuggestionSelected?(suggestion)
        }
    }

}
