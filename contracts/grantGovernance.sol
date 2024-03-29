pragma solidity 0.8.21;
pragma abicoder v2;

import {Ownable} from './dependencies/open-zeppelin/Ownable.sol';
import {SafeMath} from './dependencies/open-zeppelin/SafeMath.sol';

/**  @title Grant Governance Contract

* - Create a proposal 
* - Revoke a proposal
* - Queue a proposal
* - Submit Vote to a proposal
* - Stake ERC20 tokens or fiat currency for a proposal to gain voting powers
* - Adjust voting powers based on tokens staked.

**/

contract GrantGovernance is Ownable {

    struct Proposals{
        uint256 Id;
        string title;
        string description;
        string category;
        string body;
        string estBudget;
        address creator;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 tokensStaked;
        bool executed;
        bool revoked;
    }

    enum CitizenStatus{
       NEWBIE,
       VOTER,
       NOMINATOR,
       AMBASSADOR
    }

    struct Citizen {
        bool isActive;
        CitizenStatus status;
        uint256 votingPower;
    }

    struct StakePerCitizen{
        uint256 tokensStaked;
        uint256 fiatStaked;
        uint256 lastStakedTimestamp;
    }
    

    mapping (address => Citizen) public citizens;

    // every proposal will have map of stakes for citizens that have staked tokens
    mapping (uint256 => mapping (address => StakePerCitizen)) public stakePerCitizen;

    Proposals[] public  proposals;

    event ProposalCreated (uint256 indexed proposalId, string title, address creator);
    event Voted (uint256 indexed proposalId, address indexed voter, bool inFavor);
    event ProposalExecuted (uint256 indexed proposalId, bool executed);
    event TokensStaked (uint256 indexed proposalId, address indexed staker, uint256 amount);

    function createProposal (string memory _title, string memory _description, string memory _category, string memory _body, string memory _estBudget) public returns (uint256){
        uint proposalId = proposals.length;
        proposals.push(Proposals(proposalId, _title, _description, _category, _body, _estBudget, msg.sender, 0, 0, 0, false, false ));
        emit ProposalCreated (proposalId, _title, msg.sender);
        return proposalId;
    }

    function getProposal (uint256 _proposalId) public view returns (Proposals memory){
        return proposals[_proposalId];
    }

    function getProposals () public view returns (Proposals [] memory){
        return proposals;
    }

    function vote (uint256 _proposalId, bool _inFavor) public  {
        
        require (_proposalId < proposals.length, "Invalid proposal Id");

        require (!proposals[_proposalId].revoked && !proposals[_proposalId].executed, "Proposal is revoked or already executed");

        Proposals storage proposal = proposals[_proposalId];

        if (_inFavor) {
            proposal.forVotes = proposal.forVotes + 1;
        }else {
            proposal.againstVotes = proposal.againstVotes + 1;
        }

        emit Voted(_proposalId, msg.sender, _inFavor);
    }

    function executeProposal (uint256 _proposalId) public {

        require (_proposalId < proposals.length, "Invalid proposal Id");

        require (!proposals[_proposalId].revoked, "Proposal is revoked ");
        require (!proposals[_proposalId].executed, "Proposal is executed ");

        Proposals storage proposal = proposals[_proposalId];

        if (proposal.forVotes > proposal.againstVotes){
            proposal.executed = true;
        }

        emit ProposalExecuted (_proposalId, proposal.executed);
    }

    function stakeTokens (uint256 _proposalId, uint256 _amount) public{

        require (_amount > 0, "Amount should be greater than 0");

        require (!proposals[_proposalId].revoked, "Proposal is revoked ");
        require (!proposals[_proposalId].executed, "Proposal is already executed ");

        citizens[msg.sender].votingPower += _amount;
        stakePerCitizen[_proposalId][msg.sender].tokensStaked += _amount;
        stakePerCitizen[_proposalId][msg.sender].lastStakedTimestamp = block.timestamp;
        citizens[msg.sender].isActive = true;

        proposals[_proposalId].tokensStaked += _amount;
        
        emit TokensStaked (_proposalId, msg.sender, _amount);
    }

}