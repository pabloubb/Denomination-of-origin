// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract TestIterableMap {
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;

    /*
        The map positions could be the information that the "denomination of origin" label contains, 
        for example in this example it would be: 

            [grapeType, wineWarehouse, transportCompany, supplier]

        And it would contain the following codes (which can be the identifying code for each attribute):

            [13,125467,232466,336246]

    */
    function testIterableMap() public {
        map.set(address(0), 13);
        map.set(address(1), 125467);
        map.set(address(2), 232465); // bad insert (it would be 232466)
        map.set(address(2), 232466); // update
        map.set(address(3), 336246);

        //  Iteration
        for (uint256 i = 0; i < map.size(); i++) {
            address key = map.getKeyAtIndex(i);

            assert(map.get(key) != 0);
        }

        //  You can remove one field (wineWarehouse "address(1)")
        map.remove(address(1));

        // keys = [grapeType "address(0)", transportCompany "address(2)", supplier "address(3)"]
        assert(map.size() == 3);
        assert(map.getKeyAtIndex(0) == address(0));
        assert(map.getKeyAtIndex(1) == address(3));
        assert(map.getKeyAtIndex(2) == address(2));
    }
}
