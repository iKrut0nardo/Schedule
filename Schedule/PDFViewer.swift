import SwiftUI
import WebKit

struct NewsWebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}

struct NewsView: View {
    let urlString = "https://news.bstu.by"
    
    var body: some View {
        VStack {
            Text("Новости БрГТУ")
                .font(.largeTitle)
                .padding()
            NewsWebView(urlString: urlString)
        }
    }
}

