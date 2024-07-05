git clone "https://github.com/ibireme/yyjson"

cd yyjson

git checkout 3367c2a9844a33b282bdfacee5f976c4c783ad50

# Export inline functions
cp ../yyjson_ext.c src

sed -i -e 's/yyjson.h/yyjson_ext.c/g' CMakeLists.txt

cmake -B build
cmake --build build

cp build/libyyjson.a ../
