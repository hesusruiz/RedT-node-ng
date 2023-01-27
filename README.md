<!-- vscode-markdown-toc -->
* 1. [Installation & configuration](#Installationconfiguration)
	* 1.1. [Setting some configuration parameters](#Settingsomeconfigurationparameters)
	* 1.2. [First-time initialization](#First-timeinitialization)
		* 1.2.1. [Generate nodekey and enode address](#Generatenodekeyandenodeaddress)
		* 1.2.2. [Testing that your node starts](#Testingthatyournodestarts)
		* 1.2.3. [Permissioning](#Permissioning)
	* 1.3. [Upgrading the version of Geth](#UpgradingtheversionofGeth)
	* 1.4. [Updating the list of permissioned nodes](#Updatingthelistofpermissionednodes)
	* 1.5. [ Quick Guide for Docker compose](#QuickGuideforDockercompose)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


# Alastria Node for Alastria RedT Network
Alastria RedT node running Quorum Geth 22.7.4

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Slack Status](https://img.shields.io/badge/slack-join_chat-white.svg?logo=slack)](https://alastria.slack.com/)



##  1. <a name='Installationconfiguration'></a>Installation & configuration

The first step it to clone or download the repository to the machine where you want to install and operate the Red T node and enter into the cloned directory.

```bash
$ git clone git@github.com:hesusruiz/RedT-node-ng.git
$ cd RedT-node-ng
```

The structure of the directory is the following:

```bash
├── bin
│   ├── geth
│   └── newnodekey
├── config
│   ├── start_geth.sh
│   └── permissioned-nodes.json
├── data_dir <created only after starting Geth for the first time>
│   ├── geth
│   │   └── <contents of the blockchain database>
│   ├── keystore
│   │   └── <normally empty, unless you manage wallet accounts in the node>
│   ├── permissioned-nodes.json <copy of the file in config directory>
│   └── static-nodes.json <copy of the file in config directory>
├── secrets
│   └── nodekey
├── compose.yaml
├── Dockerfile
├── LICENSE
└── README.md
```

The `bin` directory has two pre-built binaries for Linux that you have to make sure they are executable:

```bash
$ chmod +x bin/geth
$ chmod +x bin/newnodekey
```

The `config` directory has two files:

- `start_geth.sh` is the shell script that sets some parameters that will be used in the command line of `geth` and finally starts the `geth` executable.

- `permissioned-nodes.json` is a JSON file with the public addresses of the other relevant nodes in the network. If your node is a regular node, this list is the list of boot nodes, a set of nodes run voluntarily by some entities participating in the network that help bootstrap the p2p connectivity of regular nodes. Given the nature of the Ethereum p2p layer, a node does not have to connect directly to all other nodes in the network, and instead the messages are propagated across the whole network using an epidemic protocol that provides full reachability. Of course, the administrator of one node can decide not to accept connections from some other nodes. 

The `data_dir` directory contains essentially the databases and keystore. The location is specified in the `start_geth.sh` file because it changes the default location from Ethereum.

The `secrets` directory contains the `nodekey` file with the private key of the node, representing the Ethereum identity of the node. The `secrets`` directory and the `nodekey` file have to be considered sensitive material and managed as a server private key. Anybody with the `nodekey` can impersonate as your node.

`compose.yaml` and `Dockerfile` are the Docker files to run the node as a container.

###  1.1. <a name='Settingsomeconfigurationparameters'></a>Setting some configuration parameters

The configuration parameters are defined in the `config/start_geth.sh` shell script, which it is the one that starts the `geth` executable inside the container.

The most important parameter (and probably the only one you may need to modify) is the `NODE_NAME` to set the public name of your node. The name SHOULD follow the convention:

    REG_XX_T_Y_Z_NN

Where XX is your company/entity name, Y is the number of processors of the machine, Z is the amount of memory in Gb and NN is a sequential counter for each machine that you may have (starting at 00). For example:

    NODE_NAME="REG_IN2_T_2_8_00"

This is the name that will appear in the public listings of nodes of the network. It does not have any other usage.

The `config/start_geth.sh` file sets some other parameters. The file is commented so you can understand the purpose of each parameter.

###  1.2. <a name='First-timeinitialization'></a>First-time initialization

**Warning: do this only the first time you configure a new node. The resulting `nodekey` file is the private key representing the cryptographic identity of your node and should be the same for the whole life of the node. You should also make a safe backup of the file just in case**

####  1.2.1. <a name='Generatenodekeyandenodeaddress'></a>Generate nodekey and enode address

Generate a new `nodekey` and get the associated `enode` by running the `newnodekey` executable:

```bash
$ bin/newnodekey
nodekey: a6f806e7dbd582a53da4632746c4897806dd45c07204bc97203c47b385f58f02
enode: 341d5a3f63295e83764c8743dd2a01cdcc18871f258d8e13a8838dc90cddf3aec6fd28ca661286ddb569e98d8fbf08d548ef2a9ab46baa4d233fb2ff5a43ab7b
```

You should modify the contents of the `secrets/nodekey` file with the hex string for `nodekey` exactly as displayed.

**Warning: do not use the nodekey provided as an example. You should create your own individual private key, because this is a private key and should be treated exactly like one.**

Make a copy of the value displayed in `enode`. It is the public key associated to the private key and it will be needed to create the `enode` (essentially the public address of your node) and perform the permissioning in the RedT network.

####  1.2.2. <a name='Testingthatyournodestarts'></a>Testing that your node starts

We will test that everything is correct with the configuration. However, your node is not yet permissioned so it will not be able to connect to the network yet. Permissioning is described below.

In the root directory of the repository (where the file `compose.yml` is located) run:

```bash
$ docker compose up -d
```

The command runs the service in the background, and you can check its activity by running:
  
```bash
$ docker compose logs -f --tail=20
```

Note: the repository includes a set of helper scripts to facilitate some common tasks. As an alternative to the above, you can run:

```bash
$ ./logs.sh
```

You should see the node initializing and starting to try to contact peers. However, the node is not yet permissioned, so it can not participate in the blockchain network yet.

####  1.2.3. <a name='Permissioning'></a>Permissioning

In order to perform permissioning, follow these steps:

Get the external IP address of your node, as seen from the external world. This is the address that all the other nodes will see when running the Ethereum p2p protocol.

Create the full enode address (the external address of your node in Ethereum terms) as:

    enode://xxxx@external_IP:21000?discport=0

Where

- **xxxx** is the value of `enode` that you obtained when running the `newnodekey` executable.

- **external_IP** is the external IP of your node.

With that value, you can request to be permissioned and then you will see that your node starts connecting to its peers and starts synchronizing the blockchain. The process of synchronization can take hours or even one or two days depending on the speed of your network and machine.

To ask for permission you must enter your data in this [electronic form](https://forms.gle/BiRqqgg2V7zbxF3c7), providing these information of your node: 

**1. ENODE:** String ENODE from ENODE_ADDRESS (enode://ENODE@IP:21000?discport=0)

**2. Public IP:** The external IP of your node.

**3. System details:** Hosting provider, number of cores (vCPUs), RAM Memory and Hard disk size.

You can use the standard docker-compose commands to manage your node. For example, to stop the node:

```bash
$ docker compose down
```

To restart the node:

```bash
$ docker compose restart
```

###  1.3. <a name='UpgradingtheversionofGeth'></a>Upgrading the version of Geth

You can have the latest version of Geth for the Alastria RedT network simply by running the following:

Stop the node:

```bash
$ docker compose down
```

Upgrade the binaries in the `bin` subdirectory:

```bash
$ ./updategeth.sh
```

After the command runs, you should see a message with the version of Geth that has been installed.

Start again the node:

```bash
$ docker compose up -d
```

You can check that it starts properly by looking at the logs:

```bash
$ ./logs.sh
```

###  1.4. <a name='Updatingthelistofpermissionednodes'></a>Updating the list of permissioned nodes

Periodically (e.g., every week) you should do this in order to have the latest list of boot nodes so your node will not have any problem with connectivity to the network.

```bash
$ ./updateperm.sh
```

And restart the node to pick the changes:

```bash
$ docker compose restart
```


###  1.5. <a name='QuickGuideforDockercompose'></a> Quick Guide for Docker compose

[Docker-compose](https://docs.docker.com/compose/)
