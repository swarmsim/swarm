
import { Card, Container, Form, Row, Col, Button } from "react-bootstrap";
import { BsXLg } from "react-icons/bs";
import classes from "./crystal.module.css";
import { Link } from "react-router-dom";

const Crystal = () => {
  return (
    <div className={classes.crystalDetails}>
      <Link 
          to="/crystal"
          className={classes.top_btn}
      >
          Crystal
      </Link>
      <p>Energy frozen into a solid form. Crystals can be thawed and used as energy at any time. Unlike energy, crystals have no maximum, and are kept when ascending.</p>
      <p>Swarm Simulator's developer appreciates your support - thank you!</p>
      <Card className={classes.errCard}>
        <Card.Body>
          <Card.Text>
            Please log in to buy crystals: More... > Options
          </Card.Text>
        </Card.Body>
      </Card>
      <p>Converting crystals has permanently increased your maximum energy by 0.</p>
      <Form.Group as={Row} className="mb-3" controlId="formPlaintextPassword">
        <Form.Label column sm="1">
          Converting 
        </Form.Label>
        <Col sm="4">
          <Form.Control type="password" placeholder="1" />
        </Col>
        <Form.Label column sm="4">
          energy will cost 1 crystal.
        </Form.Label>
      </Form.Group>
      <Button
        disabled
        variant="outline-secondary"
        className={classes.hatch_btn}
      >
        Can't convert
      </Button>
      <p>You own no crystals.</p>
      <Link
        to="/meat"
        className={classes.close}
      >
        <BsXLg className={classes.close_btn} />
      </Link>
    </div>
  )
}

export default Crystal