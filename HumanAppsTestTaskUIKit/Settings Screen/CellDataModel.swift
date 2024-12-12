enum CellType {
    case title
    case titleSubtitle
    case titleSwitch
}

struct CellData {
    let title: String
    let subtitle: String?
    let type: CellType
}

var data: [CellData] = [
    CellData(title: "Title", subtitle: nil, type: .title),
    CellData(title: "Title", subtitle: "Some text", type: .titleSubtitle),
    CellData(title: "Title", subtitle: nil, type: .titleSwitch)
]

