const GrantGovernance = artifacts.require("GrantGovernance")
const NominateAmbassador = artifacts.require("AmbassadorNomination")
// TODO testnet accounts
module.exports = function(deployer, network, accounts) {
  if (network === "main") {
    return
  }

  console.log("-----------------------------")
  console.log(accounts)
  console.log("-----------------------------")

  deployer.deploy(NominateAmbassador).then(function(){
    return deployer.deploy(GrantGovernance)
  })
}
