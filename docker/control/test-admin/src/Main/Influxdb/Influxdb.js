import React, { Component } from "react";
import MyConsumer from "../../MyConsumer";
import { Segment } from "semantic-ui-react";
import "./Influxdb.css";

export class Influxdb extends Component {
  state = {
    items: {},
  };

  render() {
    return (
      <MyConsumer>
        {({ influxdbUrl }) => (
          <Segment className="Influxdb">
            <iframe src={influxdbUrl} width="100%" height="100%" title="Influxdb" scrolling="auto" >
              Influxdb Dashboard
            </iframe>
          </Segment>
        )}
      </MyConsumer>
    );
  }
}

export default Influxdb;
