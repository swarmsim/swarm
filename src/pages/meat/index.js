import { Col, Row } from "react-bootstrap";
import { Link, Outlet } from "react-router-dom";
import classes from "./meat.module.css";

const Meat = () => {
    return (
        <Row className={classes.height}>
            <Col md={3}>
                <Link className={classes.drone} to="drone">
                    <div className={classes.drone_name}>Drone</div>
                    <div className={classes.drone_value}>0</div>
                </Link>
                <Link className={classes.meat} to="meat">
                    <div className={classes.drone_name}>Meat</div>
                    <div className={classes.drone_value}>35</div>
                </Link>
            </Col>
            <Col md={9}>
                <Outlet />
            </Col>
        </Row>
    )
}

export default Meat