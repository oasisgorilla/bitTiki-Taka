const { expect } = require("chai");

describe("BTTSwap", function () {
  let BTTSwap, bttSwap;
  let BTTRandomToken, bttRandomToken;
  let owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // BTTSwap 계약 배포
    BTTSwap = await ethers.getContractFactory("BTTSwap");
    bttSwap = await BTTSwap.deploy();

    // BTTRandomToken 계약 배포
    BTTRandomToken = await ethers.getContractFactory("BTTRandomToken");
    bttRandomToken1 = await BTTRandomToken.deploy("Test1", "TST1");
    bttRandomToken2 = await BTTRandomToken.deploy("Test2", "TST2");

  });

  it("should deploy the contracts", async function () {
    expect(await bttSwap.address).to.be.properAddress;
    expect(await bttRandomToken1.address).to.be.properAddress;
    expect(await bttRandomToken2.address).to.be.properAddress;
  });

  it("should create a liquidity pool", async function () {
    const token1Address = bttRandomToken1.address;
    const token2Address = bttRandomToken2.address;
    const tx = await bttSwap.createPairs(token1Address, token2Address);
    const receipt = await tx.wait();

    const pairAddress = receipt.events[0].args.pair;
    expect(pairAddress).to.be.properAddress;
  });

  // 추가적인 테스트를 작성할 수 있습니다.
});
