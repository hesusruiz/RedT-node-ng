#!/bin/sh

###############################################################################
# LOCAL PARAMETERS FOR YOR NODE. THESE ARE PROBABLY THE ONLY ONES YOU NEED TO MODIFY
# YOU CAN ADAPT THEM FOR YOUR SPECIFIC NEEDS
# HOWEVER, YOU CAN LEAVE THEM AS DEFAULT VALUES EXCEPT WHERE NOTED
###############################################################################

# The identity of the node (will be publicly displayed in Ethstats)
# Should follow the convention (for a Regular node):
# REG_XX_T_Y_Z_NN where
# - XX is your company/entity name,
# - Y is the number of processors of the machine,
# - Z is the amount of memory in Gb and
# - NN is a sequential counter for each machine that you may have (starting at 00).
# For example:
# NODE_NAME="REG_IN2_T_2_8_00"
NODE_NAME="REG_XX_T_Y_Z_NN"

# The type of node. Can be "regular", "validator" or "boot"
NODE_TYPE="regular"

###############################################################################
# GENERAL PARAMETERS FOR REDT
# YOU SHOULD NOT MODIFY THEM UNLESS YOU HAVE A GOOD REASON
###############################################################################

# This is the NETID for Alastria RedT
NETID="83584648538"

# The directory where "live" blockchain data is stored
DATA_DIR="/root/alastria/data_dir"

# The directory where immutable blockchain data resides
# This data is query-only, so you could place it on a different type of storage
# The default location is inside data_dir, but you can uncomment the line below to make it separate,
# so you can easily place it in a separate cheaper storage device (because this is read-only)
# DATA_ANCIENT="/root/alastria/data_ancient"

# The directory where configuration data and some scripts reside
CONFIG_DIR="/root/alastria/config"

# The P2P network listening port. This is how nodes talk to each other
P2P_PORT="21000"

# The timeout for the IBFT protocol execution (inactivity of the proposer)
ISTANBUL_REQUESTTIMEOUT="10000"

# Blockchain sync mode
SYNCMODE="full"

# Cache size in MB
CACHE="4096"

# Blockchain garbage collection mode
GCMODE="full"

# Allow access from applications via HTTP: the JSON-RPC server
ENABLE_RPC="--http"
# The HTTP JSON-RPC network listening address. We are running inside a container so this address is not exposed to the world
RPCADDR="0.0.0.0"
# The port to use for JSONRPC via HTTP
RPCPORT="22000"
# Allowed protocols
RPCAPI="admin,eth,debug,miner,net,txpool,personal,web3,istanbul"

# Allow access from applications via WebSockets: the JSON-RPC server
ENABLE_WS="--ws"
# The WebSockets JSON-RPC network listening address. We are running inside a container so this address is not exposed to the world
WS_ADDR="0.0.0.0"
# The port to use for JSONRPC via WebSockets
WS_PORT="22001"
# Allowed protocols
WS_API="admin,eth,debug,miner,net,txpool,personal,web3,istanbul"

# General logging verbosity: 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail
VERBOSITY="3"

# Per-module verbosity: comma-separated list of <pattern>=<level> (e.g. eth/*=5,p2p=4)
VMODULE="consensus/istanbul/ibft/core/core.go=5"

# Any additional arguments depending on the type of node
if [ $NODE_TYPE = "validator" ]; then
    # These are for a Validator node
    ADDITIONAL_ARGS="--txlookuplimit 1000 --immutabilitythreshold 2000 --cache.database 10 --cache.trie 15 --cache.gc 50 --cache.snapshot 25 --mine --miner.threads $(grep -c processor /proc/cpuinfo)"
fi

# Any additional arguments depending on the type of node
if [ $NODE_TYPE = "regular" ]; then
    # These are for a Regular node
    ADDITIONAL_ARGS="--immutabilitythreshold 2000 --cache.database 10 --cache.trie 15 --cache.gc 50 --cache.snapshot 25"
fi

###############################################################################
# PRIVATE KEY FOR YOUR NODE
# WARNING!!! THIS IS THE PRIVATE KEY THAT THE NODE USES TO PROVE ITS IDENTITY
# AND SIGN MESSAGES AT THE NETWORK LEVEL. THIS IS SENSITIVE MATERIAL AND
# YOU SOULD TREAT IT AS SUCH. DO NOT MIX THE NODES'S PRIVATE KEY WITH PUBLIC
# MATERIAL (E.G., IN BACKUPS) TO AVOID UNINTENDED EXPOSURE AND IMPERSONATION
###############################################################################

# The directory where the private key of the node resides
SECRETS_DIR="/root/alastria/secrets"

PRIVATE_KEY="${SECRETS_DIR}/nodekey"

###############################################################################
###############################################################################

# These are paremeters that have to be added to the command line

GLOBAL_ARGS="--networkid $NETID \
--identity $NODE_NAME \
--datadir ${DATA_DIR} \
--port $P2P_PORT \
--permissioned \
--cache $CACHE \
$ENABLE_RPC \
--http.addr $RPCADDR \
--http.api $RPCAPI \
--http.port $RPCPORT \
$ENABLE_WS \
--ws.addr $WS_ADDR \
--ws.port $WS_PORT \
--ws.api $WS_API \
--istanbul.requesttimeout $ISTANBUL_REQUESTTIMEOUT \
--verbosity $VERBOSITY \
--emitcheckpoints \
--syncmode $SYNCMODE \
--gcmode $GCMODE \
--vmodule $VMODULE \
--nodekey $PRIVATE_KEY \
--nodiscover \
--nousb "

# For compatibility with older versions of geth in the netwoek
COMPATIBILITY_ARGS="--snapshot=false \
--rpc.allow-unprotected-txs "

# Copy (and replace whatever is there) the configuration files to the Geth datadir
# This way, we separate configuration from blockchain data, facilitating administrative tasks
# For example, to create a new node you can just copy the whole data_dir (e.g., with rsync)
# to another machine and start the node with another configuration. This avoids having to
# synchronise the new machine from the beginning.

# Copy the permissioned and static nodes lists
# In the case of RedT they are exactly the same
cp ${CONFIG_DIR}/permissioned-nodes.json ${DATA_DIR}/permissioned-nodes.json
cp ${CONFIG_DIR}/permissioned-nodes.json ${DATA_DIR}/static-nodes.json

# Tell Geth not to use any private transaction configuration
# But you could use Quorum PTM (Private Transaction Manager) if you collaborate with other nodes using it.
export PRIVATE_CONFIG="ignore"

# Run geth with exec, so it replaces the shell and becomes the pid=1 process
# In this way geth will receive signals as if it were executed standalone
echo "Running geth ${GLOBAL_ARGS} ${COMPATIBILITY_ARGS} ${ADDITIONAL_ARGS}"
exec /root/alastria/bin/geth ${GLOBAL_ARGS} ${COMPATIBILITY_ARGS} ${ADDITIONAL_ARGS}
