import "./IPToken.sol";
import "./ICostModel.sol";
import "./ITrigger.sol";
import "./IAccounting.sol";

interface IMarket is IPToken {

  struct Market {
    ICState state;
    ICostModel costModel;
    IDripDecayModel dripDecayModel;
    ITrigger trigger;
    IAccounting accounting;
    uint16 purchaseFee; // Fee applied on each purchase.
    uint16 cancellationPenalty; // Penalty applied on protection refunds.
  }

  /// @dev Emitted when a user cancels protection. This is a market-level event.
  event Cancellation(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 protection,
    uint256 ptokens,
    address indexed trigger,
    uint256 refund
  );

  /// @dev Emitted when a user claims their protection payout when a market is
  /// triggered. This is a market-level event
  event Claim(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 protection,
    uint256 ptokens,
    address indexed trigger
  );

  /// @dev Emitted when a user purchases protection from a market. This is a
  /// market-level event.
  event Purchase(
    address indexed caller,
    address indexed owner,
    uint256 protection,
    uint256 ptokens,
    address indexed trigger,
    uint256 cost
  );

  /// @notice Devalues all outstanding protection by applying unaccrued decay to the specified market.
  function accrueDecay(address _trigger) external;

  /// @notice Returns the amount of outstanding protection that is currently active for the specified market.
  function activeProtection(address _trigger) external view returns (uint256);

  /// @notice The trigger this token is for. Markets in a set are uniquely identified by their trigger.
  function getTrigger() external view returns (address);

  /// @notice Claims protection payout after the market for `_trigger` is triggered. Pays out the specified amount of
  /// `_protection` held by `_owner` by sending it to `_receiver`.
  function claim(
    address _trigger,
    uint256 _protection,
    address _receiver,
    address _owner
  ) external returns (uint256 _ptokens);

  /// @notice Cancel `_protection` amount of protection for the specified market, and send the refund amount to `_receiver`.
  function cancel(
    address _trigger,
    uint256 _protection,
    address _receiver,
    address _owner
  ) external returns (uint256 _refund, uint256 _ptokens);
}
