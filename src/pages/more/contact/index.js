import React, { useState } from "react"
import { Card, Container } from "react-bootstrap"
import classes from "./contact.module.css"

const Contact = () => {
  const [ isShow, setIsShow ] = useState(false);
    return (
    <Container>
      <a href="https://www.reddit.com/r/swarmsim" target="_blan" className={classes.title}>
          Contact The Swarm Simulator Developer
      </a>
      <Card className={classes.card}>
        <Card.Body>
          <div>
            <a 
              href="https://www.reddit.com/r/swarmsim/submit?selftext=true" 
              target="_blank" 
              className={classes.aTagColor}
            >
              Posting
            </a> 
            {' '}
            on the
            {' '}
            <a 
              href="https://www.reddit.com/r/swarmsim" 
              target="_blank" 
              className={classes.aTagColor}
            >
              Swarm Simulator subreddit
            </a>
            {' '}
            is the best way to reach the developer! I read everything written there, even if I don't always reply.
          </div>
        </Card.Body>
      </Card>
      <p className={classes.margin_left}>
        <a 
          href="https://swarmsim.github.io/#/export" 
          target="_blank" 
          className={classes.aTagColor}
        >
          Did you play on the old website, swarmsim.github.io, and you're looking for your progress?
        </a>
      </p>
      <p className={classes.margin_left}>
        <a 
          href="https://www.reddit.com/r/swarmsim/comments/30ndt6/i_will_no_longer_restore_lost_saved_games/"
          target="_blank" 
          className={classes.aTagColor}
        >
          Did you lose your saved progress some other way?
        </a>
      </p>
      <p className={`${classes.margin_left} ${ isShow === false ? classes.margin_bottom : ""}`}>
        <a
          className={classes.aTagColor}
          onClick={() => setIsShow(!isShow)}
        >
          Email the developer?
        </a>
      </p>
      { isShow === true ?
        <Card className={ isShow === true ? classes.margin_bottom : classes.card }>
          <Card.Body>
            <p>Please email me if you're having trouble with a crystal purchase, or if you're reporting an exploitable bug.
            </p>
              <p>
              For most other topics, 
              <strong>I probably won't reply. Please post on Reddit instead.</strong>
            </p>
            <p>
              Swarm Simulator is run in one human's free time. I love you and your feedback, I really do - but email is stressful, and takes more of my limited time than you think. The Reddit community really is very helpful!
            </p>
            <a className={classes.aTagColor}>feedback@swarmsim.com</a>
          </Card.Body>
        </Card> : ""
      }
    </Container>
  )
}

export default Contact