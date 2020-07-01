pragma solidity >=0.4.24;

import "./Pausable.sol";
import "./Destructible.sol";
import "./Activatable.sol";

contract GameShop is Destructible, Pausable, Activatable {

	uint public fee;

	mapping (uint => address) itemToBuyer;
	mapping (uint => bool) paidToExhibitor;

	struct Item {
		address payable exhibitor;
		uint price;
	}

	Item[] public items;

	event RegisterItem(
		uint _id,
		address _exhibitor,
		uint _price
	);
	event BuyItem(
		uint _id,
		address _buyer
	);
	event PayToExhibitor(
		address _exhibitor,
		uint amountPaid
	);
	event RefuncdToOwner(
		address _owner,
		uint _refundBalance
	);

	function setFee(uint _newFee) external onlyOwner {
		require(_newFee > 0);

		fee = _newFee;
	}

	function registerItem(uint _price) external whenNotPaused {
		require(_price > 0);

		items.push(Item(msg.sender, _price));
		uint id = items.length - 1;
		emit RegisterItem(id, msg.sender, _price);
	}

	function buyItem(uint _id) external whenNotPaused {
		require(itemToBuyer[_id] != address(0));

		itemToBuyer[_id] = msg.sender;
		emit BuyItem(_id, msg.sender);
	}

	function payToExhibitor(uint _id) external onlyOwner {
		Item memory item = items[_id];

		require(!paidToExhibitor[_id]);
		require(item.price > fee);
		require(address(this).balance > (item.price - fee));
		require(item.exhibitor != owner);

		paidToExhibitor[_id] = true;
		item.exhibitor.transfer(item.price - fee);
		emit PayToExhibitor(item.exhibitor, item.price - fee);
	}

	function refundToOwner() external whenNotActive onlyOwner {
		require(address(this).balance > 0);

		uint refundBalance = address(this).balance;
		owner.transfer(refundBalance);
		emit RefuncdToOwner(msg.sender, refundBalance);
	}

}