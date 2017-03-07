pragma solidity ^0.4.8;

contract Project {

 // This struct gets all the required detals for the given project
     struct project_details  {
        string name;
        string description;
        address project_owner;
        uint target_amount;
        uint deadline;
    }

    bool public project_status = true; 
     
    project_details public prj_param;
    
    uint public counter;
	
	struct  contributor {address contributor_address;
		                 uint contributor_amount;}
		                 
	// Mapping of [Funder count] => Corresponding Struct with contributor details
	mapping(uint => contributor) public map_fund_counter_to_contrib;		

    uint public new_target_amount ;

    // Events for tracking the flow
    event contribTracker(address a , uint amount);
    event actualcontribTracker(address a , uint amount);
    event payoutTracker(address a , uint amount,bool x);


    event refundTracker(address a , uint amount,bool x);
    event amtTrack(uint a,uint b,uint c);
    
    /** 
        Constructor stores the incoming project specific Parameters (Received from FundingHub) 
    */
    function Project(string name, string description,address prj_owner, uint amt, 
                                                        uint endtime) payable {
        prj_param.name = name;
        prj_param.description = description;
        prj_param.project_owner = prj_owner;
        prj_param.target_amount = amt;
        prj_param.deadline = endtime;
        new_target_amount = prj_param.target_amount;

        if  (now > endtime) {
            project_status = false;
        }
    }
    
    
    /** 
        This function is invoked when someone funds the project
        RULES
        1) Deadline breached  - Invoke refund() function
        2) Target amt reached - Invoke payout() function and return the amount to each of the sender
    */
    function fund(address r_contributor_address)  payable public  returns (bool){
		uint excess_amount;
		bool isExistAddress;
		uint previousAmount;
		uint r_contributor_amt ;
		
		r_contributor_amt = msg.value;
		
		contribTracker(r_contributor_address,r_contributor_amt);

        bool status = projectStatusCheck(r_contributor_amt,r_contributor_address);

        if (status) return true;

		// Check if the deadline of the project is reached
        bool deadlineMet = deadlineCheck(r_contributor_amt,r_contributor_address);
        
        if (deadlineMet) return true;

        // Keep track of all contributors and the respective amount contributed
		for(uint i=0 ; i <= counter ;i++) {
		    
		    address who = map_fund_counter_to_contrib[i].contributor_address;
		    
		    if (who == r_contributor_address) { // Address matches with previous contribution
		        isExistAddress = true;
		        
		        previousAmount = map_fund_counter_to_contrib[i].contributor_amount;
        		
        		excess_amount = amountExcessCheck(r_contributor_amt,previousAmount,who);
        		
        		map_fund_counter_to_contrib[i].contributor_amount = 
        		                map_fund_counter_to_contrib[i].contributor_amount + r_contributor_amt - excess_amount;
                
                actualcontribTracker(who,map_fund_counter_to_contrib[i].contributor_amount);
		        break;
		    }
		    
		}
		
		if (!isExistAddress) { // Address not present
		        
		    excess_amount = amountExcessCheck(r_contributor_amt,previousAmount,r_contributor_address);
		    map_fund_counter_to_contrib[counter++] = contributor(r_contributor_address,r_contributor_amt-excess_amount);
            
            actualcontribTracker(r_contributor_address,r_contributor_amt-excess_amount);
		 }
		 return true;
    }
 
    function amountExcessCheck(uint receivied_amount,uint previous_contribution, address funder) returns (uint) {
        uint excess_amount;
        
        amtTrack(receivied_amount,new_target_amount,0);
        if (receivied_amount > new_target_amount)  { // 120 >100
            excess_amount = receivied_amount - new_target_amount ; // 20 = 120 -100
            new_target_amount =  receivied_amount - new_target_amount - excess_amount; // 120  - 100 -20 
            refund(funder,excess_amount);
            payout(); 
        }
        else
        {
            new_target_amount =  new_target_amount - receivied_amount; // 100 - 20
   
        }
        
        return excess_amount;
    }

    function deadlineCheck(uint received_amount,address contrib) returns(bool) {
    // deadline over  1                       // 120 < 100 (target)
    bool deadlineMet = false ;
        if  (now > prj_param.deadline)  {
            project_status = false;
            deadlineMet = true;
            refund(contrib,received_amount); 
            
            for(uint i=0 ; i <= counter ;i++) {
		        address who = map_fund_counter_to_contrib[i].contributor_address;
		        uint amount = map_fund_counter_to_contrib[i].contributor_amount;
		        contribTracker (who,amount);
                refund(who,amount);
		    }
        }
        
        return deadlineMet;
    }

    function projectStatusCheck(uint received_amount,address contrib) returns(bool) {
        bool status = false ;
        if  (!project_status)     {
            status = true;
            refund(contrib,received_amount); 
            
            for(uint i=0 ; i <= counter ;i++) {
                address who = map_fund_counter_to_contrib[i].contributor_address;
                uint amount = map_fund_counter_to_contrib[i].contributor_amount;
                contribTracker (who,amount);
                refund(who,amount);
            }
        }
        return status;
    }




    /**
     * Payout all the funded amount to the project owner
     */
    function payout() payable returns (bool) {
     
        bool ret = prj_param.project_owner.send(prj_param.target_amount);
        
        payoutTracker(prj_param.project_owner , prj_param.target_amount,ret);
       
        if (!ret) return false;
        
        project_status = false;


        return true;

    }    

    /**
     * Refund it to to the contributor
     */
    function refund(address funder,uint amount) payable returns (bool) {
        bool ret = funder.send(amount);
        refundTracker(funder , amount,ret);
        if (!ret) return false;
            return true;
    }
    
  function getProjInfo() constant returns (string name,string desc ,uint target, uint deadline,uint remaining_amount,bool stat) {

       return (prj_param.name,prj_param.description, prj_param.target_amount,prj_param.deadline,new_target_amount,project_status);
   }

   function (){
    throw;
  }


}