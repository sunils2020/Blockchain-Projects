
function createProject() {

 // Gets all the individual elments from the Form
  var _proj_name        = document.getElementById("project_name").value;
  var _proj_desc        = document.getElementById("project_desc").value;
  var _proj_budget      = document.getElementById("project_budget").value;
  var _proj_deadline    = document.getElementById("deadline").value;

var unixTimestamp = moment(_proj_deadline, 'YYYY-MM-DD').unix();
 //alert(unixTimestamp);

//var dateString = moment.unix(unixTimestamp).format('YYYY-MM-DD');
// alert(dateString );

  // Fetch the contract instance and invoke contract - createProject() in blockchain.  
  var hub = FundingHub.deployed();

  var func = hub.then(function(instance){

      return instance.createProject(_proj_name,_proj_desc,_proj_budget,unixTimestamp,{from:web3.eth.coinbase,gas:1164443});

  });

  alert("Project created success !!");

}

function loadProjects() {

var table_header ='<table style="width:100%" border=4><tr><th>Project Address</th><th>Project Name</th><th>Project Description</th><th>Target amount</th><th>Deadline</th><th>Remaining amount</th><th>Project status</th></tr>';

var tablecont = table_header ;

var endtable ="</table>";

  // Fetch the contract instance and invoke contract - createProject() in blockchain.
  var hub = FundingHub.deployed();

  // Get all the addresses of the Project instances
  var func = hub.then(function(instance){return instance.getProjAddr.call();});

  // Iterate through them and get the actual project elements to display on the main screen
  func.then(function(output) { 

    projects = output; 
    
    tablecont = tablecont +"<tr>";
    
    for(var i =0 ;i < output.length ; i++) { 

          var sg = projects[i];
          var counter =0;

          Project.at(sg).then(function(instance) {

                return instance.getProjInfo.call();

          }).then(function(result) { 
            
             tablecont = tablecont + "<td>"+projects[counter]+"</td>";

              counter++;


          var name = result[0]; 
    
          tablecont = tablecont + "<td>"+name+"</td>";

           var desc = result[1];

       tablecont = tablecont + "<td>"+desc+"</td>";

           var fund = web3.fromWei(result[2],"ether").toString();
  
       tablecont = tablecont + "<td>"+fund +"</td>";

            var deadline_no = parseInt(result[3].toString());

            var deadline_date = moment.unix(deadline_no).format('YYYY-MM-DD');

       tablecont = tablecont + "<td>"+deadline_date +"</td>";

            var remaining_amt = web3.fromWei(result[4],"ether").toString();

      tablecont = tablecont + "<td>"+remaining_amt +"</td>";

      var status = result[5]; 
      var proj_stat ;  
      if (status) {

         proj_stat = "Live"; 

      }  else {

        proj_stat = "Ended";
      }
           tablecont = tablecont + "<td>"+ proj_stat + "</td>" + "</tr>";


            if ( i == output.length) {

                var final =  tablecont  + endtable ;

                var divtable = document.getElementById("mytable");

                divtable.innerHTML = final;

            }
        });

        }

    });

} 

function contribute() {

alert("Thank you for your contribution");

  // Gets all the individual elments from the Form
  var _proj_addr = document.getElementById("project_address").value;

  var _contrib_fund = document.getElementById("contrib_fund").value;

  var hub = FundingHub.deployed();

  // Invoke the contribute function present in blockchain environment
  var func = hub.then(function(instance){

       instance.contribute(_proj_addr,{from:web3.eth.accounts[0],value: web3.toWei(_contrib_fund,'ether'),gas:1164443});

      });
}

