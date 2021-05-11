pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "github/OpenZeppelin/openzeppelin-contracts/contracts/access/AccessControl.sol";
contract Course is AccessControl {

    struct laboratory {
        //uint number;
        string instructions; // IPFS file
        bool open;
        mapping(address => uint) mark;
        mapping(address => string) submission;
    }
    
    address faculty;
    address[] rewardsEntry;
    uint[] laboratoryNumberList;
    mapping(uint => laboratory) laboratoryList;
    string[] studentList;
    mapping(string => address) students;
    string courseName;
    string teacherName;
    
    
    bytes32 public constant STUDENT_ROLE = keccak256("Student");
    
    constructor(address _teacher, address _faculty, string memory _courseName, string memory _teacherName) public{
    faculty = _faculty;
    courseName = _courseName;
    teacherName = _teacherName;
    _setupRole(DEFAULT_ADMIN_ROLE, _teacher);
    _setRoleAdmin(STUDENT_ROLE, DEFAULT_ADMIN_ROLE);
    }
    
    modifier onlyTeacher() {
    require(isTeacher(msg.sender), "Restricted to admins!");
    _;
    }
  
    modifier onlyStudent() {
    require(isStudent(msg.sender), "Restricted to admins!");
    _;
    }
    
    function addStudent(address _student, string memory studentName) public onlyTeacher{
        grantRole(STUDENT_ROLE, _student);
        studentList.push(studentName);
        students[studentName] = _student;
    }
    
    function addLaboratory(uint number, string memory _instructions) public onlyTeacher {
    
    
        laboratory storage lab = laboratoryList[number];
        lab.instructions = _instructions;
        lab.open = true;
        laboratoryNumberList.push(number);
    }
    
    function addSubmission(uint labNumber, string memory IPFSHash) public onlyStudent {
        laboratory storage lab = laboratoryList[labNumber];
        require(lab.open, "Laboratory submissions are closed!");
        lab.submission[msg.sender] = IPFSHash;
    }
    
    function gradeStudent(uint labNumber, string memory studentName, uint grade, bool eligible) public onlyTeacher {
        require(students[studentName] != address(0), "Student with this name not yet added!");
        laboratory storage lab = laboratoryList[labNumber];
        
        lab.mark[students[studentName]] = grade;
        
        if(eligible)
            rewardsEntry.push(students[studentName]);
    }
    
    function getRewardsEntryAndReset() external returns(address[] memory) {
        require(msg.sender == faculty);
        address[] memory rewardsEntryTemp = rewardsEntry;
        delete rewardsEntry;
        return rewardsEntryTemp;
        
    }
    
    function getLaboratoryNumberList() public view returns(uint[] memory) {
        return laboratoryNumberList;
    }
    
    function getStudentList() public view returns(string[] memory) {
        return studentList;
    }
    
    function getCourseName() public view returns(string memory) {
        return courseName;
    }
    
    function getTeacherName() public view returns(string memory){
        return teacherName;
    }
    
    
    function isTeacher(address account) public virtual view returns(bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, account);
  }
    
    function isStudent(address account) public virtual view returns(bool) {
    return hasRole(STUDENT_ROLE, account);
  }
}
