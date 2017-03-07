var FundingHub = artifacts.require("./FundingHub.sol");

var Project = artifacts.require("./Project.sol");

contract('Project', function(accounts) {


  it("Refund Test case", function() {

  // Fetch the contract instance and invoke contract - createProject() in blockchain.
  var hub = FundingHub.deployed();

  hub.then(function(instance) {return instance.createProject("deepa","test",100,1788825289);})

  // Get all the addresses of the Project instances
  var func = hub.then(function(instance){return instance.getProjAddr.call();});

  // Iterate through them and get the actual project elements to display on the main screen
  func.then(function(output) { 

    projects = output; 
    var sg = projects[0];

    var balance_before = parseInt(web3.eth.getBalance(sg).toString());

    console.log("Address:1st"+web3.eth.getBalance(sg));
    console.log("coinbase:"+web3.eth.getBalance(web3.eth.accounts[0]));

    var funds = Project.at(sg).then(function(instance) {
                // funded
                return instance.fund(sg,{from:web3.eth.accounts[0],value:50000000000000});

          });

    funds.then(function(result) {console.log("Address-2nd"+web3.eth.getBalance(sg));}).then(function(test) 
    {

        Project.at(sg).then(function(instance) {
                //refunded
                return instance.refund(web3.eth.accounts[0],50000000000000,{from:web3.eth.accounts[0]})

          }).then(function(result) {

            var balance_after = parseInt(web3.eth.getBalance(sg).toString());console.log(balance_after.toString());
            console.log("Address-3rd"+web3.eth.getBalance(sg)+balance_after);
            assert.equal(balance_before ,balance_after,"Refund Failed");
          })
  });
});
});  
  });  
