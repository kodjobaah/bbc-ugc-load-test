import React, { Component } from "react";
import MyConsumer from "../../MyConsumer";
import { Segment } from "semantic-ui-react";
import "./Graphana.css";

export class Graphana extends Component {
  state = {
    items: {},
  };

  render() {
    return (
      <MyConsumer>
        {({ graphanaUrl }) => (
          <Segment className="Graphana">
            <iframe data={graphanaUrl} width="100%" height="100%" title="Graphana" >
              Grafana Dashboard
            </iframe>
          </Segment>
        )}
      </MyConsumer>
    );
  }
}

export default Graphana;
