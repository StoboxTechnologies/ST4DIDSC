// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";

contract SDID is AccessControlEnumerable {
    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 public constant ATTRIBUTE_READER_ROLE = keccak256("ATTRIBUTE_READER_ROLE");

    error CantRevokeLastSuperAdmin();

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _revokeRole(bytes32 role, address account) internal override returns (bool revoked) {
        if (role == DEFAULT_ADMIN_ROLE) {
            require(getRoleMemberCount(role) > 1, CantRevokeLastSuperAdmin());
        }
        revoked = super._revokeRole(role, account);
    }
}
