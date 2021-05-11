pragma solidity >=0.6.0 <0.8.0;

import "./Faculty.sol";

contract FacultyFactory {
  Faculty[] public deployedFaculties;
  mapping(string => bool) public nameEntries;
  
  event FacultyCreated(address facultyAddress, string data);

  function createFaculty(string memory _name) public {
    require(!nameEntries[_name], "This name was already taken.");
    Faculty newFaculty = new Faculty(_name, msg.sender);
    nameEntries[_name] = true;
    deployedFaculties.push(newFaculty);
    emit FacultyCreated(address(newFaculty), _name);
  }

  function getDeployedFaculties() public view returns(Faculty[] memory) {
    return deployedFaculties;
  }
}
