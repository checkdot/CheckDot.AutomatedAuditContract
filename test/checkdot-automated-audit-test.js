const truffleAssert = require('truffle-assertions');
const contractTruffle = require('truffle-contract');
const { toWei, toBN } = web3.utils;

/* CheckDotToken Provider */
const checkdotTokenArtifact = require('../../CheckDot.CheckDotERC20Contract/build/contracts/CheckDot.json');
const CheckdotTokenContract = contractTruffle(checkdotTokenArtifact);
CheckdotTokenContract.setProvider(web3.currentProvider);

/* CheckDotAutomatedAuditContract Artifact */
const CheckDotAutomatedAuditContract = artifacts.require('CheckDotAutomatedAuditContract');

contract('CheckDotAutomatedAuditContract', async (accounts) => {
  let tokenInstance;
  let automatedAuditContractInstance;

  let owner;

  before(async () => {
    // instances
    tokenInstance = await CheckdotTokenContract.deployed();
    automatedAuditContractInstance = await CheckDotAutomatedAuditContract.deployed();

    console.log('Contract address:', automatedAuditContractInstance.address);

    // accounts
    owner = accounts[0];
  });

  const testBuy = async (buyFunc, amount) => {
    // // store initiator initial CDT balance
    const initiatorInitialBalance = await tokenInstance.balanceOf(owner);
    // // approve CDT
    const approveAmount = toWei('100000', 'ether');
    await tokenInstance.approve(automatedAuditContractInstance.address, approveAmount, {
      from: owner,
    });
    // buy service
    await buyFunc("0xe9e7cea3dedca5984780bafc599bd69add087d56", {
      from: owner
    });
    // compare initiator current CDT balance with initial balance
    const initiatorCurrentBalance = await tokenInstance.balanceOf(owner);
    assert.equal(
      initiatorCurrentBalance.toString(),
      initiatorInitialBalance.sub(toBN(amount)).toString(),
      'should have CDT removed from balance'
    );
  }

  const testRetrieve = async (buyFunc, amount) => {
    // // store initiator initial CDT balance
    const initiatorInitialBalance = await tokenInstance.balanceOf(owner);
    // buy service
    await buyFunc({
      from: owner
    });
    // compare initiator current CDT balance with initial balance
    const initiatorCurrentBalance = await tokenInstance.balanceOf(owner);
    assert.equal(
      initiatorCurrentBalance.toString(),
      initiatorInitialBalance.add(toBN(amount)).toString(),
      'should have 500 CDT added from balance'
    );
  };

  // Tests it area:

  it('CDT buy', async () => {
    await testBuy(automatedAuditContractInstance.buyInCDT, toWei('10000', 'ether'))
  });

  it('CDT owner retrieve fees', async () => {
    await testRetrieve(automatedAuditContractInstance.claimCDTFees, toWei('10000', 'ether'));
  });

  it('USDT buy', async () => {
    await testBuy(automatedAuditContractInstance.buyInUSDT, toWei('500', 'ether'))
  });

  it('USDT owner retrieve fees', async () => {
    await testRetrieve(automatedAuditContractInstance.claimUSDTFees, toWei('500', 'ether'));
  });

  it('BUSD buy', async () => {
    await testBuy(automatedAuditContractInstance.buyInBUSD, toWei('500', 'ether'))
  });

  it('BUSD owner retrieve fees', async () => {
    await testRetrieve(automatedAuditContractInstance.claimBUSDFees, toWei('500', 'ether'));
  });

});