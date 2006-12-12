#!/bin/bash
VERSION=xraylib_v2.4


INSTALL_DIR=$HOME
echo -n "Installation Root Directory? (${INSTALL_DIR}) "
read arg
if [ ! $arg = '' ]; then INSTALL_DIR=$arg; fi

if [ ! -d $INSTALL_DIR ]; then
    echo "Directory $INSTALL_DIR does not exist"
    echo
    exit
fi


if [ -d ${INSTALL_DIR}/.xraylib ]; then
    if [ -e ${INSTALL_DIR}/.xraylib_old ]; then
        rm -fr ${INSTALL_DIR}/.xraylib_old
    fi
    mv ${INSTALL_DIR}/.xraylib ${INSTALL_DIR}/.xraylib_old
fi

if [ ! -d ${INSTALL_DIR}/.${VERSION} ]; then
    mkdir ${INSTALL_DIR}/.${VERSION}
fi

cd src
PYTH_FLAG=1
IDL_FLAG=1
echo
echo 'Do you want to install the command line script (requires python)'
echo -n 'and the python module ([y]/n)? '
read yn
case "$yn" in
  N* | n* ) PYTH_FLAG=0;;
  *) ./make_python.sh;; 
esac

echo -n 'Do you want to install the IDL module ([y]/n)? '
read yn
case "$yn" in
  N* | n* ) IDL_FLAG=0;;
  *) make_idl.sh;;
esac

make_shared.sh

cd ..
echo "Installing files on directory ${INSTALL_DIR}/.${VERSION}/"
cp -r * ${INSTALL_DIR}/.${VERSION}/.
echo
echo "Linking directory ${INSTALL_DIR}/.${VERSION}/"
echo "to directory ${INSTALL_DIR}/.xraylib"
ln -s ${INSTALL_DIR}/.${VERSION} ${INSTALL_DIR}/.xraylib
echo

echo 'If you use the bash shell add the following lines to the file .bashrc'
echo '(or bashrc_private if you use it) in your home directory:'
echo
echo "export XRAYLIB_DIR=${INSTALL_DIR}/.xraylib"
echo 'export PATH=${PATH}:${XRAYLIB_DIR}/bin:'
if [ $PYTH_FLAG -eq 1 ]; then
    echo 'export PYTHONPATH=${PYTHONPATH}:${XRAYLIB_DIR}/bin:'
fi
echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${XRAYLIB_DIR}/lib'
echo 'alias xrl=xraylib'
echo
echo 'If you use the tcsh shell add the following lines to the file .cshrc'
echo '(or cshrc_private if you use it) in your home directory:'
echo
echo "setenv XRAYLIB_DIR ${INSTALL_DIR}/.xraylib"
echo 'setenv PATH ${PATH}:${XRAYLIB_DIR}/bin:'
if [ $PYTH_FLAG -eq 1 ]; then
    echo 'if ( ! $?PYTHONPATH ) setenv PYTHONPATH'
    echo 'setenv PYTHONPATH ${PYTHONPATH}:${XRAYLIB_DIR}/bin:'
fi
echo 'if ( ! $?LD_LIBRARY_PATH) setenv LD_LIBRARY_PATH'
echo 'setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${XRAYLIB_DIR}/lib'
echo 'alias xrl xraylib'
echo








