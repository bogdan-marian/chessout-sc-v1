const express = require("express");

import path = require("path");
import fs = require("fs");
import {
  Account,
  Address,
  UserSigner,
  SmartContractAbi,
  Balance,
  Code,
  ContractFunction,
  GasLimit,
  NetworkConfig,
  ProxyProvider,
  SmartContract,
  Interaction,
} from "@elrondnetwork/erdjs";
import {
  AbiRegistry,
  AddressValue,
  BytesValue,
  U32Value,
} from "@elrondnetwork/erdjs/out/smartcontracts/typesystem";
import { BinaryCodec } from "@elrondnetwork/erdjs/out/smartcontracts/codec";
import BigNumber from "bignumber.js";
import { readFileSync, accessSync, constants, writeFileSync } from "fs";

const app = express();

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log("Hello world listening on port", port);
  getTournamentInfoList();
});

app.get("/", (req, res) => {
  console.log("Hello world received a request.");

  const target = process.env.TARGET || "World";
  res.send(`Hello ${target}!`);
});

app.get("/tournament/:tournamentId/", getTournament);

function getTournament(request, response) {
  let tournamentId = request.params.tournamentId;
  console.log("tournamentId=" + tournamentId);

  let reply = {
    success: true,
    message: "getTournament successfully called",
    tournamentId: tournamentId,
  };

  runInteractions();

  response.send(reply);
}

async function runInteractions() {
  let codec = new BinaryCodec();
  let provider = new ProxyProvider("http://localhost:7950");
  let keyFilePath = path.resolve(__dirname, "wallets/users/alice.json");
  let keyFileJson = fs.readFileSync(keyFilePath, { encoding: "utf8" });
  let keyFileObject = JSON.parse(keyFileJson);
  let password = "password";
  let signer = UserSigner.fromWallet(keyFileObject, password);
  let user = new Account(signer.getAddress());

  let abiPath = path.resolve(__dirname, "abi.json");
  let abiJson = fs.readFileSync(abiPath, { encoding: "utf8" });
  let abiObject = JSON.parse(abiJson);
  let abi = new AbiRegistry();
  abi.extend(abiObject);
  //let namespace = abi.findNamespace("lottery-egld");

  console.log("End of runInteractions");
}

export const createSmartContractInstance = (
  abi?: AbiRegistry,
  address?: string
) => {
  const contract = new SmartContract({
    address: address ? new Address(address) : undefined,
    abi:
      abi &&
      new SmartContractAbi(
        abi,
        abi.interfaces.map((iface) => iface.name)
      ),
  });
  return contract;
};

async function getAbi(filePath: string) {
  try {
    console.log("File path: " + filePath);
    let registry = await AbiRegistry.load({ files: [filePath] });
    return registry;
  } catch (e) {
    console.log("We had an error AbiRegistry.load", e.message);
  }
}

async function queryCrowdFund() {
  try {
    let provider = new ProxyProvider("https://devnet-gateway.elrond.com");
    await NetworkConfig.getDefault().sync(provider);

    let stringAddress =
      "erd1qqqqqqqqqqqqqpgq5jq6srjkl3mrrvzy932fwj46j970ml4sd8ssacje4l";
    let address = new Address(stringAddress);

    let abiRegistry = await AbiRegistry.load({
      files: ["crowdfunding-esdt.abi.json"],
    });
    let abi = new SmartContractAbi(abiRegistry, [`Crowdfunding`]);

    let contract = new SmartContract({
      address: address,
      abi: abi,
    });

    let interaction: Interaction = contract.methods.getCurrentFunds();

    let queryResponse = await contract.runQuery(
      provider,
      interaction.buildQuery()
    );
    let response = interaction.interpretQueryResponse(queryResponse);
    console.log(response);

    // End of queryCrowdFund()
    let stamp = Date();
    console.log("End of query crowdfund " + stamp);
  } catch (error) {
    console.log(error);
  }
}

async function callGetTokenId() {
  try {
    let provider = new ProxyProvider("https://devnet-gateway.elrond.com");
    await NetworkConfig.getDefault().sync(provider);

    let stringAddress =
      "erd1qqqqqqqqqqqqqpgqmn55krqdxch3x6udq5xnenzs698rfrp4d8ss635ses";
    let address = new Address(stringAddress);

    let abiRegistry = await AbiRegistry.load({
      files: ["my-contract.abi.json"],
    });
    let abi = new SmartContractAbi(abiRegistry, [`MyContract`]);

    let contract = new SmartContract({
      address: address,
      abi: abi,
    });

    let interaction: Interaction = contract.methods.getTokenId();

    let queryResponse = await contract.runQuery(
      provider,
      interaction.buildQuery()
    );
    let response = interaction.interpretQueryResponse(queryResponse);
    console.log(response);

    // End of queryCrowdFund()
    let stamp = Date();
    console.log("End of query crowdfund " + stamp);
  } catch (error) {
    console.log(error);
  }
}

async function getTournamentInfo() {
  try {
    let provider = new ProxyProvider("https://devnet-gateway.elrond.com");
    await NetworkConfig.getDefault().sync(provider);

    let stringAddress =
      "erd1qqqqqqqqqqqqqpgqmn55krqdxch3x6udq5xnenzs698rfrp4d8ss635ses";
    let address = new Address(stringAddress);

    let abiRegistry = await AbiRegistry.load({
      files: ["my-contract.abi.json"],
    });
    let abi = new SmartContractAbi(abiRegistry, [`MyContract`]);

    let contract = new SmartContract({
      address: address,
      abi: abi,
    });

    let interaction: Interaction = contract.methods.getTournamentInfo([
      BytesValue.fromUTF8("tournament-01"),
    ]);

    let queryResponse = await contract.runQuery(
      provider,
      interaction.buildQuery()
    );
    let response = interaction.interpretQueryResponse(queryResponse);
    console.log(response);

    // End of queryCrowdFund()
    let stamp = Date();
    console.log("End of query crowdfund " + stamp);
  } catch (error) {
    console.log(error);
  }
}

async function getTournamentInfoList() {
  try {
    let provider = new ProxyProvider("https://devnet-gateway.elrond.com");
    await NetworkConfig.getDefault().sync(provider);

    let stringAddress =
      "erd1qqqqqqqqqqqqqpgqmn55krqdxch3x6udq5xnenzs698rfrp4d8ss635ses";
    let address = new Address(stringAddress);

    let abiRegistry = await AbiRegistry.load({
      files: ["my-contract.abi.json"],
    });
    let abi = new SmartContractAbi(abiRegistry, [`MyContract`]);

    let contract = new SmartContract({
      address: address,
      abi: abi,
    });

    let interaction: Interaction = contract.methods.getTournamentInfoList([
      BytesValue.fromUTF8("tournament-01"),
      BytesValue.fromUTF8("tournament-02"),
    ]);

    let queryResponse = await contract.runQuery(
      provider,
      interaction.buildQuery()
    );
    let response = interaction.interpretQueryResponse(queryResponse);
    console.log(response);

    console.log("--------------------List iteration -------------");
    let myType = response.firstValue.getType();
    console.log(myType);

    let myList = response.firstValue.valueOf();
    console.log(myList);

    myList.forEach((element) => {
      let bufferedId = element.tournament_id;
      console.log(bufferedId);
    });
    // End of queryCrowdFund()
    let stamp = Date();
    console.log("End of query crowdfund " + stamp);
  } catch (error) {
    console.log(error);
  }
}
