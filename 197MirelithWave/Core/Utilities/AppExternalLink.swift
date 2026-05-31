import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://mirelith197wave.site/privacy/225"
    case termsOfService = "https://mirelith197wave.site/terms/225"

    var url: URL? {
        URL(string: rawValue)
    }
}
