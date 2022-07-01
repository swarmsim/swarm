import {
  BsArrowUpCircleFill,
  BsArrowUpCircle,
  BsFillReplyFill,
  BsCheckLg,
  BsGearFill,
  BsPersonFill,
  BsBarChartFill,
  BsChatFill,
} from 'react-icons/bs';
import {
  GiSpiderAlt
} from "react-icons/gi";
import { Link } from 'react-router-dom';
import { AiOutlineContainer } from "react-icons/ai";
import { BsFillFileEarmarkFontFill } from "react-icons/bs";
import { Nav, NavDropdown } from 'react-bootstrap';

const Navbar = () => {
  const styles = {
    textformat: {
      textDecoration: "none",
      color: "black",
      marginLeft: 5,
    }
  };
  return (
  <Nav variant="tabs" defaultActiveKey="meat">
    <Nav.Item>
      <Nav.Link 
        eventKey="meat"
      >
        <Link
          to='/meat'
          style={{ color: '#337ab7', textDecoration: "none" }}
        >
          35 meat
        </Link>
      </Nav.Link>
    </Nav.Item>
    <Nav.Item>
      <Nav.Link 
        eventKey="larvae" 
      >
        <Link 
          to='/larvae'
          style={{ color: "#337ab7", textDecoration: "none" }}
        >
          11 larvae
        </Link>
      </Nav.Link>
    </Nav.Item>
    <NavDropdown 
      title={
        <span style={{ color: "#337ab7", fontWeight: 500 }}>More...</span>
      }
      id="nav-dropdown"
    >
      <NavDropdown.Item eventKey="4.1">
        {' '}
        <BsArrowUpCircleFill /> Buy all 1 upgrade
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.2">
        {' '}
        <BsArrowUpCircle /> Buy cheapest 1 upgrade
      </NavDropdown.Item>
      <NavDropdown.Divider />
      <NavDropdown.Item eventKey="4.3">
        {' '}
        <BsFillReplyFill /> Undo
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.4">
        {' '}
        <BsGearFill /> 
        <Link style = {styles.textformat} to="/options">Options</Link>
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.5">
        {' '}
        <BsCheckLg /> 
        <Link style = {styles.textformat} to="/achievements">Achievements</Link>
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.6">
        {' '}
        <BsBarChartFill /> 
        <Link style = {styles.textformat} to="/statistics">Statistics</Link>
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.7">
        {' '}
        <BsFillFileEarmarkFontFill /> 
        <Link style = {styles.textformat} to="/changelog">Patch Notes</Link>
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.8">
        {' '}
        <BsPersonFill /> 
        <a style = {styles.textformat} href="http://reddit.com/r/swarmsim" target="_blank">Community</a>
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.9">
        {' '}
        <BsChatFill />
        <Link style = {styles.textformat} to="/contact"> Send Feedback</Link>
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.10">
        {' '}
        <GiSpiderAlt />
        <Link style = {styles.textformat} to="/contact">Report Problem</Link>    
      </NavDropdown.Item>
      <NavDropdown.Item eventKey="4.11">
        {' '}
        <AiOutlineContainer /> 
        <Link style = {styles.textformat} to="/all">Show all units</Link>
      </NavDropdown.Item>
    </NavDropdown>
  </Nav>
  )
}

export default Navbar