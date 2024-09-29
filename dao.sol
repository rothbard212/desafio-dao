// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOToken {
    string public name = "DAO Token";
    string public symbol = "DAO";
    uint8 public decimals = 18;
    uint public totalSupply = 1000000 ether;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;  // Inicializa com todos os tokens para o criador
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address to, uint value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        allowance[from][msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract DAO {
    address public chairperson;
    DAOToken public daoToken;

    struct Proposal {
        string description;
        uint voteCount;
        bool executed;
    }

    Proposal[] public proposals;

    mapping(address => bool) public members;
    mapping(address => mapping(uint => bool)) public voted;  // Votos por membro por proposta

    constructor(address _tokenAddress) {
        chairperson = msg.sender;
        daoToken = DAOToken(_tokenAddress);
    }

    event ProposalCreated(uint proposalId, string description);
    event Voted(uint proposalId, address voter, uint weight);
    event ProposalExecuted(uint proposalId);

    modifier onlyMembers() {
        require(members[msg.sender], "Only members can perform this action");
        _;
    }

    function joinDAO() public {
        require(daoToken.balanceOf(msg.sender) > 0, "You must hold DAO tokens to join");
        members[msg.sender] = true;
    }

    function createProposal(string memory description) public onlyMembers {
        proposals.push(Proposal({ description: description, voteCount: 0, executed: false }));
        emit ProposalCreated(proposals.length - 1, description);
    }

    function vote(uint proposalId) public onlyMembers {
        require(!voted[msg.sender][proposalId], "Already voted");
        require(!proposals[proposalId].executed, "Proposal already executed");

        Proposal storage proposal = proposals[proposalId];
        uint weight = daoToken.balanceOf(msg.sender);

        proposal.voteCount += weight;
        voted[msg.sender][proposalId] = true;

        emit Voted(proposalId, msg.sender, weight);
    }

    function executeProposal(uint proposalId) public onlyMembers {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount > 0, "No votes to execute");

        proposal.executed = true;
        emit ProposalExecuted(proposalId);

        // Lógica de execução do projeto (ex: alocar fundos, iniciar projeto, etc.)
    }
}
