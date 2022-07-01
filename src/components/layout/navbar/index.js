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
import { AiOutlineContainer } from "react-icons/ai";
import { BsFillFileEarmarkFontFill } from "react-icons/bs";
import { Nav, NavDropdown } from 'react-bootstrap'
import Meat from "../meat";
import Larvae from "../larvae";

const Navbar = (props) => {
    const { event, setEventkey } = props;
    const handleSelect = (eventKey) => setEventkey(eventKey);
    return (
        <>
            <Nav variant="tabs" defaultActiveKey="meat" onSelect={handleSelect}>
                <Nav.Item>
                    <Nav.Link eventKey="meat" style={{ color: '#337ab7' }}>
                        35 meat
                    </Nav.Link>
                </Nav.Item>
                <Nav.Item>
                    <Nav.Link eventKey="larvae" style={{ color: '#337ab7' }}>
                        11 larvae
                    </Nav.Link>
                </Nav.Item>
                <NavDropdown title="More..." id="nav-dropdown">
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
                        <BsGearFill /> Options
                    </NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">
                        {' '}
                        <BsCheckLg /> Achievements
                    </NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">
                        {' '}
                        <BsBarChartFill /> Statistics
                    </NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">
                        {' '}
                        <BsFillFileEarmarkFontFill /> Patch Notes
                    </NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">
                        {' '}
                        <BsPersonFill /> Community
                    </NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">
                        {' '}
                        <BsChatFill /> Send Feedback
                    </NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">Report Problem</NavDropdown.Item>
                    <NavDropdown.Item eventKey="4.4">
                        {' '}
                        <AiOutlineContainer /> Show all units
                    </NavDropdown.Item>
                </NavDropdown>
            </Nav>
            { event === "meat" ?
                <Meat /> : ""        
            }
            { event === "larvae" ?
                <Larvae /> : ""        
            }
        </>
    )
}

export default Navbar