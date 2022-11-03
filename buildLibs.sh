cd allwpilib
./gradlew :ntcoreffi:build
cd ..

FILE=$(find ./allwpilib/ntcoreffi/build/libs/ntcoreffi/shared/*/release \( -name "libntcoreffi.dylib" -o -name "libntcoreffi.o" \) -print)

echo $FILE

cp $FILE ./libs