import React, { Component } from "react";

import MyConsumer from "../../MyConsumer";
import { Segment } from "semantic-ui-react";
import "./WeaveScope.css";

export class WeaveScope extends Component {
  state = {
    items: {},
  };

  render() {
    return (
      <MyConsumer>
        {({ weaveScopeUrl }) => (
          <Segment className="Weavescope">
            <iframe src={weaveScopeUrl} width="100%" height="100%" title="Weave Scope" scrolling="auto" >
                Kubernetes Monitor
            </iframe>
          </Segment>
        )}
      </MyConsumer>
    );
  }
}

export default WeaveScope;
