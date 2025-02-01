import SwiftUI
import WebKit

struct RichTextWebView: UIViewRepresentable {
    @Binding var htmlContent: String
    
    @EnvironmentObject var editorModel: EditorModel

    func makeUIView(context: Context) -> RichEditorWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        let webView = RichEditorWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "selectionHandler") // Listen for selection updates

        if let fontPath = Bundle.main.path(forResource: "BowlbyOne-Regular", ofType: "ttf") {
            let fontURL = URL(fileURLWithPath: fontPath)
            let baseURL = fontURL.deletingLastPathComponent()

            // Load HTML with base URL (so the font is accessible)
            webView.loadHTMLString(htmlTemplate(with: htmlContent, globalFont: editorModel.globalFont.name, globalFontSize: editorModel.globalFontSize), baseURL: baseURL)
        } else {
            webView.loadHTMLString(htmlTemplate(with: htmlContent, globalFont: editorModel.globalFont.name, globalFontSize: editorModel.globalFontSize), baseURL: nil)
        }
        
        return webView
    }

    func updateUIView(_ webView: RichEditorWebView, context: Context) {
        print("view updated")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: RichTextWebView

        init(_ parent: RichTextWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "selectionHandler", let isTextSelected = message.body as? Bool {
                DispatchQueue.main.async {
                    self.parent.editorModel.isTextSelected = isTextSelected
                    print("text is selected \(isTextSelected)")
                }
            }
        }
    }

    // Generate the HTML structure with CSS for scrolling
    private func htmlTemplate(with content: String, globalFont: String, globalFontSize: CGFloat) -> String {
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                   @font-face {
                        font-family: 'BowlbyOne-Regular';
                        src: url('BowlbyOne-Regular.ttf');
                    }
                    @font-face {
                        font-family: 'SpaceGrotesk-Bold';
                        src: url('SpaceGrotesk-Bold.ttf');
                    }
                    @font-face {
                        font-family: 'SpaceGrotesk-Light';
                        src: url('SpaceGrotesk-Light.ttf');
                    }
                    @font-face {
                        font-family: 'SpaceGrotesk-Medium';
                        src: url('SpaceGrotesk-Medium.ttf');
                    }
                    @font-face {
                        font-family: 'SpaceGrotesk-Regular';
                        src: url('SpaceGrotesk-Regular.ttf');
                    }
                    @font-face {
                        font-family: 'SpaceGrotesk-SemiBold';
                        src: url('SpaceGrotesk-SemiBold.ttf');
                    }

                body {
                    background-color: #F4F2EA;
                    border-style: none;
                    margin: 0;
                    padding: 0;
                    height: 100%;
                }

                #editor {
                    min-height: 100vh;
                    outline: none;
                    padding: 10px;
                    overflow-y: auto;
                    white-space: pre-wrap;
                    font-size: \(globalFontSize)px;
                    font-family: '\(globalFont)', sans-serif;
                    color: #333;
                }
        
                /* Style the checkbox */
                .custom-checkbox {
                    appearance: none;
                    width: 20px;
                    height: 20px;
                    border: 2px solid #333;
                    border-radius: 50%; /* Make it rounded */
                    display: inline-block;
                    position: relative;
                    cursor: pointer;
                    margin-right: 8px;
                    vertical-align: middle;
                }

                .custom-checkbox:checked {
                    background-color: #333;
                }

                .custom-checkbox:checked::after {
                    font-size: 16px;
                    color: white;
                    position: absolute;
                    top: 2px;
                    left: 4px;
                }

                /* Task list styling */
                .task-item {
                    display: flex;
                    align-items: center;
                    margin-bottom: 5px;
                }
        
                /* Image Styling */
                .editor-image {
                    max-width: 75%;
                    height: auto;
                    border-radius: 8px;
                    margin: 10px 0;
                    display: block;
                }

                /* File Link Styling */
                .editor-file {
                    color: #007AFF;
                    text-decoration: none;
                    display: block;
                    margin: 10px 0;
                    font-weight: bold;
                }
            </style>
            <script>
        
                function insertImage(url) {
                    var selection = window.getSelection();
                    if (!selection.rangeCount) return;

                    var range = selection.getRangeAt(0);
                    var img = document.createElement("img");
                    img.src = url;
                    img.className = "editor-image";

                    range.insertNode(img);
                    range.collapse(false);
                }

                function insertFile(url, filename) {
                    var selection = window.getSelection();
                    if (!selection.rangeCount) return;

                    var range = selection.getRangeAt(0);
                    var link = document.createElement("a");
                    link.href = url;
                    link.className = "editor-file";
                    link.textContent = filename;
                    link.target = "_blank";

                    range.insertNode(link);
                    range.collapse(false);
                }
                
                function changeGlobalFont(fontName, fontSize) {
                    document.getElementById('editor').style.fontFamily = fontName;
                    document.getElementById('editor').style.fontSize = fontSize + 'px';
                }
        
                function changeSelectedTextFont(fontName, fontSize) {
                    var selection = window.getSelection();
                    if (!selection.rangeCount) return;

                    var range = selection.getRangeAt(0);
                    var selectedText = range.extractContents(); // Extract current text

                    var span = document.createElement("span");
                    span.style.fontFamily = fontName;
                    span.style.fontSize = fontSize + 'px';

                    span.appendChild(selectedText);
                    range.insertNode(span);

                    selection.removeAllRanges(); // Reapply selection
                    var newRange = document.createRange();
                    newRange.selectNodeContents(span);
                    selection.addRange(newRange);
                }
                
                function checkSelection() {
                    var selection = window.getSelection();
                    if (selection.rangeCount > 0 && selection.toString().length > 0) {
                        window.webkit.messageHandlers.selectionHandler.postMessage(true);
                    } else {
                        window.webkit.messageHandlers.selectionHandler.postMessage(false);
                    }
                }

                function applyOrderedList() {
                    document.execCommand('insertOrderedList', false, null);
                }

                function applyUnorderedList() {
                    document.execCommand('insertUnorderedList', false, null);
                }
        
                function insertCheckbox() {
                    var selection = window.getSelection();
                    if (!selection.rangeCount) return;

                    var range = selection.getRangeAt(0);
                    var node = range.startContainer;

                    // Find the start of the current line
                    while (node.nodeType !== Node.ELEMENT_NODE && node.previousSibling) {
                        node = node.previousSibling;
                    }

                    // Create checkbox element
                    var checkbox = document.createElement("input");
                    checkbox.type = "checkbox";
                    checkbox.className = "custom-checkbox";

                    // Check if we're at the start of the line
                    if (node.nodeType === Node.TEXT_NODE) {
                        var text = node.nodeValue.trim();
                        if (text.length > 0) {
                            // If there is already text, insert before it
                            var parent = node.parentNode;
                            parent.insertBefore(checkbox, node);
                        } else {
                            // If it's an empty line, replace with checkbox
                            node.nodeValue = "";
                            range.insertNode(checkbox);
                        }
                    } else {
                        // If not a text node, just insert the checkbox at the selection
                        range.insertNode(checkbox);
                    }

                    range.collapse(false); // Move cursor after checkbox
                }
        
                document.addEventListener("selectionchange", checkSelection);
            </script>
        </head>
        <body>
            <div id="editor" contenteditable="true">\(content)</div>
        </body>
        </html>
        """
    }
}

class RichEditorWebView: WKWebView {

    var accessoryView: UIView?

    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let fontButton = UIBarButtonItem(
            image: UIImage(systemName: "textformat.alt"),
            style: .plain,
            target: self,
            action: #selector(showFontMenu)
        )
        let listButton = UIBarButtonItem(
            image: UIImage(systemName: "list.triangle"),
            style: .plain,
            target: self,
            action: #selector(showListMenu)
        )
        let mediaButton = UIBarButtonItem(
            image: UIImage(systemName: "paperclip"),
            style: .plain,
            target: self,
            action: #selector(showMediaMenu)
        )
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            image: UIImage(systemName: "keyboard.chevron.compact.down"),
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )

        toolbar.items = [
            flexibleSpace,
            fontButton,
            flexibleSpace,
            listButton,
            flexibleSpace,
            mediaButton,
            flexibleSpace,
            doneButton,
            flexibleSpace
        ]
        self.accessoryView = toolbar
        return accessoryView
    }
    
    @objc private func showFontMenu() {
        NotificationCenter.default.post(name: NSNotification.Name("OpenFontMenu"),
                                        object: nil)
    }
    
    @objc private func showListMenu() {
        NotificationCenter.default.post(name: NSNotification.Name("OpenListMenu"),
                                        object: nil)
    }
    
    @objc private func showMediaMenu() {
        NotificationCenter.default.post(name: NSNotification.Name("OpenMediaMenu"),
                                        object: nil)
    }

    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
