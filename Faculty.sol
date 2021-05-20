// SPDX-License-Identifier:UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;


import "github/OpenZeppelin/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "./Course.sol";

contract Faculty is AccessControl {
  bytes32 public constant TEACHER_ROLE = keccak256("Teacher");
  string name;
  Course[] public courses;
  address[] public teachers;
  mapping(address => string) public teacherNames;
  
  
  event ETHDonation(address from, address to, string message);

  constructor (string memory _name, address _admin) public {
    name = _name;
    _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    _setRoleAdmin(TEACHER_ROLE, DEFAULT_ADMIN_ROLE);
  }
  
  function createCourse(string memory _courseName, string memory _teacherName) public onlyTeacher {
      Course newCourse = new Course(msg.sender, address(this), _courseName, _teacherName);
      
      courses.push(newCourse);
  }
  
  /*
  As it is, the function can fail if it doesn't have enough ETH in its balance and so
  if this happens, some eligible students might not receive their rewards and also they'd get
  wiped from the eligible list. A better approach would be to seperate the concerns, having a 
  function to retrieve the eligible list ( and counting every eligible student from all courses
  then checking if that number times amountForEach is smaller than the balance) and a different 
  function that resets the eligible list of students.
  */
  function sendRewards(uint amountForEach) public onlyAdmin {
      uint courseLength = courses.length;
      
      for(uint i = 0; i < courseLength; i++) {
          Course course = courses[i];
          
          address[] memory beneficiaries = course.getRewardsEntryAndReset();
          uint beneficiariesLength = beneficiaries.length;
          
          for(uint j = 0; j < beneficiariesLength; j++) {
              address payable beneficiary = payable(beneficiaries[j]);
              beneficiary.transfer(amountForEach * 1 ether);
          }
      }
  }
  
  function getDeployedCourses() public view returns(Course[] memory) {
      return courses;
  }
  
  function contributeETH(string memory message) public payable {
      emit ETHDonation(msg.sender, address(this), message);
  }
    
  function getBalanceInWei() view public returns(uint){
      return address(this).balance;
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender), "Restricted to admins!");
    _;
  }

  modifier onlyTeacher() {
    require(isTeacher(msg.sender), "Restricted to teachers!");
    _;
  }

  function isTeacher(address account) public virtual view returns(bool) {
    return hasRole(TEACHER_ROLE, account);
  }

  function isAdmin(address account) public virtual view returns(bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, account);
  }
  
  function getName() public view returns(string memory) {
    return name;
  }

  function addTeacher(address account, string memory _teacherName) public virtual onlyAdmin {
    grantRole(TEACHER_ROLE, account);
    teachers.push(account);
    teacherNames[account] = _teacherName;
  }
  
  function getTeachers() public view returns(address[] memory) {
      return teachers;
  }
 
  function addAdmin(address account) public virtual onlyAdmin {
    grantRole(DEFAULT_ADMIN_ROLE, account);
  }

  function removeTeacher(address account) public virtual onlyAdmin {
    revokeRole(TEACHER_ROLE, account);
  }
}
