import { Col, Row, Button, Form } from "react-bootstrap"
import { BsXLg } from "react-icons/bs";
import { Link } from 'react-router-dom';
import classes from "../meat.module.css"

const MeatDetails = () => {
    return (
        <div className={classes.meatDetails}>
            <Link 
                to="/larvae"
                className={classes.top_btn}
            >
                Meat
            </Link>
            <p>Meat is delicious. All of your swarm's creatures eat meat.</p>
            <p>You own 1 meat.</p>
            <p>You earn 3 meat per second.</p>
            <Link
                to="/meat"
                className={classes.close}
            >
                <BsXLg className={classes.close_btn} />
            </Link>
        </div>
    )
}

export default MeatDetails