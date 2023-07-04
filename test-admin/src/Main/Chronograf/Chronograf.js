import React, { Component } from "react";

import MyConsumer from "../../MyConsumer";
import {
  Segment 
} from 'semantic-ui-react';
import "./Chronograf.css";

export class Chronograf extends Component {
  state = {
    items: {}
  };

  render() {
    return (
      <MyConsumer>
        {({ chronographUrl }) => (
          <Segment className="Chronograf">
    <iframe src={ chronographUrl} width="100%" height="100%" title="Chronograf" >
    </iframe>
    </Segment>
        )}
      </MyConsumer>
    );
  }
}

export default Chronograf;
