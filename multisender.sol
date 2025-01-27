// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

//The interface of IERC20
interface IERC20 { 
    
function approve(address spender, uint256 amount) external returns (bool); 
function transferFrom(address sender,address recipient,uint256 amount) external returns (bool); 

}

//Contract Creation
contract MultiTransfer { 
    
    address owner;
    
    //Creation of the mapping
    mapping(address => uint256) public balances;
    IERC20 Token;
    
    //Creation of the constructor
    constructor(IERC20 _token){
        owner = msg.sender;
        Token = _token;
    }
    
    //Defining of the function
    //This function is for transfering token to multiple addresses
    
    function multiTransfer(address[] memory _addresses, uint256 [] memory _amount) external { 
      
      require(msg.sender == owner,"Only owner can deploy this function");
      
      //Using for loop for the array of addresses length
      for(uint i = 0; i < _addresses.length; i++){
         
         //Transfering the token from owner the the array of addresses  
        Token.transferFrom(msg.sender, _addresses[i], _amount[i]);
    }
} 

    //This function is for transfering token to single address
    function singleTransfer(IERC20 _token,address _address,uint _amount) public{
          
         //Using ERC20 transferFrom function to transfer the function
         _token.transferFrom(msg.sender,_address,_amount);
         
         //Copying the data from amount variable to the balances mapping of msg.sender
         balances[msg.sender] += _amount; 
        
    }
}