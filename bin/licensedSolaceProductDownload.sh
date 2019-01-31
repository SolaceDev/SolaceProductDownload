#!/bin/bash

## Exit on errors.
set -e

#
### 
#
#
# A Basic scripting to do Solace products downloads that handles:
#
# - Authentication
# - Accepting of Solace License Agreement
# - Downloading of Solace License Agreement
# - Downloading of a product
# - Optional: Validate checksum of a downloaded file ( md5 or sha256 )
#
# All required and optional parameters can be command line arguments or environment variables.
#
#
###

export SCRIPT="$( basename "${BASH_SOURCE[0]}" )"
export SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export SOLACE_PRODUCTS_FORM_URL="https://products.solace.com/#"
export SOLACE_PRODUCTS_DOWNLOAD_URL="https://products.solace.com/"
export SOLACE_PRODUCTS_PDF_LICENSE_URL="$SOLACE_PRODUCTS_DOWNLOAD_URL/Solace-Systems-Software-License-Agreement.pdf"
export SOLACE_PRODUCTS_HTML_LICENSE_URL="http://www.solace.com/license-software"
export COOKIES_FILE=${COOKIES_FILE:-"cookies.txt"}

export SHA256SUM_CMD=$( which sha256sum || which gsha256sum )
export MD5SUM_CMD=$( which md5sum || which gmd5sum )

## Default checksum using md5
export CHECKSUM_CMD=${CHECKSUM_CMD:-$MD5SUM_CMD}

##
# A chance to clean up when done
##
function downloadCleanup {
  if [ -f $COOKIES_FILE ]; then
    rm -f $COOKIES_FILE
  fi
}
trap downloadCleanup EXIT INT TERM HUP

function authenticateAndAcceptSolaceLicenseAgreement() {
 printf "Authenticating as user\t\t\t%s\n" $SOLACE_USER
 export AUTH_RESPONSE=$( curl -s -w '%{http_code}' -X POST -F 'login-submit=1' -F "username=$1" -F "password=$2" -c $COOKIES_FILE $SOLACE_PRODUCTS_FORM_URL )
 printf "Accepting License Agreement\t\t%s\n" $SOLACE_PRODUCTS_PDF_LICENSE_URL
 printf "License Agreement as HTML\t\t%s\n" $SOLACE_PRODUCTS_HTML_LICENSE_URL
 export LICENSE_RESPONSE=$( curl -s -w '%{http_code}' -X POST -b $COOKIES_FILE -F 'license-submit=1' -F 'acceptcheckbox=1' $SOLACE_PRODUCTS_FORM_URL )
}


function downloadProduct() {
  PRODUCT_PATH=$1
  PRODUCT_FILE=$( basename $PRODUCT_PATH )
  export DOWNLOAD_RESPONSE=$( curl -s -w '%{http_code}' -X GET  -b cookies.txt $SOLACE_PRODUCTS_DOWNLOAD_URL/$PRODUCT_PATH -o $PRODUCT_FILE )
  printf "Downloaded\t\t\t\t%s\n" $PRODUCT_FILE
} 

function validateChecksum() {

  PRODUCT_PATH=$1
  PRODUCT_FILE=$( basename $PRODUCT_PATH )
  PRODUCT_CHECKSUM=$2

  if [ -f $PRODUCT_FILE ] && [ -f $PRODUCT_CHECKSUM ] && [ -x $CHECKSUM_CMD ]; then
     printf "Checksum command\t\t\t%s\n" "$CHECKSUM_CMD -c $PRODUCT_CHECKSUM"
     printf "Checksum result:\n"
     $CHECKSUM_CMD -c $PRODUCT_CHECKSUM
  else
     printf "Checksum\t\t\t\t%s\n" "Not validated"
  fi

}

function showUsage() {
    echo
    echo "Usage: $SCRIPT [OPTIONS]"
    echo
    echo "OPTIONS"
    echo "  -h                        Show Command options "
    echo "  -u <username>             Required user name for downloads. or provide \$SOLACE_USER"
    echo "  -p <password>             Required password for downloads. or provide \$SOLACE_USER_PASSWORD"
    echo "  -d <download_file_path>   The download file path. or provide \$DOWNLOAD_FILE_PATH"
    echo "  -a                        Accept the Solace License Agreement upon download. or provide \$ACCEPT_LICENSE=1"
    echo "  -c <checksum_file>        A checksum file produced by md5sum or sha256sum. or provide \$CHECKSUM_FILE"
    echo
}

function showUsageAndExit() {
  showUsage
  echo
  printf "%s\n" "$1"
  echo
  exit 1
}


while getopts "u:p:d:c:ah" arg; do
    case "${arg}" in
        u)
            export SOLACE_USER=$OPTARG
            ;;
        p)
            export SOLACE_USER_PASSWORD=$OPTARG
            ;;
        d)
            export DOWNLOAD_FILE_PATH=$OPTARG
            ;;
        c)
            export CHECKSUM_FILE=$OPTARG
            ;;
        a)
            export ACCEPT_LICENSE=1
            ;;
        h)
            showUsage
            exit 0
            ;;
       \?)
       >&2 echo
       >&2 echo "Invalid option: -$OPTARG" >&2
       >&2 echo
       showUsage
       exit 1
       ;;
    esac
done

if [ -z $SOLACE_USER ]; then
  showUsageAndExit "Missing username, please use -u or \$SOLACE_USER"
fi

if [ -z $SOLACE_USER_PASSWORD ]; then
  showUsageAndExit "Missing password, please use -p or \$SOLACE_USER_PASSWORD"
fi

if [ -z $DOWNLOAD_FILE_PATH ]; then
  showUsageAndExit "Missing download file path, please use -d or \$DOWNLOAD_FILE_PATH"
fi

if [ -z $ACCEPT_LICENSE ]; then
  showUsageAndExit "Accepting the Solace License Agreement is required to download products from Solace. Please use -a or \$ACCEPT_LICENSE=1"
fi

if [ ! -z $CHECKSUM_FILE ] && [ -f $CHECKSUM_FILE ]; then
   SAMPLE_CHECKSUM=$( cat $CHECKSUM_FILE  | awk '{ print $1 }' )
   SAMPLE_CHECKSUM_LEN=${#SAMPLE_CHECKSUM}

   # Determine checksum
   ## MD5SUM
   if [ "$SAMPLE_CHECKSUM_LEN" -eq "32" ]; then
     export CHECKSUM_CMD=$MD5SUM_CMD
   fi
   ## SHA256SUM
   if [ "$SAMPLE_CHECKSUM_LEN" -eq "64" ]; then
     export CHECKSUM_CMD=$SHA256SUM_CMD
   fi
fi

authenticateAndAcceptSolaceLicenseAgreement $SOLACE_USER $SOLACE_USER_PASSWORD
downloadProduct $SOLACE_PRODUCTS_PDF_LICENSE_URL
downloadProduct $DOWNLOAD_FILE_PATH

if [ ! -z $CHECKSUM_FILE ]; then
 validateChecksum $DOWNLOAD_FILE_PATH $CHECKSUM_FILE
fi

