#!/usr/bin/env swift
import Foundation

let fm = FileManager.default
let cwd = URL(fileURLWithPath: fm.currentDirectoryPath)

let sourcesRoot = cwd.appendingPathComponent("IconSources")
let regularDir = sourcesRoot.appendingPathComponent("regular")
let fillDir = sourcesRoot.appendingPathComponent("fill")

let dsRoot = cwd
  .appendingPathComponent("Packages")
  .appendingPathComponent("KeyboardKit")
  .appendingPathComponent("Sources")
  .appendingPathComponent("DesignSystem")

let xcassetsURL = dsRoot
  .appendingPathComponent("Resources")
  .appendingPathComponent("Icons.xcassets")

let generatedSwiftURL = dsRoot
  .appendingPathComponent("Icons")
  .appendingPathComponent("Generated")
  .appendingPathComponent("DSIcon+Generated.swift")

guard fm.fileExists(atPath: regularDir.path), fm.fileExists(atPath: fillDir.path) else {
  FileHandle.standardError.write(Data("error: IconSources/{regular,fill} not found at \(sourcesRoot.path)\n".utf8))
  exit(1)
}

func listSVGNames(_ dir: URL, stripSuffix: String? = nil) -> [String] {
  let files = (try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
  var names: [String] = []
  for url in files where url.pathExtension.lowercased() == "svg" {
    var name = url.deletingPathExtension().lastPathComponent
    if let suffix = stripSuffix, name.hasSuffix(suffix) {
      name = String(name.dropLast(suffix.count))
    }
    names.append(name)
  }
  return names.sorted()
}

let regularNames = listSVGNames(regularDir)
let fillNames = listSVGNames(fillDir, stripSuffix: "-fill")

let regularSet = Set(regularNames)
let fillSet = Set(fillNames)

let allNames = regularSet.union(fillSet).sorted()
print("info: discovered \(regularNames.count) regular, \(fillNames.count) fill, \(allNames.count) unique base icons")

func camelCase(from kebab: String) -> String {
  let parts = kebab.split(separator: "-")
  guard let first = parts.first else { return kebab }
  let head = String(first)
  let tail = parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }
  return ([head] + tail).joined()
}

let swiftReservedWords: Set<String> = [
  "repeat", "return", "class", "switch", "case", "where", "while", "for",
  "if", "else", "true", "false", "nil", "in", "do", "throw", "throws", "try",
  "catch", "guard", "defer", "let", "var", "func", "init", "deinit", "self",
  "super", "import", "operator", "extension", "protocol", "enum", "struct",
  "typealias", "associatedtype", "some", "any", "as", "is", "inout", "static",
  "final", "public", "private", "internal", "fileprivate", "open"
]

func swiftCaseName(_ kebab: String) -> String {
  let camel = camelCase(from: kebab)
  if swiftReservedWords.contains(camel) {
    return "`\(camel)`"
  }
  return camel
}

func writeJSON(_ object: Any, to url: URL) throws {
  let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
  try data.write(to: url, options: .atomic)
}

if fm.fileExists(atPath: xcassetsURL.path) {
  try fm.removeItem(at: xcassetsURL)
}
try fm.createDirectory(at: xcassetsURL, withIntermediateDirectories: true)

try writeJSON([
  "info": ["version": 1, "author": "generate-icons.swift"]
], to: xcassetsURL.appendingPathComponent("Contents.json"))

func writeImageset(name: String, sourceFile: URL, in dir: URL) throws {
  let imagesetURL = dir.appendingPathComponent("\(name).imageset")
  try fm.createDirectory(at: imagesetURL, withIntermediateDirectories: true)

  let dest = imagesetURL.appendingPathComponent("\(name).svg")
  try fm.copyItem(at: sourceFile, to: dest)

  let contents: [String: Any] = [
    "info": ["version": 1, "author": "generate-icons.swift"],
    "images": [
      [
        "filename": "\(name).svg",
        "idiom": "universal"
      ]
    ],
    "properties": [
      "preserves-vector-representation": true,
      "template-rendering-intent": "template"
    ]
  ]
  try writeJSON(contents, to: imagesetURL.appendingPathComponent("Contents.json"))
}

let regularGroupURL = xcassetsURL.appendingPathComponent("Regular")
let fillGroupURL = xcassetsURL.appendingPathComponent("Fill")
try fm.createDirectory(at: regularGroupURL, withIntermediateDirectories: true)
try fm.createDirectory(at: fillGroupURL, withIntermediateDirectories: true)

try writeJSON([
  "info": ["version": 1, "author": "generate-icons.swift"]
], to: regularGroupURL.appendingPathComponent("Contents.json"))

try writeJSON([
  "info": ["version": 1, "author": "generate-icons.swift"]
], to: fillGroupURL.appendingPathComponent("Contents.json"))

var written = 0
for name in regularNames {
  let src = regularDir.appendingPathComponent("\(name).svg")
  try writeImageset(name: name, sourceFile: src, in: regularGroupURL)
  written += 1
}
for name in fillNames {
  let src = fillDir.appendingPathComponent("\(name)-fill.svg")
  try writeImageset(name: "\(name)-fill", sourceFile: src, in: fillGroupURL)
  written += 1
}
print("info: wrote \(written) imagesets")

try? fm.createDirectory(at: generatedSwiftURL.deletingLastPathComponent(), withIntermediateDirectories: true)

var swift = ""
swift += "import Foundation\n\n"
swift += "extension DSIcon {\n"
for name in allNames {
  let caseName = swiftCaseName(name)
  let hasRegular = regularSet.contains(name)
  let hasFill = fillSet.contains(name)
  let weights: String
  switch (hasRegular, hasFill) {
    case (true, true): weights = ".all"
    case (true, false): weights = ".regularOnly"
    case (false, true): weights = ".fillOnly"
    case (false, false): continue
  }
  swift += "  public static let \(caseName) = DSIcon(rawName: \"\(name)\", availableWeights: \(weights))\n"
}
swift += "\n"
swift += "  public static let all: [DSIcon] = [\n"
for name in allNames {
  let caseName = swiftCaseName(name)
  swift += "    .\(caseName),\n"
}
swift += "  ]\n"
swift += "}\n"

try swift.write(to: generatedSwiftURL, atomically: true, encoding: .utf8)
print("info: wrote \(generatedSwiftURL.path)")
print("info: \(allNames.count) icons available as DSIcon static members")
