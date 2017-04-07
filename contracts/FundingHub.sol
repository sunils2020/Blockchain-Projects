pragma solidity ^0.4.8;

import "./Project.sol";

/*******************************************************************************
 FundingHub Contract : This smart contract is used to create and fund a project.
 Description : It creates project based on the input details and remembers them.
 Functions : 
             1. createProject() - used to create a project
             2. getProjAddr() - gets the project addresses
             3. contribute() - Contribute to particular project
*******************************************************************************/
contract FundingHub {

// Owner of the FundingHub contract
address  contractCreator ;
address[]  projaddr;


// FundingHub constructor
function FundingHub() {
    contractCreator = msg.sender;
 }

 // This struct contains all the required detals of the given project
 struct  projectDetails {string name;
                         string description;
                         address projectOwnerAddress;
                         uint fundingGoal;
                         uint deadline;
                        }
    // Mapping of [Project Address] => Corresponding Struct with project details
    mapping(address => projectDetails) map_prj_address_to_details;      

    // Events for tracking the flow
    event trackSender (address a);
    event trackProjectAddress (address a);
    event trackContributor (address a,uint b);
    event trackProject (string name, string desc, address owner,uint funding_goal, 
                                                                    uint deadline);
    event trackFund(uint a);
                                                                    
  /******************************************************************************
   Function : createProject()
   Description : This function is used to create a project instance based on
                 the input fields provided by the user.
   ******************************************************************************/
  function createProject(string name,
                       string description, 
                       uint fundingGoal, 
                       uint deadline)  returns (address){

    address _owner = msg.sender;
    uint oneEther = 1 ether;

    // Track the one who creates the project
    trackSender(_owner);

    // Create a Project instance for every new project    
    Project obj = new Project (name, 
                               description, 
                               _owner, 
                               fundingGoal*oneEther,
                               deadline);
    
    // trace message to trac the project address
    trackProjectAddress(obj);
    projaddr.push(obj);

    // Mapping of [Project Address] => Corresponding Struct with project details 
    map_prj_address_to_details[obj] = projectDetails(name,
                                                     description,
                                                     _owner,
                                                     fundingGoal*oneEther,
                                                     deadline);

    // track project specific details
    trackProject ( map_prj_address_to_details[obj].name,  
                                    map_prj_address_to_details[obj].description, 
                                    map_prj_address_to_details[obj].projectOwnerAddress,
                                    map_prj_address_to_details[obj].fundingGoal*oneEther, 
                                    map_prj_address_to_details[obj].deadline);
    
    return obj; // Address is returned. This can be shown in UI
      
   }

  /******************************************************************************
   Function : getProjAddr()
   Description : This function returns all the project addresses
   ******************************************************************************/
   function getProjAddr() returns ( address[]) {
      return projaddr;
  }
 
  /******************************************************************************
   Function : contribute()
   Description : This function is used to fund any of the registered  project
   ******************************************************************************/
 function contribute (address projectAddress) payable returns (bool) {

    if(msg.value == 0) return false;
    var a = map_prj_address_to_details[projectAddress];
    trackProject ( a.name,  
                                    a.description, 
                                    a.projectOwnerAddress,
                                    a.fundingGoal, 
                                    a.deadline);
    bool isFailure = Project(projectAddress).fund.value(msg.value)();
    return isFailure;
    }
}

