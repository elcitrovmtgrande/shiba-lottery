// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ShibaLottery {
    // Adresses du propriétaire du contrat, du token SHIBA INU utilisé pour la loterie et de l'organisme de bienfaisance
    address public owner;
    address public charityAddress;
    //TODO: Change it by real ERC-20 shiba inu before production
    address public constant SHIBA_INU_ADDRESS =
        0xd91Ba5F8d577424C411F50CB3E215bcF5245d2a3;
    // 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    address public constant DEAD_ADDRESS =
        0x0000000000000000000000000000000000000000;

    uint256 public totalBurnt;
    uint256 public cashPrize;
    uint256 public ticketPrice;

    uint8 public burnPercentage;
    uint8 public charityPercentage;

    // Struct representing a ticket
    struct Ticket {
        address owner;
        uint256 value;
    }
    struct Winner {
        address winner;
        uint256 value;
    }

    Ticket[] public tickets;
    Winner[] public winners;

    // Événements déclenchés lorsqu'un ticket est acheté ou lorsqu'un tirage a lieu
    event NewTicket(address indexed buyer, uint256 ticketsNb);
    event NewDraw(uint256 drawId, address winner, uint256 winnings);

    // Constructeur du contrat
    constructor(
        uint256 _ticketPrice,
        uint8 _burnPercentage,
        uint8 _charityPercentage,
        address _charityAddress
    ) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        burnPercentage = _burnPercentage;
        charityPercentage = _charityPercentage;
        charityAddress = _charityAddress;
        cashPrize = 22031996;
    }

    // Achete un ticket pour le tirage en cours
    function buyTicket() public payable {
        // Vérifie que le prix du ticket est respecté
        require(msg.value == ticketPrice, "Ticket price is not valid.");

        // Vérifie que l'expéditeur a suffisamment de tokens SHIBA INU
        ERC20 shibaInu = ERC20(SHIBA_INU_ADDRESS);
        require(
            shibaInu.balanceOf(msg.sender) >= ticketPrice,
            "Buyer does not have enough of SHIBA INU tokens."
        );

        uint256 toBeBurnt = ticketPrice * (burnPercentage / 100);
        uint256 toCharity = ticketPrice * (charityPercentage / 100);
        uint256 toCashPrize = ticketPrice - toBeBurnt - toCharity;

        // Incrémente le nombre de tickets vendus et le montant du gain potentiel pour le tirage en cours
        cashPrize += toCashPrize;

        // Create a new ticket
        Ticket memory ticket = Ticket({owner: msg.sender, value: ticketPrice});

        // Save the ticket
        tickets.push(ticket);

        // Burn de 20% du prix du ticket
        shibaInu.transferFrom(msg.sender, DEAD_ADDRESS, toBeBurnt);
        totalBurnt += toBeBurnt;

        // Sauvegarde 10% pour les oeuvres
        shibaInu.transferFrom(msg.sender, charityAddress, toCharity);

        // Transfere les tokens SHIBA INU a gagner (70%) du ticket à l'adresse du contrat
        shibaInu.transferFrom(msg.sender, address(this), toCashPrize);

        // Émet un événement pour signaler l'achat du ticket
        emit NewTicket(msg.sender, tickets.length);
    }

    /**
     * Effectue un tirage et désigne le gagnant
     */
    function draw() public {
        // Vérifie que seul le propriétaire du contrat peut effectuer un tirage
        require(
            msg.sender == owner,
            "You are not allowed to do this operation."
        );

        // Vérifie qu'il y a au moins un ticket en vente pour le tirage en cours
        require(tickets.length > 0, "No ticket registered for this draw.");

        // Choisit un gagnant au hasard parmi les tickets vendus
        uint256 winnerIndex = randomIndex();
        address winnerAddress = tickets[winnerIndex].owner;

        // Calcul le montant du gain

        // Envoie le gain au gagnant
        ERC20 shibaInu = ERC20(SHIBA_INU_ADDRESS);
        shibaInu.transfer(winnerAddress, cashPrize);

        // Enregistrement du gagnant
        Winner memory winner = Winner({
            winner: winnerAddress,
            value: cashPrize
        });
        winners.push(winner);

        // Réinitialise les tickets en vidant le tableau
        delete tickets;

        // Réinitialisation du cash prize
        cashPrize = 0;

        // Émet un événement pour signaler le tirage et annoncer le gagnant
        // emit NewDraw(winner, winner, winnings);
    }

    /**
     * Permet de changer le montant du ticket
     */
    function changeTicketPrice(uint8 updatedPrice) public {
        // Vérifie que seul le propriétaire du contrat peut effectuer un tirage
        require(
            msg.sender == owner,
            "You are not allowed to change de thicket price."
        );

        ticketPrice = updatedPrice;
    }

    // Renvoie le nombre de tickets vendus pour le tirage en cours
    function getTicketCount() public view returns (uint256) {
        return tickets.length;
    }

    // Renvoie le montant du gain potentiel pour le tirage en cours
    function getCashPrize() public view returns (uint256) {
        return cashPrize;
    }

    // Renvoie le nombre total de tokens SHIBA INU brûlés depuis la création du contrat
    function getTotalBurnt() public view returns (uint256) {
        return totalBurnt;
    }

    function randomIndex() private view returns (uint256) {
        return
            1 +
            (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                tickets.length);
    }
}
