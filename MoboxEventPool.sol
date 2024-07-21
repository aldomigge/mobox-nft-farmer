interface IMoboxToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount_) external;
}

contract MoboxEventPool is Ownable {
    using SafeMath for uint256;

    event EventApply(
        address applyer,
        address applyTo,
        uint256 amount,
        uint256 eventAmount,
        uint256 devTeamAmount,
        bytes reason
    ); 

    event EventPoolBurn(
        address bunner,
        uint256 amount,
        bytes reason
    );

    uint256 public constant devTeamRate = 2000;
    address public moboxToken;
    address public finance;
    address public devTeam;
    string public poolName;     // Event/Partner

    constructor() public {

    }

    function init(string memory name_, address mobox_, address finance_) external onlyOwner {
        require(mobox_ != address(0) && finance_ != address(0), "invalid param");
        poolName = name_;
        finance = finance_;
        moboxToken = mobox_;
    }

    modifier onlyFinance() {
        require(msg.sender == finance, "not finance");
        _;
    }

    function setDevTeam(address addr_) external onlyOwner {
        devTeam = addr_;
    }

    function setFinance(address addr_) external onlyFinance {
        require(addr_ != address(0), "invalid addr");
        finance = addr_;
    }

    function applyFor(address to_, uint256 amount_, bytes memory reason_) external onlyFinance {
        require(to_ != address(0) && devTeam != address(0) && reason_.length <= 256, "invalid param");
        uint256 devTeamAmount = amount_.mul(devTeamRate).div(10000);
        uint256 eventAmount = amount_.sub(devTeamAmount);

        IMoboxToken mbox = IMoboxToken(moboxToken);
        mbox.transfer(to_, eventAmount);
        mbox.transfer(devTeam, devTeamAmount);

        emit EventApply(msg.sender, to_, amount_, eventAmount, devTeamAmount, reason_);
    }

    function burn(uint256 amount_, bytes memory reason_) external onlyFinance {
        require(reason_.length <= 256, "invalid param");

        IMoboxToken(moboxToken).burn(amount_);

        emit EventPoolBurn(msg.sender, amount_, reason_);
    }
}