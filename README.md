# Module 8 - Beginner Lab: Creating A Faucet

** Note: This lab assumes the older interface for Remix IDE. The updated faucet8.sol code is the latest code with events from Chapter 7

## Background
This lab will go over the creation of a faucet smart contract. A faucet is a free source of tokens.

## Meta Information
| Attribute | Explanation |
| - | - |
| Summary | This assignment involves creating, deploying, and interacting with a faucet smart contract. |
| Topics | Smart contracts, faucets, tokens. |
| Audience | Appropriate for CS1 or a later course. |
| Difficulty | Beginner. |
| Strengths | This assignment exposes students to popular technology (blockchain) and some of its features. |
| Weaknesses | It may be difficult for students to extend smart contracts without programming knowledge and familiarity with the Solidity programming language. |
| Dependencies | Some programming knowledge and an internet-connected computer with a suitable browser (with [MetaMask][MetaMask] installed) for use of [the Remix IDE][Remix]. |
| Variants | Could be used to introduce smart contracts, tokens, or use of general-purpose blockchains. |

## Assignment Instructions
1. Navigate to [https://remix.ethereum.org][Remix].
    * This is our development environment. Here, we can write smart contracts and test them.
2. Click on the "+" at the top left corner of the screen.
    * This will create a new empty document to begin development.
3. Name the document `faucet.sol`.
4. In the blank document, add the following code:
    ```solidity
    // Version of Solidity compiler this program was written for
    pragma solidity ^0.5.1;
    ```
    * This piece of information allows the Solidity compiler to know what set of rules it should use when compiling the contract into bytecode.
5. Now we will add the meat of the contract. Below the previous code snippet, add the following:
    ```solidity
    contract Faucet {
        // Give out ether to anyone who asks
        function withdraw(uint withdraw_amount) public {
            // Limit withdrawal amount
            require(withdraw_amount <= 100000000000000000);
            require(address(this).balance >= withdraw_amount, "Insufficient balance in faucet for withdrawal request");

            // Send the amount to the address that requested it
            msg.sender.transfer(withdraw_amount);
        }

        // Accept any incoming amount
        function () external payable {}
    }
    ```
    * This code represents a faucet, which will allow anyone to pay it any amount of ETH and will give anyone freely from its reserve any amount requested, provided that it is less than or equal to 100000000000000000 wei (17 zeros).
6. We can make the `withdraw_amount` maximum a little more clear by using a keyword. Go ahead and change `100000000000000000` to `0.1 ether` (same amount of currency as before, just easier on the eyes).
    * This contract seems great, but what if, for whatever reason, we wanted to get rid of it (and have the funds return to our account in full)? For this reason, we will add a way to destroy the contract using `selfdestruct` (it would otherwise be immortal, and no-one in the world would have the power to destroy it). However, we also don't want just anyone to be able to destroy the faucet and recover the funds, so let's have it check that the entity requesting this action is in fact the owner (in this case, us).
7. Inside of the Faucet contract, add a variable `address owner;`. This will allow the contract to remember whom we are and to know that we have the authority to command its immediate destruction (and deposit of sweet ether into our account).
8. Adding this variable is not enough alone, though. Next, we'll want to add a constructor (preferably just below that variable declaration) to assign to it our EOA (Externally Owned Account), which is just our wallet address. It should look like this:
    ```solidity
    // Contract constructor: set owner
    constructor() public {
        owner = msg.sender;
    }
    ```
    * Done? Nope. Sure, now it knows who we are, but here's a funfact: if we don't include the code to actually have it self destruct, it is just not capable of doing so. It will know our address and live forever... Cool, but not what we're going for.
9. The way we're going to have this thing die (did I mention the ether?) involves declaring another function, which we could name whatever we want (let's go with `destroy`) so long as it eventually calls `selfdestruct`. Let's do it (add the following):
    ```solidity
    // Contract destructor
    function destroy() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }
    ```
9. Now we should have a faucet contract that looks something like this:
    ```solidity
    // Version of Solidity compiler this program was written for
    pragma solidity ^0.5.1;

    contract Faucet {
        address owner;

        // Contract constructor: set owner
        constructor() public {
            owner = msg.sender;
        }

        // Contract destructor
        function destroy() public {
            require(msg.sender == owner);
            selfdestruct(msg.sender);
        }

        // Give out ether to anyone who asks
        function withdraw(uint withdraw_amount) public {
            // Limit withdrawal amount
            require(withdraw_amount <= 0.1 ether);
            require(address(this).balance >= withdraw_amount, "Insufficient balance in faucet for withdrawal request");

            // Send the amount to the address that requested it
            msg.sender.transfer(withdraw_amount);
        }

        // Accept any incoming amount
        function () external payable {}
    }
    ```
10. Alright, are you ready to give away money? Well, calm down. There's still work to do... Go ahead and click **Start to compile (Ctrl-S)** and see if you get any errors (it's usually something small like forgetting to end a line with a semicolon (`;`). No (more) errors? Great (finally)!
11. In the top right, select the **Run** tab. All settings should be the same as for a previous lab, but in the box above the **Deploy** button, it should say **Faucet**. If so, go ahead and click the **Deploy** button.
    * (You will need to confirm the pending transaction in MetaMask, but it should pop up.)
13. In MetaMask, find the most recent transaction. It should say **Contract Deployment** and _confirmed_. Click on that and scroll down. To the right of **Details** you should see an up-and-to-the-right arrow. This will take you to [etherscan][Etherscan]. There you should see (or, if you just clicked on the blue thing in the last sentence, be able to search for (with your address)) the transaction wherein your contract was created.
14. Click on the line that looks like \[Contract 0x... Created\]. That'll take you to a page where the contract is the main focus. At the top of the page, there should be a little copy icon that looks like two pieces of paper, just to the right of the address. Click it. The address of the contract should be copied to your virtual clipboard now.
15. Okay, _now_ it's time to give away money. In MetaMask, click on **SEND** and then where it says **Recipient Address**, you'll want to paste (Ctrl-V) the address you just copied a moment ago.
16. Next, set the amount to something reasonable, like 0.5 ETH. Click **NEXT**. If everything looks fine (not 50 ETH), go ahead and click **CONFIRM**. Then just wait for the transaction to go through.
17. Back in [Remix][Remix], within the **Transactions recorded** area, you should see something like **Faucet at 0x... (blockchain)**. Open that up (click on it) and you should see the names of the functions we wrote (`destroy`, `withdraw`...).
18. In the box beside withdraw, enter an amount less than 100000000000000000, and then click withdraw. Once you allow the pending transaction in MetaMask and it goes through, your account should have that much ETH returned to it (minus the transaction fee, which could very well be more than you asked for back).
    * Sidenote: you didn't think we were actually going to give money away to _other_ people, did you? But you could... Anyway, as I'm sure the reader knows, we're only playing around with test ether at the moment, but it's fun to pretend.
19. If you want the rest of your ether back (without numerous transaction fees and waiting for every 0.1 ETH increment to go through), you can just click destroy, and when it's done (remember to allow it in MetaMask), your account should be back to its original balance, a little worse for wear...

## Credits
Dr. Debasis Bhattacharya  
Mario Canul  
Saxon Knight  
https://github.com/ethereumbook/ethereumbook  

[Remix]: https://remix.ethereum.org/
[Etherscan]: https://rinkeby.etherscan.io/
[MetaMask]: https://metamask.io/
