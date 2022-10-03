format:
	java 																									\
	--add-exports jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED 											\
	--add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED 										\
	--add-exports jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED 										\
	--add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED 										\
	--add-exports jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED 										\
	-jar google-java-format-1.13.0-all-deps.jar -r $(shell find . -type f -name "*.java") 
	flutter format .
	./swiftformat --swiftversion 4.2 --maxwidth 100 ios

install_formatting:
	./install_formatting_tools.sh
