##
export SOLACE_USER=${SOLACE_USER:-'someaccount'}
export SOLACE_USER_PASSWORD=${SOLACE_USER_PASSWORD:-'somepassword'}
export DOWNLOAD_FILE_PATH=${DOWNLOAD_FILE_PATH:-"/products/2.2GA/PCF/Current/2.2.1/documentation.html"}
export ACCEPT_LICENSE=1

./downloadLicensedSolaceProduct.sh
