  1. Using specific compiler pragma 
    Removed the caret ^, so only one compiler version can be used. This will avoid unintended consequence in the future should the contract be compiled with the future version.

  2. Using reentrancy guard
    Inherited from @openzeppelin/contracts/security/ReentrancyGuard.sol" to protect against reentrency attack. This is utilizing Check, Effect, Interaction pattern

  3. Using modifier for validation
    Placed all the requirement checking up before the function implementation