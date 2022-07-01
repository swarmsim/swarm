import React, { useState } from "react";
import { Container, Card, ListGroup, Button } from "react-bootstrap";
import { Link } from "react-router-dom";
import classes from "./changelog.module.css";

const headers = [
  { title: "Version 1.1.X" },
  { title: "Version 1.0.X" },
  { title: "Version 1.0.X, Public Test" },
  { title: "Version 0.2.X" },
  { title: "Version 0.1.X" },
]

const versions = [
  { version: "1.1.13", dec1: "Added a button to export your save to the clipboard with one click.", dec2: "", date:  "2019/07/21" },
  { version: "1.1.12", dec1: "Some invisible backend changes.", dec2: "", date: "2019/06/12" },
  { version: "1.1.11", dec1: "Tutorial text should once again appear reliably.", dec2: "Crystal purchases from www.swarmsim.com no longer redirect you to the old website.", date: "2018/06/07" },
  { version: "1.1.10", dec1: `Soon, swarmsim.github.io will begin encouraging players <Link to="/" >to move to www.swarmsim.com.</Link> This will be visible in a day or two. (Kongregate is unchanged.)`, dec2: "", date: "2018/06/05" },
  { version: "1.1.9", dec1: "The game's now playable on www.swarmsim.com. <Link to="/" >In the near future, swarmsim.github.io will be moving there.</Link> (Kongregate is unchanged.)", dec2: "", date: "2018/06/04" },
  { version: "1.1.8", dec1: "", dec2: "", date: "2018/06/04" },
  { version: "1.1.7", dec1: 'The "delete online saved data" button in the options screen now asks for confirmation first.', dec2: "Mousing over an input field when buying units lists all possible formats. This previously worked; fixed a bug that broke it.", date: "2018/05/27" },
  { version: "1.1.6", dec1: "More icon sizes for mobile home screens.", dec2: "", date: "2017/06/19" },
]

const Changelog = () => {
  const [ isShow, setIsShow ] = useState(0);
  const [ isShowTrue, setIsShowTrue ] = useState(true)

  const handleShow = (i) => {
    setIsShow(i);
    setIsShowTrue(!isShowTrue);
  }

  return (
    <Container>
      <h1>Patch Notes</h1>
      <p style={{fontFamily: "initial"}}>
        Swarm Simulator is open source. See the 
        <a 
          href="https://github.com/swarmsim/swarm"
          target="_blank"  
          className={classes.seeCode}
        >
          source code repository
        </a>
        for a more thorough, but less readable, change history. 179 updates released since 2014/08/28.
      </p>
      <hr></hr>
      <div className={classes.body}>
        { headers.map((header, i) =>(
          <Card key={i} style={{marginBottom: 5}}>
            <Card.Header>
              <button
                className={classes.headText}
                onClick={() => handleShow(i)}
              >
                {header.title}
              </button>
            </Card.Header>
            { isShow === i && isShowTrue === true ?
              <ListGroup variant="flush">
              { versions.map((version, i) => (
                <ListGroup.Item>
                  <div className={classes.flex}>
                    <h5>{version.version}</h5>
                    <span className={classes.dateText}>{version.date}</span>
                  </div>
                  <ul>
                    <li>{version.dec1}</li>
                  </ul>
                </ListGroup.Item>
              ))}
            </ListGroup> : ""
            }
            
          </Card>
        )) }
      </div>
    </Container>
  )
}

export default Changelog