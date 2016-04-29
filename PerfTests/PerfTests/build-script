#!/bin/sh

mkdir -p build/lib
mkdir -p build/Resources

swiftc -emit-library -emit-module -module-name Diff ../../Sources/* -Xlinker -install_name -Xlinker @rpath/libDiff.dylib -o ./build/lib/libDiff.dylib -g
swiftc ./main.swift ../Utils/PerformanceTestUtils.swift -o ./build/main -module-link-name Diff -I "./build/lib/" -L "./build/lib" -Xlinker -rpath -Xlinker @loader_path/lib -Xlinker -lDiff -g

cp ../Utils/Resources/* ./build/Resources/
