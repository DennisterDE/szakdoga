// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mail {




    struct Email {
        address sender;
        address receiver;
        string subject;
        string message;
        uint256 timestamp;
    }

    mapping(address => Email[]) public inbox;
    mapping(address => Email[]) public sent;


    event EmailSent(
        address indexed sender,
        address indexed receiver,
        string subject,
        uint256 timestamp
    );

    function sendEmail(address _receiver, string memory _subject, string memory _message) public {
        require(_receiver != address(0), "Receiver address cannot be zero");
        require(msg.sender != _receiver, "Cannot send an email to yourself");

        Email memory newEmail = Email({
            sender: msg.sender,
            receiver: _receiver,
            subject: _subject,
            message: _message,
            timestamp: block.timestamp
        });

        inbox[_receiver].push(newEmail);
        sent[msg.sender].push(newEmail);

        emit EmailSent(msg.sender, _receiver, _subject, block.timestamp);
    }

    function getEmailCount(address _user) public view returns (uint256 inboxCount, uint256 sentCount) {
        inboxCount = inbox[_user].length;
        sentCount = sent[_user].length;
    }


  function getEmailsReceived() public view returns (Email[] memory) {
        Email[] memory emails = inbox[msg.sender];
        uint256 count = emails.length;
        Email[] memory senderEmails = new Email[](count);
        uint256 senderEmailsCount = 0;

        for (uint256 i = 0; i < count; i++) {
            if (emails[i].sender == msg.sender) {
                senderEmails[senderEmailsCount] = emails[i];
                senderEmailsCount++;
            }
        }

        // Resize the senderEmails array to the actual count of sender's emails
        assembly {
            mstore(senderEmails, senderEmailsCount)
        }

        return senderEmails;
    }


    function createAndAddMockEmails(address _receiver, uint256 _numberOfEmails) public {
        require(_numberOfEmails > 0, "Number of emails must be greater than 0");
        
        for (uint256 i = 0; i < _numberOfEmails; i++) {
            string memory subject = string(abi.encodePacked("Mock Email #", uintToString(i)));
            string memory message = string(abi.encodePacked("This is a mock email #", uintToString(i)));
            
            inbox[_receiver].push(Email(msg.sender, _receiver, subject, message,block.timestamp));
        }
    }

    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 j = v;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (v != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(v - v / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            v /= 10;
        }
        return string(bstr);
    }
}