![GitHub Logo](/resources/header.png)

`xcsummary` is a macOS command line tool that parses `xcbodebuild` test results and generates html output with activity screenshots. We use it as a part of our CI Server and find it very useful and helpful. We'd like to share it.

## Usage

As easy as pie:
```shell
build/xcsummary -r <path to result folder> // Example build/xcsummary -r build_reports/results
```

or simply launch the Xcode project and hit cmd+r
