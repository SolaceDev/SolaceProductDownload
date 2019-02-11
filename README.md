# Solace Product Download
A project that supports automation for downloading products from Solace Products (https://products.solace.com). It does so by providing an implementation of a Concourse resource to perform this download.
## Contents
* [Overview](#overview)
* [Concourse Configurations](#concourse-configurations)
* [Standalone Script](#standalone-script)
* [Development](#development)
* [Contributing](#contributing)
* [Authors](#authors)
* [License](#license)
* [Additional Resources](#additional-resources)
---
## Overview
The SolaceProductDownload implements a Concourse resource. The resource facilitates calling the [downloadLicensedSolaceProduct](bin/downloadLicensedSolaceProduct.sh) script used to download products from Solace. The script can download any product from the [Solace Products domain](https://products.solace.com/).
## Concourse Configurations
SolaceProductDownload can be added to a Concourse pipeline yaml. There are a couple of possible configurations supported.
#### Direct download
```
resource_types:
- name: solace-product-download
  type: docker-image
  source:
    repository: solace/solace-product-download
    tag: latest
  [...]
resource:
- name: solace-tile
  type: solace-product-download
  source:
    username: "solace-product-username"
    password: "solace-product-password"
    filepath: "/products/2.2GA/PCF/Current/2.2.1/solace-pubsub-2.2.1-enterprise.pivotal"
    accept_terms: true
  [...]
jobs:
- name: demo-resource
  plan:
  - get: solace-tile
  - task: my-task
    config:
      inputs:
      - name: solace-tile
  [...]
```
This will create a resourc called `solace-tile` of type `solace-product-download` which is given a path to download the given resource from https://products.solace.com/ as well as Solace product credentials. Furthermore, the accept_terms flag is required to accept the Solace Systems Software License Aggrement found [here](https://products.solace.com/Solace-Systems-Software-License-Agreement.pdf).

#### Pivnet Download
```
- name: solace-product-download
  type: docker-image
  source:
    repository: solace/solace-product-download
    tag: latest
  [...]
resource:
- name: solace-tile
  type: solace-product-download
  source:
    username: "solace-product-username"
    password: "solace-product-password"
    pivnet_token: "<my pivnet token>" # Pivotal Network UAA token found in Settingss
    accept_terms: true
  [...]
jobs:
- name: demo-resource
  plan:
  - get: solace-tile
  - task: my-task
    config:
      inputs:
      - name: solace-tile
  [...]
```
This configuration, instead of downloading a specific product file, will download the latest product as specified by the checksum on the Pivotal Network page for Solace Pubsub+ (https://network.pivotal.io/products/solace-pubsub). This checksum will be interpreted to download the corresponding product from Solace products. Furthermore, the resulting file will be verified using this checksum. Lastly, in addition to agreeing to the Solace Systems Software License Agreement, the accept_terms flag also signifies the user's acceptance of the EULA of Solace Pubsub+ on Pivnet found [here](https://network.pivotal.io/legal_document_agreements/686270) which is required to download the checksum.

## Standalone Script
The [downloadLicensedSolaceProduct](bin/downloadLicensedSolaceProduct.sh) script can be used standalone to automate the download of products from solace. An invocation of the script is as follows
```
downloadLicensedSolaceProduct.sh -u "solace-username" -p "solace-password" -d "/path/of/file-to-download" -a [-c "/path/to/checksumfile"]
```
The username (-u) and password (-p) are credentials for https://product.solace.com/, the download path (-d) is the path relative to https://product.solace.com/ and -a is required to signify acceptance of the solace license agreement found [here](https://products.solace.com/Solace-Systems-Software-License-Agreement.pdf). Optionally, a checksum file can be provided (with -c) to verify the downloaded product.

## Development
The project can be built locally by calling
```
sudo docker build . -t solace/solace-product-download
```
To iterate, this can be pushed to a local or private docker registry. See [Deploying a Registry Server](https://docs.docker.com/registry/deploying/) for more information on local docker registrys.
```
sudo docker tag solace/solace-product-download my.local.docker:port/solace-product-download
sudo docker push my.local.docker:port/solace-product-download
```
If using an insecure docker registry, a Concourse pipeline can be configured as follows to find the development version of solace-product-download
```
resource_types:
- name: solace-tile
  type: docker-image
  source:
    repository: my.local.docker:port/solace-product-download
    tag: latest
    insecure_registries: ["my.local.docker:port"]
```
## Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.
## Authors
See the list of [contributors](graphs/contributors) who participated in this project.
## License
This project is licensed under the Apache License, Version 2.0. - See [LICENSE](LICENSE) file for details
## Additional Resources
For more information about Concourse resources, check out
* https://concourse-ci.org/implementing-resources.html

For more information about Solace, visit
* Solace Homepage https://solace.com
* The Solace Developer Portal website at https://dev.solace.com
* Solace Pubsub+ for PCF https://network.pivotal.io/products/solace-pubsub