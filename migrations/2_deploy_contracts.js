const GrantGovernance = artifacts.require("GrantGovernance")

// TODO testnet accounts
module.exports = function(deployer, network, accounts) {
  if (network === "main") {
    return
  }

  console.log("-----------------------------")
  console.log(accounts)
  console.log("-----------------------------")

  return deployer.deploy(GrantGovernance)
  
}
