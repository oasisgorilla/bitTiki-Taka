async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const BTTSwap = await ethers.getContractFactory("BTTSwap");
    const bttSwap = await BTTSwap.deploy();
    console.log("BTTSwap deployed to:", bttSwap.address);
  
    const BTTRandomToken = await ethers.getContractFactory("BTTRandomToken");
    const bttRandomToken = await BTTRandomToken.deploy("Test1", "TST1");
    console.log("BTTRandomToken deployed to:", bttRandomToken.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  