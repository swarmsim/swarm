import { Card, Nav } from 'react-bootstrap';
import { BsXLg } from 'react-icons/bs';
import classes from "./../layout.module.css";

const Viewwrap = (props) => {
    const setClose = props.setClose;
    return(
        <Card className={classes.viewwrap}>
          <Card.Body>
            <Card.Text style={{ marginBottom: 0 }}>
              We recently moved from <strong>swarmsim.github.io</strong> to{' '}
              <strong>www.swarmsim.com</strong>. You're in the right place.
            </Card.Text>
            <Nav>
              <Nav.Link href="#home" className={classes.old_site} style={{  }}>
                Looking for your saved progress from the old site?
              </Nav.Link>
            </Nav>
          </Card.Body>
          <Card.Body
            style={{ textAlign: 'right' }}
            onClick={() => setClose(true)}
          >
            <BsXLg className={classes.close_btn} />
          </Card.Body>
        </Card>
    )
}

export default Viewwrap