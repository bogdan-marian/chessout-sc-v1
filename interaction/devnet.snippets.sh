PROJECT="${PWD}"
# ALICE="${PROJECT}/wallets/users/alice.pem"
ALICE="${PROJECT}/wallets/users/testnet-bogdan.pem"
ADDRESS=$(erdpy data load --key=address-devnet)
DEPLOY_TRANSACTION=$(erdpy data load --key=deployTransaction-devnet)
PROXY=https://devnet-gateway.elrond.com
CHAINID=D
MY_LOGS="interaction-logs"

deploy() {
    erdpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} --gas-limit=50000000 --arguments 0 --send --outfile="${MY_LOGS}/deploy-devnet.interaction.json" --proxy=${PROXY} --chain=${CHAINID} || return

    TRANSACTION=$(erdpy data parse --file="${MY_LOGS}/deploy-devnet.interaction.json" --expression="data['emitted_tx']['hash']")
    ADDRESS=$(erdpy data parse --file="${MY_LOGS}/deploy-devnet.interaction.json" --expression="data['emitted_tx']['address']")

    erdpy data store --key=address-devnet --value=${ADDRESS}
    erdpy data store --key=deployTransaction-devnet --value=${TRANSACTION}

    echo ""
    echo "Smart contract address: ${ADDRESS}"
}

issueToken() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=50000000 --function="issueToken" \
      --arguments 0 --proxy=${PROXY} --chain=${CHAINID} --send \
      --outfile="${MY_LOGS}/issueToken.json"
}
