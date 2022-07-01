import React, { useState } from 'react'
import { Container, Card, Nav } from 'react-bootstrap'
import classes from './layout.module.css'
import Viewwrap from './viewwrap';
import Navbar from "./navbar";

const Layout = () => {
  const [ close, setClose ] = useState(false);
  const [ event, setEventkey ] = useState("meat");

  return (
    <Container>
      <Card className={classes.nav}>
        <Card.Body>
          <Nav>
            <Nav.Item>
              <Nav.Link href="/" style={{ color: '#777', fontSize: 21 }}>
                Swarm Simulator
              </Nav.Link>
            </Nav.Item>
            <Nav.Item>
              <Nav.Link href="/" style={{ color: '#777', fontSize: 18 }}>
                v1.1.13
              </Nav.Link>
            </Nav.Item>
          </Nav>
        </Card.Body>
      </Card>
      <Card className={classes.tutorial}>
        <Card.Body>
          <Card.Text>
            You lead a small brood of worker drones. Drones gather meat. Use
            this meat to build more drones and expand your brood.
          </Card.Text>
        </Card.Body>
      </Card>
      { close === false ? (
        <Viewwrap setClose={setClose} />
        ) : ( '')
      }
      <Navbar event={event} setEventkey={setEventkey} />
    </Container>
  )
}

export default Layout
