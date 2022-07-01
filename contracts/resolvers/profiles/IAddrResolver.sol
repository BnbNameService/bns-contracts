// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * Interface for the legacy (BNB-only) addr function.
 */
interface IAddrResolver {
    event AddrChanged(bytes32 indexed node, address a);

    /**
     * Returns the address associated with an BNS node.
     * @param node The BNS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address payable);
}
