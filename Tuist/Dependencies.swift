import ProjectDescription

let dependencies = Dependencies(swiftPackageManager: .init([
    .remote(url: "https://github.com/rensbreur/SwiftTUI.git", requirement: .revision("9ae1ac9f2f4070a1186e7f4adafebe9bf1beedff"))
]))
