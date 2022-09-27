if [ uname = "Linux" ]
then
    echo "Install for Linux"
    wget https://github.com/nicklockwood/SwiftFormat/releases/download/0.48.18/swiftformat.zip
    unzip swiftformat.zip
    rm swiftformat.zip
    chomd +x swiftformat
else
    echo "Install for MAC"
    wget https://github.com/nicklockwood/SwiftFormat/releases/download/0.48.18/swiftformat_linux.zip
    unzip swiftformat_linux.zip
    rm swiftformat_linux.zip
    chomd +x swiftformat_linux
    mv swiftformat_linux swiftformat
fi

rm google-java-format-1.13.0-all-deps.jar
wget https://github.com/google/google-java-format/releases/download/v1.13.0/google-java-format-1.13.0-all-deps.jar