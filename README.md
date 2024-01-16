# Cloudsecure helper tools - illumio.cloudsecure  


- [Overview](#overview)
- [Contents](#contents)
    - [Scripts](#modules)
- [Installation](#installation)
    - [Requirements](#requirements)
    - [Ansible Galaxy](#ansible-galaxy)
- [Usage](#usage)
    - [Using illumio scripts](#using-illumio-scripts)
- [Support](#support)
- [Contributing](#contributing)
- [License](#license)

## Overview  

This repository contains the customer helper scripts for `illumio.cloudsecure`.  

The scripts here provides customer a way to scan their cloud objects in AWS and Azure. Scripts use CLI provided by AWS and Azure.
## Contents  

### Scripts  

- [get-aws-inventory](get-aws-inventory.sh)
- [get-azure-inventory](get-azure-inventory.ps)

### Requirements  

Customer should have all AWS account information in .aws/config and .aws/credentials, as required to run aws cofigure.

```
export AWS_CONFIG_PATH=~./aws
```

For using Azure script, please login to your Azure account:

```
az login
```

## Usage  

### Using cripts 
For AWS run below
```sh
./get-aws-inventory.sh
```
For Azure run below
```sh
./get-azure-inventory.ps
```

## Support  

The `illumio.cloudsecure` collection is released and distributed as open source software subject to the included [LICENSE](LICENSE). Illumio has no obligation or responsibility related to the package with respect to support, maintenance, availability, security or otherwise. Please read the entire [LICENSE](LICENSE) for additional information regarding the permissions and limitations. Support is offered on a best-effort basis through the [Illumio Cloudsecure team](mailto:cloudsecure@illumio.com) and project contributors.  

## Contributing  

See the project's [CONTRIBUTING](.github/CONTRIBUTING.md) document for details.  

## License  

Copyright 2022 Illumio  

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
