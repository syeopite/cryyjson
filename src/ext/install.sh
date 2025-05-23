#!/bin/sh

git clone "https://github.com/ibireme/yyjson"

cd yyjson

git checkout 9e24d6bcead647231f81173cc5c6bb6c097c00e4

# Export inline functions
cp ../yyjson_ext.c src

sed -i -e 's/yyjson.h/yyjson_ext.c/g' CMakeLists.txt

cmake -B build
cmake --build build

cp build/libyyjson.a ../
