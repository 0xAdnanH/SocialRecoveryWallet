const { expect } = require("chai");
const { ethers } = require("hardhat");
let provider = ethers.provider;
let owner;
let addr1;
let addr2;
let guardian;
let newOwner;
let contract;

before(async () => {
  [owner, addr1, addr2, guardian, newOwner] = await ethers.getSigners();
  const getFactory = await ethers.getContractFactory("SocialRecoveryWallet");
  contract = await getFactory.connect(owner).deploy();
});

describe("Testing execute fn", () => {
  it("should low level call successfully", async () => {
    await contract.connect(owner).execute(addr1, "0x11ab", { value: 5000 });
    const addr1Balance = await provider.getBalance(addr1.address);
    expect(addr1Balance).to.equal(10000000000000000005000n);
  });
  it("should revert if no data is sent", async () => {
    await expect(
      contract.connect(owner).execute(addr1, "0x", { value: 5000 })
    ).to.be.revertedWith("Empty data");
  });
});

describe("Setting new guardian", () => {
  it("should not set same guardian twice", async () => {
    await contract.connect(owner).registerGuardian(guardian);
    await expect(
      contract.connect(owner).registerGuardian(guardian)
    ).to.be.revertedWith("Guardian already registered");
  });
});

describe("removing registered guardian", () => {
  it("should remove guardian", async () => {
    await contract.connect(owner).deregisterGuardian(guardian);
    await expect(
      contract.connect(owner).deregisterGuardian(guardian)
    ).to.be.revertedWith("Guardian not registered");
  });
});

describe("new owner voting", () => {
  it("should revert if newOwner == owner", async () => {
    await contract.connect(owner).registerGuardian(guardian);
    await expect(
      contract.connect(guardian).chooseRecoverer(owner)
    ).to.be.revertedWith("Already owner");
  });
});

describe("set new owner", () => {
  it("should set new owner", async () => {
    await contract.connect(guardian).chooseRecoverer(newOwner);
  });
});

describe("transfer ownership to new owner", () => {
  it("should transfer ownership to new owner", async () => {
    await contract.connect(newOwner).recovererClaimOwnership();

    await contract.connect(newOwner).execute(addr2, "0x12", { value: 99999 });
    const addr2Balance = await provider.getBalance(addr2.address);
    expect(addr2Balance).to.equal(10000000000000000099999n);
  });
});
