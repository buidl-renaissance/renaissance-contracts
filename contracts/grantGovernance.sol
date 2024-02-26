pragma solidity 0.7.5;
pragma abicoder v2;

import {Ownable} from './dependencies/open-zeppelin/Ownable.sol';
import {SafeMath} from '../dependencies/open-zeppelin/SafeMath.sol';

/**  @title Grant Governance Contract

* - Create a proposal 
* - Revoke a proposal
* - Queue a proposal
* - Submit Vote to a proposal
* - Create fund for a proposal
* - Stake ERC20 tokens or fiat current for a proposal to gain voting powers
* - Adjust voting powers based on tokens staked.

**/

contract GrantGovernance is Ownable{


    uint256 Proposals [];
    


    contructor () {

    }

    struct Proposals{
        uint256 Id;
        string description;
        address creator;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        bool revoked;
        bool queued;

    }

    enum CitizenStatus{
       voter,
       nominator,
       ambassador
    }

    struct Citizen {

        bool isActive;
        uint256 votingPower;
        uint256 tokensStaked;
        uint256 fiatStaked;
        uint256 lastStakedTimestamp;
        CitizenStatus status;
    }

    mapping (address => Citizen) public citizens;

    Proposal[] public proposals;

    event ProposalCreated (uint256 proposalId, string description, address creator)
    event Voted (uint256 proposalId, address msg.sender, bool inFavor) 
    event ProposalExecuted (uint256 proposalId)

    function createProposal (string _description) public returns (uint256){
        uint proposalId = proposals.length
        proposals.push(Proposal(proposalId, _description, msg.sender, 0, 0, false, false, false ))
        event ProposalCreated (proposalId, _description, msg.sender) 
        return proposalId;
    }

    function vote  (uint256 _proposalId, bool _inFavor) public  {
        
        require (citizens[msg.sender].isActive, "You aren't an active citizen")
        require (_proposalId < proposals.length, "Invalid proposal Id")
        require (!proposals[_proposalId].queued, "Proposal is queued")

        require (!proposals[_proposalId].revoked && !proposals[_proposalId].executed, "Proposal is revoked or already executed")

        Proposal stroage proposal = proposals[_proposalId]

        if (_inFavor) {
            proposal[forVotes] = proposal[forVotes] + 1
        }else {
            proposal[againstVotes] = proposal[againstVotes] + 1
        }

        emit Voted(_proposalId, msg.sender, _inFavor);
    }

    function executeProposal (_proposalId) public {

        require (proposalId < proposals.length, "Invalid proposal Id")
        require (!proposals[proposalId].queued, "Proposal is queued")

        require (!proposals[proposalId].revoked, "Proposal is revoked ")
        require (!proposals[proposalId].executed, "Proposal is executed ")

        proposals[_proposalId].executed = true
        event ProposalExecuted (_proposalId)
    }

    function stakeTokens () {
        
    }
}