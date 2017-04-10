pragma solidity ^0.4.8;

/*******************************************************************************
 Project Contract : This smart contract is used to fund a project.
 Description : It keeps track of all the contributors and their contributions.
 Functions : 
             1. fund() - fund any project
             2. amountExcessChek() - Validates if someone has funded more than 
                                     what is required
             3. deadlineCheck() - Validates if the project has Ended
             4. projectStatusCheck() - Validates if the project is Live
             5. payout() - Final check is sent to the project owner
             6. refund() - Refunds the amount to the respective contributor
             7. getProjInfo() - Get to know the project values
*******************************************************************************/
contract Project {

    // This struct gets all the required detals for the given project
     struct project_details  {
                                address project_address;
                                string name;
                                string description;
                                address project_owner;
                                uint target_amount;
                                uint deadline;
                             }
   // Live or Ended
    bool project_status = true;
    
    // Struct instance
    project_details prj_param;
    
    // Counter to track the contributor and the amount
    uint counter; 
    
    // Mapping of contribution amount and the contributor address
    struct  contributor {address contributor_address;
                         uint contributor_amount;}
                         
    // Mapping of [Funder count] => Corresponding Struct with contributor details
    mapping(uint => contributor) map_fund_counter_to_contrib;

   // Revised target after each funding
    uint new_target_amount ;

    /*************************************************************************** 
        Function    : Project()
        Description : Constructor which stores the incoming project specific 
                      parameters (Received from FundingHub) 
    ***************************************************************************/ 
    function Project(string name, string description,address prj_owner, uint amt, 
                                                        uint endtime) payable {
                                                            
        prj_param.project_address = this;
        prj_param.name = name;
        prj_param.description = description;
        prj_param.project_owner = prj_owner;
        prj_param.target_amount = amt;
        prj_param.deadline = endtime;
        new_target_amount = prj_param.target_amount;

        /* If deadline is passed then set the project status as Ended
           Ex: April 3,2017 > April 2,2016 ( End time mentioned) */
        if  (now > endtime) {
            project_status = false;
        }
    }

    // Events for tracking the flow
    event contribTracker(address a , uint amount);
    event actualcontribTracker(address a , uint amount);
    event payoutTracker(address a , uint amount,bool x);
    event refundTracker(address a , uint amount,bool x);
    event amtTrack(uint a,uint b,uint c);

    /*************************************************************************** 
        Function    : fund()
        Description : This function is invoked when someone funds the project
        Rules       :
        1) Deadline breached  - Invoke refund() function
        2) Target amt reached - Invoke payout() function and return 
                                the amount to each of the sender
    ***************************************************************************/
    function fund(r_contributor_address)  payable returns (bool) {
        
        uint excess_amount;
        bool isExistAddress;
        uint previousAmount;
        uint r_contributor_amt ;
        
        r_contributor_amt = msg.value;

        contribTracker(msg.sender,r_contributor_amt);
        
        // Live or Ended
        bool status = projectStatusCheck(r_contributor_amt,r_contributor_address);
        if (status) return status; // project ended

        // Check if the deadline of the project is reached
        bool deadlineMet = deadlineCheck(r_contributor_amt,r_contributor_address);
        if (deadlineMet) return deadlineMet; // deadline reached

        // Keep track of all contributors and the respective amount contributed
        
        // Counter will be 0 till someone contributes first
        for(uint i=0 ; i <= counter ;i++) { 
            
            address who = map_fund_counter_to_contrib[i].contributor_address;
            
        // Address matches with previous contribution - Check with all values of i
            if (who == r_contributor_address) { 
                // Someone has already contributed
                isExistAddress = true; 
                /* Get the previous contribution amount
                   Ex : [1,(0X01,2)]    - Here previous amount is 2
                   Let us say the new amount is 3 */
                previousAmount = map_fund_counter_to_contrib[i].contributor_amount;
                
                /* Pass the contributor address & amount , current amount 
                   Ex : [1,(0X01,2)] ==> 3,2,0X01 */
                
                // Check if the amount exceeds than the required limit
                excess_amount = amountExcessCheck(r_contributor_amt,previousAmount,who);
                
                // Adding the actual contribution amount (Excess amount excluded)
                map_fund_counter_to_contrib[i].contributor_amount = 
                                map_fund_counter_to_contrib[i].contributor_amount + 
                                                                r_contributor_amt - 
                                                                excess_amount;
                
                actualcontribTracker(who,map_fund_counter_to_contrib[i].contributor_amount);
                break; // Once matched exit out of the loop
            }
            
        }
        
        // Contributor Address not present in the Map
        if (!isExistAddress) { 
            // Check if the amount exceeds than the required limit
            excess_amount = amountExcessCheck(r_contributor_amt,previousAmount,
                                                           r_contributor_address);
            // Adding the actual contribution amount (Excess amount excluded)
            map_fund_counter_to_contrib[counter++] = 
                contributor(r_contributor_address,r_contributor_amt-excess_amount);
            // Ex : [1,(0X01,2)]
            actualcontribTracker(r_contributor_address,r_contributor_amt-excess_amount);
         }
         return true;
    }

    /*************************************************************************** 
        Function    : amountExcessCheck()
        Description : This function checks if the amount received exceeds the 
                      actual target amount
    ***************************************************************************/

    function amountExcessCheck(uint receivied_amount,uint previous_contribution, 
                                                 address funder) returns (uint) {
        uint excess_amount;
        amtTrack(receivied_amount,new_target_amount,0);
        // 120 >100
        if (receivied_amount > new_target_amount)  {
            // 20 = 120 -100
            excess_amount = receivied_amount - new_target_amount ; 
            // 0 = 120 - 100 -20 
            new_target_amount =  receivied_amount - new_target_amount - excess_amount; 
            // funder,20
            refund(funder,excess_amount);
            // Payout to the project owner
            payout(); 
        }
        else
        {   // case 1 : 100 > 100 
            // case 2 : 20  < 100
            new_target_amount =  new_target_amount - receivied_amount; 
            // case 1 : 100 - 20  ==> new target is 80
            // case 2 : 100 - 100 ==> new target is 0
            if (new_target_amount == 0) {
                payout();
            }
        }
        return excess_amount;
    }

    /*************************************************************************** 
        Function    : deadlineCheck()
        Description : This function checks the project deadline before accepting 
                      funds.
    ***************************************************************************/    
    function deadlineCheck(uint received_amount,address contrib) returns(bool) {
    bool deadlineMet = false ;
        if  (now > prj_param.deadline)  { // April 7, 2017  > April 3, 2017 ===> Refund
            project_status = false;
            deadlineMet = true;
            refund(contrib,received_amount); // Refund the amount
            // Since the project has passed its timeline, transfer all the individual contributions respectively
            for(uint i=0 ; i <= counter ;i++) {
                address who = map_fund_counter_to_contrib[i].contributor_address;
                uint amount = map_fund_counter_to_contrib[i].contributor_amount;
                contribTracker (who,amount);
                refund(who,amount);
            }
        }
        return deadlineMet;
    }

    /*************************************************************************** 
        Function    : projectStatusCheck()
        Description : This function checks the project status (Live/Ended) before 
                      accepting funds.
    ***************************************************************************/    
    function projectStatusCheck(uint received_amount,address contrib) returns(bool) {
        bool status = false ;
        // If Project status is Ended (false)
        if  (!project_status)     { 
            status = true;
            refund(contrib,received_amount); // Refund the incoming amount to the receiver
            
        }
        return status;
    }

    /*************************************************************************** 
        Function    : projectStatusCheck()
        Description : This function pays out all the funded amount to the project 
                      owner
    ***************************************************************************/    
    function payout() payable returns (bool) {
        bool ret = prj_param.project_owner.send(prj_param.target_amount);
        project_status = false;
        payoutTracker(prj_param.project_owner , prj_param.target_amount,ret);
        if (!ret) return false;
        return true;
    }    

    /*************************************************************************** 
        Function    : projectStatusCheck()
        Description : This function refunds all the amount to the contributor
    ***************************************************************************/    
    function refund(address funder,uint amount) payable returns (bool) {
        bool ret = funder.send(amount);
        refundTracker(funder , amount,ret);
        if (!ret) return false;
        return true;
    }

    /*************************************************************************** 
        Function    : getProjInfo()
        Description : This function gets all the required project details
    ***************************************************************************/    
    
    function getProjInfo() constant returns (string name,
                                             string desc ,
                                             uint target, 
                                             uint deadline,
                                             uint remaining_amount,
                                             bool stat,
                                             address project_Addr) {

       return (prj_param.name,
               prj_param.description, 
               prj_param.target_amount,
               prj_param.deadline,
               new_target_amount,
               project_status,
               prj_param.project_address);
    }
    
    /*************************************************************************** 
        Function    : Fall back function
        Description : just throw so now one manipulates the fallback function
    ***************************************************************************/   
    function () {
        throw;
     }
}

