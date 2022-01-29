PROJECT="${PWD}"
ALICE="${PROJECT}/wallets/users/alice.pem"
# ALICE="${PROJECT}/wallets/users/testnet-bogdan.pem"
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
    --gas-limit=60000000 --send --outfile="${MY_LOGS}/deploy-devnet.interaction.json" \
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

getTokenIdSimple() {
  erdpy --verbose contract query ${ADDRESS} --function="getTokenId" \
    --proxy=${PROXY}
}

getTokenId() {
  erdpy --verbose contract query ${ADDRESS} --function="getTokenId" \
    --proxy=${PROXY} \
    | tee "${MY_LOGS}/getTokenId.json"  `# log to file and also to standard out`\
    | grep hex                          `# select the hex line`\
    | awk -F "\"" '{print$4}'           `# split by quotation char`\
    | xxd -r -p                         `# convert from hex to string`\
    | tee "${MY_LOGS}/getTokenId.txt";  `# log to file and also to standard out`\
    echo ""                             `# ad extra new line so the output is on different line the current prompt`
}
