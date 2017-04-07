// Load FundingHub and Project contract
var FundingHub = artifacts.require("./FundingHub.sol");
var Project = artifacts.require("./Project.sol");

contract('Project', function(accounts) {
 

    it("1.Refund test - Fund after projet end date", function() {

    var sg ;
    var coinbase_balance_before;
    var project_balance_before;
    var project_balance_after_funding ;   
    var coinbase_balance_after_funding;

    FundingHub.deployed().then(function(instance) {

    instance.createProject("Testing1","This is a test project 1",10,1291373548,{from:web3.eth.accounts[5]});
    return instance.getProjAddr.call();

    }).then (function(results){

        var projects = results;
        sg = projects[0];
        coinbase_balance_before = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[4]),"ether"));
        project_balance_before  = web3.eth.getBalance(sg).toString();
        return sg;

    }).then(function(instance) {

       return Project.at(instance).fund(instance,{from:web3.eth.accounts[4],value:4000000000000000000});

     }).then(function(result) {

        console.log("#######################################################################################################################\n");
        console.log("\nTest Case 1 : Fund a project while the project is already met the deadline\n");
        console.log("Coinbase Balance before: " + coinbase_balance_before);
        console.log("Project  Balance before: " + project_balance_before);      
        console.log("\nTransfer 4 ethers from Coinbase to Project \n");
        project_balance_after_fund_transfer = web3.eth.getBalance(sg).toString();
        coinbase_balance_after_funding = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[4]),"ether"));
        console.log("Coinbase Balance after acepting funds: "+coinbase_balance_after_funding);
        console.log("Project  Balance after funding: " + web3.fromWei(project_balance_after_fund_transfer,"ether"));
        assert.equal(project_balance_before ,project_balance_after_fund_transfer,"Fund is transfered after project End date - FAIL !!!!");

    });

   });

   it("2.Excess amount refund test", function() {
    var funder_balance_before;
    var funder_balance_after;
    var project_balance_before;
    var project_owner_balance_before;
    var sg;
    FundingHub.deployed().then(function(instance) {

    instance.createProject("Testing2","This is a test project 2",10,1788825289);
    return instance.getProjAddr.call();

    }).then (function(results){

    var projects = results;
    sg = projects[1];
    funder_balance_before = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[1]),"ether"));
    project_owner_balance_before = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]),"ether"));
    project_balance_before = parseInt(web3.eth.getBalance(sg).toString());
    return  null;

    }).then(function() {

       return Project.at(sg).fund(sg,{from:web3.eth.accounts[1],value:11000000000000000000,gas:200000});

    }).then (function(result) {

      console.log("\n#######################################################################################################################\n"); 
      console.log("Test Case 2 : Project is created with maximum target amount as 10 Ethers.\n");
      console.log("Project owner account balance ="+project_owner_balance_before);
      console.log("Funder account balance = "+funder_balance_before);
      console.log("\n11 Ethers are transfered instead of 10[maximum fund] - Payout executed and 1 extra ether sent to owner !!!!!!!!!!!!!!\n");
      funder_balance_after = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[1]),"ether"));
      var project_owner_balance_after = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]),"ether"));
      console.log("Project owner account balance="+project_owner_balance_after);
      console.log("Funder account balance after funding 11 ethers= "+funder_balance_after);
      var newbalance = project_owner_balance_before + 10;
      assert.equal(project_owner_balance_after ,newbalance,"Fund transfer accepted more than required - FAIL !!!!");

    });

  });




    it("3.Refund test - Fund from multiple accounts and project end date is encountered", function() {
    var sg ;
    var coinbase_balance_before6;
    var coinbase_balance_before7;
    var coinbase_balance_before8;
    var coinbase_balance_after6;
    var coinbase_balance_after7;
    var coinbase_balance_after8;
    var coinbase6_balance_afterDelay;
    var coinbase7_balance_afterDelay;
    var coinbase8_balance_afterDelay;
    var project_balance_before;
    var project_balance_after_funding ;   
    var coinbase_balance_after_funding;

    var unixtime = Math.round((new Date()).getTime() / 1000) + 20;

    FundingHub.deployed().then(function(instance) {

    instance.createProject("Testing1","This is a test project 3",10,unixtime,{from:web3.eth.accounts[5]});
    return instance.getProjAddr.call();

    }).then (function(results){

        var projects = results;
        sg = projects[2];
        coinbase_balance_before6 = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[6]),"ether"));
        coinbase_balance_before7 = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[7]),"ether"));
        coinbase_balance_before8 = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[8]),"ether"));
        project_balance_before  = web3.eth.getBalance(sg).toString();
        return sg;

    }).then(function(instance) {

       Project.at(instance).fund(instance,{from:web3.eth.accounts[6],value:1000000000000000000});
       Project.at(instance).fund(instance,{from:web3.eth.accounts[7],value:1000000000000000000});
       return Project.at(instance).fund(instance,{from:web3.eth.accounts[8],value:1000000000000000000});

    }).then(function(result) {

        coinbase_balance_after6 = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[6]),"ether"));
        coinbase_balance_after7 = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[7]),"ether"));
        coinbase_balance_after8 = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[8]),"ether"));
        return null;

    }).then(setTimeout(function() {
        console.log("\n#######################################################################################################################\n");
        console.log("\nTest Case 3 : Fund a project from different accounts. Fund again after project endtime\n");
        console.log("Coinbase6 Balance before: " + coinbase_balance_before6);
        console.log("Coinbase7 Balance before: " + coinbase_balance_before7);
        console.log("Coinbase8 Balance before: " + coinbase_balance_before8);
        console.log("Project  Balance  before: " + project_balance_before);    
        console.log("\n\nFund 1 Ether from each account \n\n");
        console.log("Coinbase6 Balance after fund transfer: " + coinbase_balance_after6);
        console.log("Coinbase7 Balance after fund transfer: " + coinbase_balance_after7);
        console.log("Coinbase8 Balance after fund transfer: " + coinbase_balance_after8);
        console.log("Project  Balance  after fund accepted: " + web3.eth.getBalance(sg).toString());    
        console.log("\nAfter 60 seconds wait - Transfer funds again - by this time project is end dated.\n");

        var unixtime = Math.round((new Date()).getTime() / 1000) + 60;
        Project.at(sg).fund(sg,{from:web3.eth.accounts[6],value:1000000000000000000});
        return null;

    },60000)).then(setTimeout(function() {

        coinbase6_balance_afterDelay = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[6]),"ether"));
        coinbase7_balance_afterDelay = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[7]),"ether"));
        coinbase8_balance_afterDelay = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[8]),"ether"));
        console.log("\nFund 1 Ether from each account\n");
        console.log("Coinbase6 Balance after project deadline: " + coinbase6_balance_afterDelay);
        console.log("Coinbase7 Balance after project deadline: " + coinbase7_balance_afterDelay);
        console.log("Coinbase8 Balance after project deadline: " + coinbase8_balance_afterDelay);
        console.log("Project  Balance  after project deadline: " + web3.eth.getBalance(sg).toString());
        prjBalanceAfter = parseInt(web3.eth.getBalance(sg).toString());
        console.log("\n#######################################################################################################################\n");
        assert.equal(project_balance_before ,prjBalanceAfter,"Refund success");    

    },70000));

});

 

  it("4.Refund Test case", function() {

    var project_balance_before;
    var coinbase_balance_before;
    var project_balance_after_fund_transfer;
    var sg;
    var project_balance_after_funding ;   
    var coinbase_balance_after_funding;

    // Fetch the contract instance and invoke contract - createProject() in blockchain.

    FundingHub.deployed().then(function(instance) {

    instance.createProject("Testing1","This is a test project 3",10,1788825289,{from:web3.eth.accounts[3]});
    return instance.getProjAddr.call();

    }).then (function(results){

        var projects = results;
        sg = projects[3];
        coinbase_balance_before = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[2]),"ether"));
        project_balance_before  = web3.eth.getBalance(sg).toString();
        return sg;

    }).then(function(instance) {

       return Project.at(instance).fund(instance,{from:web3.eth.accounts[2],value:5000000000000000000});

     }).then(function(result) {

        project_balance_after_fund_transfer = web3.eth.getBalance(sg).toString();
        coinbase_balance_after_funding = parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[2]),"ether"));
        console.log("\n#######################################################################################################################\n");
        console.log("Test Case 4 : Fund a project and refund back \n");
        console.log("Coinbase Balance befor: " + coinbase_balance_before);
        console.log("Project  Balance before: " + project_balance_before);      
        console.log("\nTransfer 5 ethers from Coinbase to Project \n");
        console.log("Coinbase Balance after funding: "+coinbase_balance_after_funding);
        console.log("Project  Balance after accepting funds: " + web3.fromWei(project_balance_after_fund_transfer,"ether"));
        return sg;

    }).then(function(instance) {

        return Project.at(instance).refund(web3.eth.accounts[2],5000000000000000000,{from:web3.eth.accounts[3]});

    }).then(function(result) {

        console.log("\nRefund 5 ethers from Project to Coinbase\n");
        var balance_after = web3.fromWei(web3.eth.getBalance(sg).toString(),"ether");
        console.log("Coinbase Balance after refund: "+parseInt(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[2]),"ether")));
        console.log("Project Balance after refund: "+ balance_after.toString());
        assert.equal(project_balance_before ,balance_after,"Refund Failed");

    });

  });

});

 
