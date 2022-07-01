import { Container, ProgressBar, Form, Card, Row, Col } from "react-bootstrap";
import { BsCheckLg } from "react-icons/bs";
import classes from "./achievements.module.css"

const Achievements = () => {
    const HatPercentage = 0;
    const TotalPercentage = 0;

    const archieves = [
        { isArchieve: true, value: 50, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 40, isHatched: false, progress: 0 },
        { isArchieve: false, value: 50, isHatched: false, progress: 0 },
        { isArchieve: false, value: 60, isHatched: false, progress: 0 },
        { isArchieve: false, value: 70, isHatched: false, progress: 0 },
        { isArchieve: false, value: 80, isHatched: false, progress: 0 },
        { isArchieve: false, value: 90, isHatched: false, progress: 0 },
        { isArchieve: true, value:10, isHatched: false, progress: 0 },
        { isArchieve: true, value:20, isHatched: true , progress: 0},
        { isArchieve: true, value:30, isHatched: true , progress: 0},
        { isArchieve: true, value:10, isHatched: false, progress: 0 },
        { isArchieve: true, value:20, isHatched: true , progress: 0},
        { isArchieve: true, value:30, isHatched: true , progress: 0},
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
        { isArchieve: false, value: 10, isHatched: false, progress: 0 },
        { isArchieve: false, value: 20, isHatched: false, progress: 0 },
        { isArchieve: false, value: 30, isHatched: false, progress: 0 },
    ]

    return (
        <Container>
            <h2>0 Achievement Points</h2>
            <ProgressBar
                className={classes.progressBar}
                now={HatPercentage}
                label={`${HatPercentage}% complete `}
                variant="custom"
                height={30}
            />
            <div className={classes.flex}>
                <span style={{marginRight: 5}}>Show</span>
                <Form.Check.Input type='checkbox' isValid />
                <strong style={{marginRight: 5}}>earn</strong>
                <Form.Check.Input type='checkbox' isValid />
                <strong style={{marginRight: 5}}>unearned</strong>
                <Form.Check.Input type='checkbox' isValid />
                <strong style={{marginRight: 5}}>masked</strong>
                <span>achievements, sorted by {' '}</span>
                <Form.Check.Input type='radio' isValid />
                <strong style={{marginRight: 5}}>default</strong>
                <Form.Check.Input type='radio' isValid />
                <strong style={{marginRight: 5}}>% complete ,</strong>
                <Form.Check.Input type='checkbox' isValid />
                <strong style={{marginRight: 5}}>lowest first</strong>
            </div>
            { archieves.map((archieve, i) => (
                <Card key={i} className={classes.cardItem}>
                    <Card.Body>
                        <div className={classes.flex1}>
                            <BsCheckLg size={60} color="#8a6d3b" />
                            <div style={{textAlign: "center"}}>
                                <h3 style={{color: "#8a6d3b"}}>Tutorial Complete</h3>
                                <p style={{color: "#8a6d3b"}}>Finish the tutorial  </p>
                            </div>
                            <span style={{color: "#8a6d3b", fontSize: "400%", fontWeight: "700"}}>50</span>
                        </div>
                        <ProgressBar
                            className={classes.progressBar}
                            now={TotalPercentage}
                            label={`${TotalPercentage}% `}
                            variant="custom"
                            height={30}
                        />
                    </Card.Body>
                </Card>
            ))}
        </Container>
    )
}

export default Achievements