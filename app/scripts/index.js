// Import the page's CSS. Webpack will know what to do with it.
import '../styles/app.css'

// Import libraries we need.
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

const campaign = require("../../build/contracts/Campaign.json")
const campaignFactory = require('../../build/contracts/CampaignFactory.json') 
const Campaign = contract(campaign);
const CampaignFactory = contract(campaignFactory)

var renderCampaign = (_campaigns) => {
  var listCampaign = $("#campaigns");
  var html;
  _campaigns.forEach(function(entry){
    var element =  '<li>' + entry + '<button class="badge" id ='+ entry +' data-campaign="'+ entry +'" onclick="donateCampaign(this)">Donate</button></li>';
    html += element;
  });
  listCampaign.html(html);
}

window.createCampaign = async function() {

  var instance = await CampaignFactory.deployed();
  await instance.createCampaign({gas: 3000000, from: web3.eth.accounts[0]});
  var campaigns = await instance.getAllCampaigns();
  await renderCampaign(campaigns);
  // try {
  //   CampaignFactory.deployed().then(function(instance) {
  //     instance.createCampaign({gas: 3000000, from: web3.eth.accounts[0]}).then(function() {

  //       var listCampaign = $("#campaigns");
  //       var html = '<li>' + campaign + '<button class="badge" data-campaign="'+ campaign +'">Donate</button></li>'
  //       listCampaign.append(html);
  //     })
  //   })
  // } catch (err) {
  //   console.logog(err)
  // } 
}
window.donateCampaign = async function(target) {
  var addressCampaign = await target.dataset.campaign;
  // instance

  try {
    // addressCampaign = $(this).data("campaign");
    Campaign.at(addressCampaign).then(function(instance){
      instance.donate({gas: 140000, from: web3.eth.accounts[0], value: 10000000});
    });
  } catch (err) {
    console.log(err);
  }
}
$( document ).ready(function() {
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source like Metamask")
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  CampaignFactory.setProvider(web3.currentProvider);
  Campaign.setProvider(web3.currentProvider);
  CampaignFactory.deployed().then(async (ins) => {
    var initCampaigns = await ins.getAllCampaigns();
    await renderCampaign(initCampaigns);
  });
  
})