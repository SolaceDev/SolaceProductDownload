
export SHA256SUM_CMD=$( which sha256sum || which gsha256sum )
export MD5SUM_CMD=$( which md5sum || which gmd5sum )

function testDownloadWithMissingLicense() {
  echo "Testing download with missing license"
  failed_dl=$(./downloadLicensedSolaceProduct.sh -u someaccount -p somepassword -d /products/2.2GA/PCF/Current/2.2.1/documentation.html | grep "Accepting the Solace License Agreement is required" | wc -l)
  if [ "$failed_dl" -eq 0 ]; then
    echo "Download license solace product did not fail when missing license agreement acceptance"
    exit 1
  fi
}

function testDownloadWithMissingPassword() {
  echo "Testing download with missing password" 
  failed_dl=$(./downloadLicensedSolaceProduct.sh -u someaccount -d /products/2.2GA/PCF/Current/2.2.1/documentation.html -a | grep "Missing password" | wc -l)
  if [ "$failed_dl" -eq 0 ]; then
    echo "Download license solace product did not fail when missing password"
    exit 1
  fi
}

function testDownloadWithMissingUsername() {
  echo "Testing download with missing username"
  failed_dl=$(./downloadLicensedSolaceProduct.sh -p somepassword -d /products/2.2GA/PCF/Current/2.2.1/documentation.html -a | grep "Missing username" | wc -l)
  if [ "$failed_dl" -eq 0 ]; then
    echo "Download license solace product did not fail when missing username"
    exit 1
  fi
}

function testDownloadWithMissingPath() {
  echo "Testing download with missing path"
  failed_dl=$(./downloadLicensedSolaceProduct.sh -u someaccount -p somepassword -a | grep "Missing download" | wc -l)
  if [ "$failed_dl" -eq 0 ]; then
    echo "Download license solace product did not fail when missing download"
    exit 1
  fi
}
##
function testDownloadWithBadUsernameAndPassword() {
  echo "Testing download with bad username and password"
  failed_dl=$(./downloadLicensedSolaceProduct.sh -u someaccount -p somepassword -d /products/2.2GA/PCF/Current/2.2.1/documentation.html -a | grep FAILED | wc -l)
  if [ "$failed_dl" -eq 0 ]; then
    echo "Download license solace product did not fail when given incorrect username and password"
    exit 1
  fi
}

function testCheckScriptChecksum() {
  echo "Testing config checksum in version of source"
  input="{\"source\":{\"user\":\"testuser\"},\"version\":null}"
  tmpfile=$(mktemp)
  echo $input > $tmpfile
  output=$(./check 2> /dev/null < $tmpfile)
  expected_checksum=$( $SHA256SUM_CMD $tmpfile | awk '{ print $1 }')
  actual_checksum=$(echo "$output" | jq -r '.[0].config_checksum // ""')
  if [ ! "$expected_checksum" == "$actual_checksum" ]; then
    echo "Checksum did not match expected! Expected $expected_checksum got $actual_checksum"
    exit 1
  fi
}

echo
echo "======================="
echo "Testing download script"
echo "======================="
echo

testDownloadWithMissingLicense
testDownloadWithMissingPassword
testDownloadWithMissingUsername
testDownloadWithMissingPath

testDownloadWithBadUsernameAndPassword

echo
echo "===================="
echo "Testing check script"
echo "===================="
echo

testCheckScriptChecksum

echo
echo "================"
echo "All tests passed"
echo "================"
echo
