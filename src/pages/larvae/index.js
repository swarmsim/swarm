import { BsFillArrowUpCircleFill } from "react-icons/bs";
import { Outlet } from "react-router";
import { Link } from 'react-router-dom';
import { Row, Col } from 'react-bootstrap';
import classes from "./larvae.module.css";

const Larvae = () => {
    return (
        <Row className={classes.height}>
            <Col md={3}>
                <Link className={classes.larva} to='larva'>
                    <BsFillArrowUpCircleFill color="#337ab7" />
                    <div className={classes.larva_name}>Larva</div>
                    <div className={classes.larva_value}>12 +1.00/sec</div>
                </Link>
            </Col>
            <Col md={9}>
                <Outlet />
            </Col>
        </Row>
    )
}

export default Larvae;