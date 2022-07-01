import { Container, Table } from "react-bootstrap";
import classes from "./statistics.module.css";

const Statistics = () => {
    return (
        <Container>
          <h1>Statistics</h1>
          <div className={classes.divider1}></div>
          <Table responsive>
            <thead>
              <tr className={classes.divider2}>
                <th> Unit</th>
                <th>First Bought</th>
                <th>Clicks</th>
                <th>Bought Manually</th>
                <th>Twins</th>
              </tr>
            </thead>
            <tbody>
              <tr className={classes.divider1}>
                <td>Meat</td>
              </tr>
              <tr className={classes.divider1}>
                <td>Larva</td>
              </tr >
              <tr className={classes.divider1}>
                <td>Crystal</td>
              </tr>
            </tbody>
          </Table>
          <div>
            <span>No upgrades purchased</span>
            <div className={classes.flex}>
              <div className={classes.flexCol1}>
                <strong>Save File Size</strong>
                <strong>Start Date</strong>
                <strong>Last Ascended</strong>
              </div>
              <div className={classes.flexCol2}>
                <span>1,005 base64 chars</span>
                <span>3 hours ago - Fri Jul 01 2022 08:37:32 GMT+0200 (Central European Summer Time)</span>
                <span>never</span>
              </div>
            </div>
          </div>
        </Container>
    )
}

export default Statistics