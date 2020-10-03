//
//  HTMLGenerator.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import Foundation

class HTMLGenerator {
    var components: [Component] = [
        H2(childs: [Span(childs: [Span(string: "para")], string: "paraa")], string: "Header2"),
        Span(string: "paragraph"),
        HR(),
        H2(childs: [Span(childs: [Span(string: "para")], string: "paraa"), Span(childs: [Span(string: "para")], string: "paraa")], string: "Header2"),
        H2(childs: [Span(childs: [Span(string: "para")], string: "paraa")], string: "Header2"),
        Span(string: "paragraph"),
        HR(),
        H2(childs: [Span(childs: [Span(string: "para")], string: "paraa")], string: "Header2")
    ]
    func generateHTML() -> String {
        let string = """
            <html>
                <head>
                    <meta charset='UTF-8'>
                </head>
                <style>
                    \(HTMLGenerator.style)
                </style>
                <body>
                    \(getComponents())
                </body>
            </html>
            """
        print(string)
        return string
    }
    
    func getComponents() -> String {
        var string: String = ""
        for component in components {
            string.append(component.makeComponent())
            string.append("\n")
        }
        return string
    }
}

extension HTMLGenerator {
    static let style: String =
    """
    body {
        color: #333333;
        text-align: justify;
        font-size: 15px;
        line-height: 1.25em;
        margin-left: 20px;
        margin-right: 20px;
        font-family: 'Optima-Regular', 'PingFangSC-light', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    }

    h2 {
        letter-spacing: 0.1em;
        break-inside: avoid;
        line-height: 1.2;
        margin-top: 4em;
        margin-bottom: 0.5em;
        font-family: inherit;
        font-weight: bold;
        border-left: 5px solid rgb(17, 148, 127);
        padding-top: 7px;
        padding-left: 7px;
    }

    p {
        color: #333333;
        font-weight: 400;
        margin-top: 1em;
        margin-bottom: 0.2em;
    }

    span {
        color: #333333;
        display: block;
        line-height: 2.1;
        letter-spacing: 0px;
    }

    span.hasMargin {
        margin-bottom: 0.5em;
    }

    blockquote {
        background-color: rgb(235, 235, 235);
        border-left: 4px solid lightgray;
        line-height: 2;
        margin-top: 1em;
        margin-bottom: 1em;
        margin-left: 0px;
        margin-right: 0px;
        padding-top: 12.3px;
        padding-bottom: 12.3px;
        padding-left: 10px;
        padding-right: 10px;
    }

    blockquote.quote {
        background-color: none;
        text-align: center;
        font-style: italic;
    }

    strong {
        margin-right: 1px;
        margin-left: 1px;
    }

    .h2Number {
        font-size: 24px;
        font-weight: bolder;
        color:rgb(17, 148, 127);
        display: inline-block;
        /* border-right: 1px solid lightgray; */
        padding-left: 3px;
        padding-right: 5px;
        padding-bottom: 0px;
        padding-top: 0px;
        margin-right: 10px;
    }

    .h2Text {
        font-size: 18px;
        font-weight: bold;
        display: inline-block;
        border-bottom: 2px solid lightgray;
        padding-bottom: 10px;
    }

    img {
        min-width: 100%;
        min-height: 100%;
        align-self: stretch;
        object-fit: cover;
    }

    .image {
        margin-top: 1em;
        margin-bottom: 0.2em;
        min-width: 100%;
        background-color: rgb(17, 148, 127);
        border: 5px solid rgb(17, 148, 127);
    }

    footer {
        font-size: 14px;
        color: gray;
        margin-top: 0px;
        margin-bottom: 8px;
        text-align: center;
    }

    ol, ul {
        padding-left: 0;
        margin-left: 0;
        color: rgb(17, 148, 127);
    }

    .inline {
        display: inline;
    }

    span.quote {
        padding: 20px;
        text-align: center;
        font-style: italic;
        font-weight: bold;
        display: block;
        margin: 0.5em;
    }

    span.credits {
        color: gray;
        font-size: 14px;
        font-weight: lighter;
        text-align: left;
    }

    hr {
        color: lightgray;
    }
    """
}
