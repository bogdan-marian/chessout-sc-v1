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
DEPLOY_GAS="75000000"
BUY_GAS="10000000"
GAS_ISSUE_TOKEN="75000000"

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
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=${GAS_ISSUE_TOKEN} --function="issueToken" \
    --value ${MINT_COST} \
    --arguments ${ISSUE_TOKEN_ARGUMENTS} \
    --proxy=${PROXY} --chain=${CHAINID} --send \
    --outfile="${MY_LOGS}/issueToken.json"
}

getTokenId() {
  erdpy --verbose contract query ${ADDRESS} --function="getTokenId" \
    --proxy=${PROXY} \
    | tee "${MY_LOGS}/getTokenId.json" \
    | grep hex \
    | awk -F "\"" '{print$4}' \
    | xxd -r -p \
    | tee "${MY_LOGS}/getTokenId.txt"; \
    echo ""
}

getTokenIdSimple() {
  erdpy --verbose contract query ${ADDRESS} --function="getTokenId" \
    --proxy=${PROXY}
}

setLocalRoles(){
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} \
    --gas-limit=60000000 --function="setLocalRoles" \
    --proxy=${PROXY} --chain=${CHAINID} --send\
    --outfile="${MY_LOGS}/setLocalRoles.json"
}



createNft() {
  CURRENT_TIME="$(echo -n $(date +%s))"
  NFT_NAME=$(echo -n "NFT-${CURRENT_TIME}")
  NFT_NAME_HEX=$(echo -n ${NFT_NAME} | xxd -p)
  ROYALTIES="5000"
  NFT_URL="www.mycoolnft.com/${NFT_NAME}"
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
  NFT_NONCE="1"
  erdpy --verbose contract query ${ADDRESS} --function="getNftPrice" \
    --arguments ${NFT_NONCE} \
    --proxy=${PROXY}
}

buyNft(){
  NFT_PRICE="7"
  NFT_NONCE="1"
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOGDAN} --gas-limit=${BUY_GAS} \
    --function="buyNft" \
    --value ${NFT_PRICE} \
    --arguments ${NFT_NONCE} \
    --proxy=${PROXY} --chain=${CHAINID} --send \
    --outfile="${MY_LOGS}/buyNft.json"
}



# tournament section

TOURNAMENT_ID="tournament-02"
TOURNAMENT_ID_HEX=$(echo -n ${TOURNAMENT_ID} | xxd -p)
TOKEN_IDENTIFIER="EGLD"
TOKEN_IDENTIFIER_HEX=$(echo -n ${TOKEN_IDENTIFIER} | xxd -p)
SIGN_IN_PRICE="11"
createTournament(){
  CREATE_TOURNAMENT_ARGS="0x${TOURNAMENT_ID_HEX} 0x${TOKEN_IDENTIFIER_HEX} ${SIGN_IN_PRICE}"
  erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOGDAN} --gas-limit=${BUY_GAS} \
      --function="createTournament" \
      --arguments ${CREATE_TOURNAMENT_ARGS} \
      --proxy=${PROXY} --chain=${CHAINID} --send \
      --outfile="${MY_LOGS}/createTournament.json"
}

getTournamentInfo(){
  erdpy --verbose contract query ${ADDRESS} --function="getTournamentInfo" \
  --arguments "0x${TOURNAMENT_ID_HEX}" \
  --proxy=${PROXY}
}

getTournamentInfoList(){
  TOURNAMENT_ID_A="tournament-01"
  TOURNAMENT_ID_A_HEX=$(echo -n ${TOURNAMENT_ID_A} | xxd -p)
  TOURNAMENT_ID_B="tournament-02"
  TOURNAMENT_ID_B_HEX=$(echo -n ${TOURNAMENT_ID_B} | xxd -p)
  GET_TOURANMENT_LIST_ARGS="0x${TOURNAMENT_ID_A_HEX} 0x${TOURNAMENT_ID_B_HEX}"
  echo ${GET_TOURANMENT_LIST_ARGS}
  erdpy --verbose contract query ${ADDRESS} --function="getTournamentInfoList" \
    --arguments "0x${TOURNAMENT_ID_A_HEX}" "0x${TOURNAMENT_ID_B_HEX}" \
    --proxy=${PROXY}
}
