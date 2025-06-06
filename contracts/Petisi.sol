// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/Iprofile.sol";

contract Petisi is Ownable { 
    IProfile private profileContract;

    constructor(address _profileContract) Ownable(msg.sender){
        profileContract = IProfile(_profileContract);
    }

    struct Proposal {
        uint256 id;
        string title;
        string description;
        uint256 votes;
        string imgUrl;
        uint256 deadline;
        address author;
        string usernameAuthor;
        string imgAuthore;
        uint256 created;
    }

    uint256 counterProposal = 0;
    // event
    event proposalCreated(uint256 id, string title, string description, uint256 votes, string _imgUrl, uint256 _deadline,address author);
    event SignSuccess(bool _isVoted);
    // mapping
    mapping (address => Proposal[]) public myProposal;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping (address => bool)) public hasvoted;
    mapping (uint256 => address[]) public voter;
    
    // array
    Proposal[] public proposalList;

    modifier onlyRegisterd(){
        IProfile.profile memory profileTemp =  profileContract.getProfile(msg.sender);
        require(profileTemp.isRegistered, "You have to Registerd");
        _;
    }

    modifier onlyHasNoVoted(uint _id){
        require(!hasvoted[_id][msg.sender], "You are already Voted!");
        _;      
    }

    function createProposal(string memory _title, string memory _description, string memory _imgUrl, uint256 _deadline) onlyRegisterd public {
        string memory usernameUser =  profileContract.getUsernameProfile(msg.sender);
        string memory imgUser =  profileContract.getImgProfile(msg.sender);
        Proposal memory newProposal = Proposal(counterProposal, _title, _description, 0, _imgUrl, _deadline, msg.sender, usernameUser, imgUser, block.timestamp) ;
        proposals[counterProposal] = newProposal;
        myProposal[msg.sender].push(newProposal);
        proposalList.push(proposals[counterProposal]);
        emit proposalCreated(counterProposal, _title, _description, 0, _imgUrl, _deadline, msg.sender);
        counterProposal++;
    }

    function gerAllProposal() public view returns (Proposal[] memory){
        return proposalList;
    }

    function getMyProposal(address _user) public view returns (Proposal[] memory){
        return myProposal[_user];
    }

    function getProposal(uint256 _id) public view returns(Proposal memory){
         return proposals[_id];
      
    }

    function signing(uint256 _id) public onlyRegisterd onlyHasNoVoted(_id){
        proposals[_id].votes += 1;
        proposalList[_id].votes = proposals[_id].votes ;
        hasvoted[_id][msg.sender] = true;
        voter[_id].push(msg.sender);
        emit SignSuccess(hasvoted[_id][msg.sender]);
    }

    function getSigner(uint256 _id) public view returns (address[] memory){
        return voter[_id];
    }

}
