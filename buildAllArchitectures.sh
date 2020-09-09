#! /bin/sh

# Changed install prefix so multiple install coexist
PREFIX=$PWD
XCFRAMEWORKS_DIR=$PREFIX/Python-aux/
export PATH=$PREFIX/Library/bin:$PATH
export PYTHONPYCACHEPREFIX=$PREFIX/__pycache__
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

# 1) compile for OSX (required)

find . -name \*.o -delete
env CC=clang CXX=clang++ CPPFLAGS="-isysroot $OSX_SDKROOT" CFLAGS="-isysroot $OSX_SDKROOT" CXXFLAGS="-isysroot $OSX_SDKROOT" LDFLAGS="-isysroot $OSX_SDKROOT" LDSHARED="clang -v -undefined error -dynamiclib -isysroot $OSX_SDKROOT -lz -L. -lpython3.9" ./configure --prefix=$PREFIX/Library --with-system-ffi --enable-shared >& configure_osx.log
# enable-framework incompatible with local install
rm -rf build/lib.macosx-10.15-x86_64-3.9
make -j 4 >& make_osx.log
mkdir -p build/lib.macosx-10.15-x86_64-3.9
cp libpython3.9.dylib build/lib.macosx-10.15-x86_64-3.9
make -j 4 install >& make_install_osx.log
# Force reinstall and upgrade of pip, setuptools 
python3.9 -m pip install pip --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install setuptools --upgrade >> make_install_osx.log 2>&1
# Pure-python packages that do not depend on anything, keep latest version:
# These are just patches of setup.py, no need to fork.
# Order of packages: packages dependent on something after the one they depend on
python3.9 -m pip install six --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install html5lib --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install urllib3 --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install webencodings --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install wheel --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install pygments --upgrade >> make_install_osx.log 2>&1
# markupsafe: prevent compilation of extension:
echo Installing MarkupSafe with no extensions >> $PREFIX/make_install_osx.log 2>&1
mkdir -p packages >> $PREFIX/make_install_osx.log 2>&1
pushd packages >> $PREFIX/make_install_osx.log 2>&1
python3.9 -m pip download --no-binary :all: markupsafe >> $PREFIX/make_install_osx.log 2>&1
tar xvzf MarkupSafe*.tar.gz >> $PREFIX/make_install_osx.log 2>&1
rm MarkupSafe*.tar.gz >> $PREFIX/make_install_osx.log 2>&1
pushd MarkupSafe* >> $PREFIX/make_install_osx.log 2>&1
sed -i bak  's/run_setup(True)/run_setup(False)/g' setup.py  >> $PREFIX/make_install_osx.log 2>&1
python3.9 -m pip install . >> $PREFIX/make_install_osx.log 2>&1
popd  >> $PREFIX/make_install_osx.log 2>&1
rm -rf MarkupSafe* >> $PREFIX/make_install_osx.log 2>&1
popd >> $PREFIX/make_install_osx.log 2>&1
echo Done installing MarkupSafe >> make_install_osx.log 2>&1
# end markupsafe 
python3.9 -m pip install jinja2 --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install attrs --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install appnope --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install packaging --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install bleach --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install entrypoints --upgrade >> make_install_osx.log 2>&1
# pyrsistent: prevent compilation of extension:
echo Installing pyrsistent with no extension >> make_install_osx.log 2>&1
pushd packages >> make_install_osx.log 2>&1
python3.9 -m pip download pyrsistent --no-binary :all:  >> $PREFIX/make_install_osx.log 2>&1
tar xvzf pyrsistent*.tar.gz >> $PREFIX/make_install_osx.log 2>&1
rm pyrsistent*.tar.gz >> $PREFIX/make_install_osx.log 2>&1
pushd pyrsistent* >> $PREFIX/make_install_osx.log 2>&1
sed -i bak 's/^if platform.python_implementation/#&/' setup.py  >> $PREFIX/make_install_osx.log 2>&1
sed -i bak 's/^    extensions = /#&/' setup.py  >> $PREFIX/make_install_osx.log 2>&1
python3.9 -m pip install . >> $PREFIX/make_install_osx.log 2>&1
popd  >> $PREFIX/make_install_osx.log 2>&1
rm -rf pyrsistent* >> $PREFIX/make_install_osx.log 2>&1
popd >> $PREFIX/make_install_osx.log 2>&1
echo done installing pyrsistent >> make_install_osx.log 2>&1
# end pyrsistent
python3.9 -m pip install ptyprocess --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install jsonschema --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install mistune --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install traitlets --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install pexpect --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install ipython-genutils --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install jupyter-core --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install nbformat --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install pandocfilters --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install testpath --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install defusedxml --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install nbconvert --upgrade >> make_install_osx.log 2>&1
python3.9 -m pip install python-dateutil --upgrade >> make_install_osx.log 2>&1
# This simple trick prevents tornado from installing extensions:
CC=/bin/false python3.9 -m pip install tornado --upgrade  >> make_install_osx.log 2>&1
python3.9 -m pip install terminado --upgrade >> make_install_osx.log 2>&1
# NB: different from: pure-python packages that I have to edit (use git), 
#                     non-pure python packages (configure and make)
# break here when only installing packages:
# exit 0
# When working on frozen importlib, need to compile twice:
# make regen-importlib >> make_install_osx.log 2>&1
# make >> make_osx.log 2>&1 
# mkdir -p build/lib.macosx-10.15-x86_64-3.9
# cp libpython3.9.dylib build/lib.macosx-10.15-x86_64-3.9
# make install >> make_install_osx.log 2>&1

# 2) compile for iOS:

export PYTHONHOME=$PREFIX/Library
mkdir -p Frameworks_iphoneos
mkdir -p Frameworks_iphoneos/include
mkdir -p Frameworks_iphoneos/lib
cp -r $XCFRAMEWORKS_DIR/libffi.xcframework/ios-arm64/Headers/ffi $PREFIX/Frameworks_iphoneos/include/ffi
cp -r $XCFRAMEWORKS_DIR/libffi.xcframework/ios-arm64/Headers/ffi/* $PREFIX/Frameworks_iphoneos/include/ffi/
cp -r $XCFRAMEWORKS_DIR/crypto.xcframework/ios-arm64/Headers $PREFIX/Frameworks_iphoneos/include/crypto/
cp -r $XCFRAMEWORKS_DIR/openssl.xcframework/ios-arm64/Headers $PREFIX/Frameworks_iphoneos/include/openssl/
# Need to copy all libs after each make clean: 
cp $XCFRAMEWORKS_DIR/crypto.xcframework/ios-arm64/libcrypto.a $PREFIX/Frameworks_iphoneos/lib/
cp $XCFRAMEWORKS_DIR/openssl.xcframework/ios-arm64/libssl.a $PREFIX/Frameworks_iphoneos/lib/
cp $XCFRAMEWORKS_DIR/libffi.xcframework/ios-arm64/libffi.a $PREFIX/Frameworks_iphoneos/lib/
find . -name \*.o -delete
rm -f Programs/_testembed Programs/_freeze_importlib

# preadv / pwritev are iOS 14+ only
env CC=clang CXX=clang++ \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT" \
	CFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT -F$PREFIX/Frameworks_iphoneos -framework ios_system -L$PREFIX/Frameworks_iphoneos/lib" \
	LDSHARED="clang -v -undefined error -dynamiclib -isysroot $IOS_SDKROOT -lz -L. -lpython3.9  -F$PREFIX/Frameworks_iphoneos -framework ios_system -L$PREFIX/Frameworks_iphoneos/lib" \
	PLATFORM=iphoneos \
	./configure --prefix=$PREFIX/Library --enable-shared \
	--host arm-apple-darwin --build x86_64-apple-darwin --enable-ipv6 \
	--with-openssl=$PREFIX/Frameworks_iphoneos \
	--without-computed-gotos \
	with_system_ffi=yes \
	ac_cv_file__dev_ptmx=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_func_getentropy=no \
	ac_cv_func_sendfile=no \
	ac_cv_func_clock_settime=no >& configure_ios.log
# --enable-framework fails with iOS compilers
rm -rf build/lib.darwin-arm64-3.9
make -j 4 >& make_ios.log
mkdir -p  build/lib.darwin-arm64-3.9
cp libpython3.9.dylib build/lib.darwin-arm64-3.9
# Don't install for iOS

# 3) compile for Simulator:

# 3.1) download and install required packages: 
mkdir -p Frameworks_iphonesimulator
mkdir -p Frameworks_iphonesimulator/include
mkdir -p Frameworks_iphonesimulator/lib
cp -r $XCFRAMEWORKS_DIR/libffi.xcframework/ios-x86_64-simulator/Headers/ffi $PREFIX/Frameworks_iphonesimulator/include/ffi
cp -r $XCFRAMEWORKS_DIR/libffi.xcframework/ios-x86_64-simulator/Headers/ffi/* $PREFIX/Frameworks_iphonesimulator/include/ffi/
cp -r $XCFRAMEWORKS_DIR/crypto.xcframework/ios-x86_64-simulator/Headers $PREFIX/Frameworks_iphonesimulator/include/crypto/
cp -r $XCFRAMEWORKS_DIR/openssl.xcframework/ios-x86_64-simulator/Headers $PREFIX/Frameworks_iphonesimulator/include/openssl/
# Need to copy all libs after each make clean: 
cp $XCFRAMEWORKS_DIR/crypto.xcframework/ios-x86_64-simulator/libcrypto.a $PREFIX/Frameworks_iphonesimulator/lib/
cp $XCFRAMEWORKS_DIR/openssl.xcframework/ios-x86_64-simulator/libssl.a $PREFIX/Frameworks_iphonesimulator/lib/
cp $XCFRAMEWORKS_DIR/libffi.xcframework/ios-x86_64-simulator/libffi.a $PREFIX/Frameworks_iphonesimulator/lib/
find . -name \*.o -delete
rm -f Programs/_testembed Programs/_freeze_importlib

# preadv / pwritev are iOS 14+ only
env CC=clang CXX=clang++ \
	CPPFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT" \
	CFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT" \
	CXXFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT" \
	LDFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT -F$PREFIX/Frameworks_iphonesimulator -framework ios_system -L$PREFIX/Frameworks_iphonesimulator/lib" \
	LDSHARED="clang -v -undefined error -dynamiclib -isysroot $SIM_SDKROOT -lz -L. -lpython3.9  -F$PREFIX/Frameworks_iphonesimulator -framework ios_system -L$PREFIX/Frameworks_iphonesimulator/lib" \
	PLATFORM=iphonesimulator \
	./configure --prefix=$PREFIX/Library --enable-shared \
	--host x86_64-apple-darwin --build x86_64-apple-darwin --enable-ipv6 \
	--with-openssl=$PREFIX/Frameworks_iphonesimulator \
	--without-computed-gotos \
	cross_compiling=yes \
	with_system_ffi=yes \
	ac_cv_file__dev_ptmx=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_func_getentropy=no \
	ac_cv_func_sendfile=no \
	ac_cv_func_clock_settime=no >& configure_simulator.log
rm -rf build/lib.darwin-x86_64-3.9
make -j 4 >& make_simulator.log
mkdir -p build/lib.darwin-x86_64-3.9
cp libpython3.9.dylib build/lib.darwin-x86_64-3.9
# Don't install for iOS

# TODO: create frameworks from dynamic libraries & incorporate changes into code.

# Python build finished successfully!
# The necessary bits to build these optional modules were not found:
# _bz2                  _curses               _curses_panel      
# _gdbm                 _lzma                 _tkinter           
# _uuid                 nis                   ossaudiodev        
# readline              spwd                                     
# To find the necessary bits, look in setup.py in detect_modules() for the module's name.
# 
# 
# The following modules found by detect_modules() in setup.py, have been
# built by the Makefile instead, as configured by the Setup files:
# _abc                  atexit                pwd                
# time                                                           


# Questions / todo: 
# - load xcframeworks / move relevant libraries in place
# - merge with ios_system changes 
# - generate multiple frameworks 
# - generate xcframeworks
