// scripts/index.js
async function main () {
  // Our code will go here
  console.log('interacting'); 
  const addressWETHGateway = '0xcD34503e5fD5Ff9bC370679a92ad26011bC7cd9F'; 
  const WETHGateway = await ethers.getContractFactory('WETHGateway');
  const w = await WETHGateway.attach(addressWETHGateway); 
  const addressLendingPool = '0x10DcdCAfA77CB47C8b2a496E4Ec264F96B729923'; 
  const addressonBehalfOf = '0x163e23Ea39BEB535b038E009b1C3966805f8c0BC'; 
  await w.depositETH(addressLendingPool, addressonBehalfOf,0,
      {"value": ethers.utils.parseEther("0.5")},
  );


}
  
main()
  .then(() => process.exit(0))
  .catch(error => {
  console.error(error);
  process.exit(1);
});