echo "Cleanup"
rm swiftformat
rm -r __MACOSX
rm google-java-format-1.13.0-all-deps.jar

if [ $(uname) = "Linux" ]
then
    echo "Install for Linux"
    wget https://github.com/nicklockwood/SwiftFormat/releases/download/0.48.18/swiftformat_linux.zip
    unzip swiftformat_linux.zip
    rm swiftformat_linux.zip
    mv swiftformat_linux swiftformat
else
    echo "Install for MAC"
    wget https://github.com/nicklockwood/SwiftFormat/releases/download/0.48.18/swiftformat.zip
    unzip swiftformat.zip
    rm swiftformat.zip
fi
chmod +x swiftformat

wget https://github.com/google/google-java-format/releases/download/v1.13.0/google-java-format-1.13.0-all-deps.jar
