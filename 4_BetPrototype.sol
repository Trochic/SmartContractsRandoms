// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

/* Prototype of a smart contract that allow Betting for example on a football team, you can either chose TeamA, TeamB or Draw. Winners get Losers bid. */
/* Entirely created by me */
/* Inspired from "Predictions" on pancakeswap.finance */

contract BetPrototype {
    
    address public adminAddress;
    uint public actualRound = 0;
    uint public amountWinner = 0;
    uint public amountLoser = 0;
    uint public currentAmount = 0;
    
    
    enum Bet {TeamA, TeamB, Draw, None}
    
    /* Round structure, contians every information needed for a round */

    struct Round {
        uint totalAmount;
        uint amountTeamA;
        uint amountTeamB;
        uint amountDraw;
        bool closed;
        Bet winSide;
    }
    
    /* Player structure */
    struct Player {
        Bet betSide;
        uint betAmount;
        bool claimed;
    }
    
    /* Creating the ledgers which we'll use to store rounds, and store players */
    mapping(uint => Round) public rounds; 
    mapping(address => Player) public players;
    
    
    constructor(address _adminAddress) {
        adminAddress = _adminAddress;
    }
    
    modifier onlyAdmin {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }
    
    modifier isRoundOpen {
        require(rounds[actualRound].closed == false, "Round closed");
        _;
    }

    modifier isRoundFinished {
        require(rounds[actualRound].closed == true, "Round is not finished");
        _;
    }
    
    function updateCurrentAmount(uint amount) internal {
        currentAmount += msg.value;
        currentAmount -= amount;
    }
    

    /* Allows admin to create a new round, requires actual round to be closed before */
    function createRound() public onlyAdmin isRoundFinished {
        Round storage round = rounds[actualRound++];
        round.totalAmount = 0;
        round.amountTeamA = 0;
        round.amountTeamB = 0;
        round.amountDraw = 0;
        round.closed = false;
        round.winSide = Bet.None;
    }
    
    /* Public functions allowing someone to bet on Team A*/

    function betTeamA() public payable isRoundOpen {

        /* Updates players ledger */
        players[msg.sender] = Player(Bet.TeamA, msg.value, false);
        
        /* Updates round + round ledger */
        Round storage round = rounds[actualRound];
        round.totalAmount += msg.value;
        round.amountTeamA += msg.value;
        rounds[actualRound] = round;
        updateCurrentAmount(0);
    }
    /* Same as betTeamA() */
    function betTeamB() public payable isRoundOpen {
        players[msg.sender] = Player(Bet.TeamB, msg.value, false);
        
        
        Round storage round = rounds[actualRound];
        round.totalAmount += msg.value;
        round.amountTeamB += msg.value;
        updateCurrentAmount(0);
    }
    
    /*Same as betTeamA() */
    function betDraw() public payable isRoundOpen {
        players[msg.sender] = Player(Bet.Draw, msg.value, false);
        
        
        Round storage round = rounds[actualRound];
        round.totalAmount += msg.value;
        round.amountDraw += msg.value;
        updateCurrentAmount(0);
    }
    
    /*Allows admin to close the round and deciding who wins */
    function closeRound(Bet winSide) public onlyAdmin {
        rounds[actualRound].closed = true;
        rounds[actualRound].winSide = winSide;
        if (winSide == Bet.TeamA) {
            amountWinner = rounds[actualRound].amountTeamA;
            amountLoser = rounds[actualRound].amountTeamB + rounds[actualRound].amountDraw;
        }
        else if (winSide == Bet.TeamB) {
            amountWinner = rounds[actualRound].amountTeamB;
            amountLoser = rounds[actualRound].amountTeamA + rounds[actualRound].amountDraw;
        }
        else {
            amountWinner = rounds[actualRound].amountDraw;
            amountLoser = rounds[actualRound].amountTeamA + rounds[actualRound].amountTeamB;
        }
        
    }
    
    /* Calculate rewards for a payer */
    function calculateRewards(Player storage claimer) internal view returns(uint) {
        require(rounds[actualRound].winSide != Bet.None, "Round not finished");
        Bet winSide = rounds[actualRound].winSide;
        
        /* Checks side, and determines the amount claimer won, there are no float numbers in solidity */
        if (claimer.betSide == winSide) {
            uint prctAllocated = (claimer.betAmount*10000*100 / amountWinner*10000) / 1000000;
            uint amountWinned = (prctAllocated * (amountWinner+amountLoser)) / 10000;
            return amountWinned;
        }
        else {
            return 0;
        }
    }
    
    /* Callable function to claim rewards */
    function claimRewards() public isRoundFinished {
        require(players[msg.sender].claimed == false, "Already claimed");
        Player storage claimer = players[msg.sender];
        uint amount = calculateRewards(claimer);
        payable(msg.sender).transfer(amount);
        players[msg.sender].claimed = true;
        updateCurrentAmount(amount);
        
    }
    
    
}