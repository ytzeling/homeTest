
import UIKit

protocol TableViewCellModelProtocol {
    var cellIdentifier: String { get }
    var name: String { get }
    var avatarUrl: String? { get }
    var note: String? { get }
    var seen: Bool { get }
}

extension TableViewCellModelProtocol {
    var hideNote: Bool {
        return note == nil
    }
}

protocol TableViewCellProtocol {
    func populate(with data: TableViewCellModelProtocol)
}

/// Normal cell
///
struct NormalCellModel: TableViewCellModelProtocol {
    
    var cellIdentifier: String = "NormalCell"
    var name: String
    var avatarUrl: String?
    var note: String?
    var seen: Bool

    init(name: String, avatarUrl: String?, note: String?, seen: Bool) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.note = note
        self.seen = seen
    }
}

class NormalCell: BaseCell {
    
    override func populate(with data: TableViewCellModelProtocol) {
        super.populate(with: data)
        if let data = data as? NormalCellModel {
            avatarImageView.loadImage(from: data.avatarUrl, inverted: false)
        }
    }
}


// Inverted

struct InvertedCellModel: TableViewCellModelProtocol {
    var name: String
    
    var avatarUrl: String?
    
    var cellIdentifier: String = "InvertedCell"
    
    var note: String?
    
    var seen: Bool
    
    init(name: String, avatarUrl: String?, note: String?, seen: Bool) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.note = note
        self.seen = seen
    }
}

class InvertedCell: BaseCell {
    override func populate(with data: TableViewCellModelProtocol) {
        super.populate(with: data)
        if let data = data as? InvertedCellModel {
            avatarImageView.loadImage(from: data.avatarUrl, inverted: true)
        }
    }
}

// BaseCell

class BaseCell: UITableViewCell, TableViewCellProtocol {
    
    
    let avatarImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    let detailLabel: UILabel = {
       let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    let noteIcon: UIImageView = {
       let icon = UIImageView(image: UIImage(systemName: "note"))
        return icon
    }()
    
    private let stackview: UIStackView = {
       let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.spacing = 10
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    private let nameStackview: UIStackView = {
       let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.alignment = .leading
        stackview.spacing = 10
        return stackview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(stackview)
        
        stackview.addArrangedSubview(avatarImageView)
        stackview.addArrangedSubview(nameStackview)
        stackview.addArrangedSubview(noteIcon)
        
        nameStackview.addArrangedSubview(usernameLabel)
        nameStackview.addArrangedSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            stackview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            stackview.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            stackview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            stackview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populate(with data: TableViewCellModelProtocol) {
        usernameLabel.text = data.name
        
        detailLabel.text = data.note
        noteIcon.isHidden = data.hideNote
        
        backgroundColor = data.seen ? .lightGray.withAlphaComponent(0.3) : .systemBackground
    }
    
}
