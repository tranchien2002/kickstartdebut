const Campaign = artifacts.require('./Campaign.sol');
contract('Campaign', function([owner, contributor1, contributor2, contributor3]){
  
  const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
  
  describe('owner contract', async function() {
    let campaign;
    before('setup contract for test', async function() {
      campaign = await Campaign.new(owner, 120, 5, 20);
    })
    it('has an owner', async function() {
      assert.equal(await campaign.owner(), owner);
    })
  })
  
  describe('contribute', async function() {
    let campaign;
    before('setup contract for test', async function() {
      campaign = await Campaign.new(owner, 120, 5, 20);
    })
    it('contribute', async function() {
      await campaign.contribute({value: 30, from: contributor1});
      await campaign.contribute({value: 20, from: contributor2});
      const balance = await campaign.currentBalance();
      assert.equal(balance, 50);
      const contribution1 = await campaign.contributions.call(contributor1);
      assert.equal(contribution1, 30);
    })
    it('cant contribute when timeout', async function() {
      await delay(5000);
      try {
        await campaign.contribute({value: 30, from: contributor1});
      }
      catch (e) {
        return true;
      }
      assert.equal(await campaign.approversCount(), 0);
    })
  })
  
  describe('fundCall unsuccess', async function(){
    let campaign;
    before('setup contract for test', async function() {
      campaign = await Campaign.new(owner, 120, 5, 20);
    })
    
    it("refund when time remains", async () => {
      await campaign.contribute({value: 30, from: contributor1});
      await campaign.contribute({value: 20, from: contributor2});
      let balance = await campaign.currentBalance();
      try {
        await campaign.refund({from: contributor1});
      }
      catch (e) {
        return true;
      }
      assert.equal(balance, 50);}
    );

    it("refund when time out", async () => {
      await delay(5000);
      await campaign.refund({from: contributor1});
      let balance = await campaign.currentBalance();
      assert.equal(balance, 20);
    })

  })

  describe('fundCall success', async function(){
    let campaign;
    before('setup contract for test', async () => {
      campaign = await Campaign.new(owner, 120, 5, 20);
    })
    it('refund when time out', async () => {
      await campaign.contribute({value: 100, from: contributor1});
      await campaign.contribute({value: 20, from: contributor2});
      await delay(5000);
      try {
        await campaig.refund({from: contributor1});
      }
      catch (e){
        return true;
      }
      const balance = await campaign.currentBalance();
      assert.equal(balance, 120);
    })

    it('create request', async () => {

    })
  })
})