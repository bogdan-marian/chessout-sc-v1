PROJECT="${PWD}"
ALICE="${PROJECT}/wallets/users/alice.pem"
BOGDAN="${PROJECT}/wallets/users/testnet-bogdan.pem"
ADDRESS=$(erdpy data load --key=address-devnet)
DEPLOY_TRANSACTION=$(erdpy data load --key=deployTransaction-devnet)
PROXY=https://devnet-gateway.elrond.com
CHAINID=D
MY_LOGS="interaction-logs"

MINT_COST_VAL=$(echo '0.05*(10^18)' | bc)
# 50000000000000000 = (0.05 EGLD)
# MINT_COST_VAL=50000000000000000
MINT_COST=$(echo $MINT_COST_VAL | awk -F "." '{print $1}')
TOKEN_NAME="TEST001xToken"
TOKEN_NAME_HEX=$(echo -n ${TOKEN_NAME} | xxd -p)
TOKEN_REVERSE=$(xxd -r -p <<<"$TOKEN_NAME_HEX")
TOKEN_TICKER="TEST001"
TOKEN_TICKER_HEX=$(echo -n ${TOKEN_TICKER} | xxd -p)
ISSUE_TOKEN_ARGUMENTS="0x${TOKEN_NAME_HEX} 0x${TOKEN_TICKER_HEX}"

GAS_LIMIT="60000000"
GAS_SMALL="50000000"
DEPLOY_GAS="65000000"

listArgValues() {
  echo "${MINT_COST}"
  echo "${MINT_COST_HEX}"
  echo "${TOKEN_NAME}"
  echo "${TOKEN_NAME_HEX}"
  echo "${TOKEN_REVERSE}"
  echo "${ISSUE_TOKEN_ARGUMENTS}"
  echo "Wallet used = ${ALICE}"
  echo "Contract Address = ${ADDRESS}"
}

deploy() {
  erdpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} \
    --gas-limit=${DEPLOY_GAS} --send --outfile="${MY_LOGS}/deploy-devnet.interaction.json" \
    --proxy=${PROXY} --chain=${CHAINID} || return

  TRANSACTION=$(erdpy data parse --file="${MY_LOGS}/deploy-devnet.interaction.json" --expression="data['emitted_tx']['hash']")
  ADDRESS=$(erdpy data parse --file="${MY_LOGS}/deploy-devnet.interaction.json" --expression="data['emitted_tx']['address']")

  erdpy data store --key=address-devnet --value=${ADDRESS}
  erdpy data store --key=deployTransaction-devnet --value=${TRANSACTION}

  echo ""
  echo "Smart contract address: ${ADDRESS}"
}

issueToken() {
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=60000000 --function="issueToken" \
    --value ${MINT_COST} \
    --arguments ${ISSUE_TOKEN_ARGUMENTS} \
    --proxy=${PROXY} --chain=${CHAINID} --send \
    --outfile="${MY_LOGS}/issueToken.json"
}

setLocalRoles(){
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} \
    --gas-limit=60000000 --function="setLocalRoles" \
    --proxy=${PROXY} --chain=${CHAINID} --send\
    --outfile="${MY_LOGS}/setLocalRoles.json"
}

getTokenIdSimple() {
  erdpy --verbose contract query ${ADDRESS} --function="getTokenId" \
    --proxy=${PROXY}
}

createNft() {
  CURRENT_TIME="$(echo -n $(date +%s))"
  NFT_NAME=$(echo -n "NFT-${CURRENT_TIME}")
  NFT_NAME_HEX=$(echo -n ${NFT_NAME} | xxd -p)
  ROYALTIES="5000"
  NFT_URL="www.mycoolnft.com/${NFT_NAME}"
  #NFT_URL_HEX=$(echo -n "${NFT_URL}" | xxd -p)
  NFT_URL_HEX=$(echo -n "${NFT_URL}" | xxd -p)
  NFT_URL_HEX_FIX=$(echo -n ${NFT_URL_HEX} | awk '{print $1}')
  echo ${NFT_URL_HEX}
  SELLING_PRICE="7"
  CREATE_ARGS="0x${NFT_NAME_HEX} ${ROYALTIES} 0x${NFT_URL_HEX_FIX} ${SELLING_PRICE}"

  erdpy --verbose contract call ${ADDRESS} \
  --recall-nonce --pem=${ALICE} --gas-limit=${GAS_SMALL} \
  --function="createNft" \
  --arguments ${CREATE_ARGS} \
  --proxy=${PROXY} --chain=${CHAINID} --send \
  --outfile="${MY_LOGS}/createNft.json"
}

getNftPrice(){
  NFT_NONCE="3"
  erdpy --verbose contract query ${ADDRESS} --function="getNftPrice" \
    --arguments ${NFT_NONCE} \
    --proxy=${PROXY}
}

buyNft(){
  NFT_PRICE="1"
  NFT_NONCE="1"
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOGDAN} --gas-limit=${GAS_SMALL} \
    --function="buyNft" \
    --value ${NFT_PRICE} \
    --arguments ${NFT_NONCE} \
    --proxy=${PROXY} --chain=${CHAINID} --send \
    --outfile="${MY_LOGS}/buyNft.json"
}

getTokenId() {
  erdpy --verbose contract query ${ADDRESS} --function="getTokenId" \
    --proxy=${PROXY} \
    | tee "${MY_LOGS}/getTokenId.json"  `# log to file and also to standard out`\
    | grep hex                          `# select the hex line`\
    | awk -F "\"" '{print$4}'           `# split by quotation char`\
    | xxd -r -p                         `# convert from hex to string`\
    | tee "${MY_LOGS}/getTokenId.txt";  `# log to file and also to standard out`\
    echo ""
}
