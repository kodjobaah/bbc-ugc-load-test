import React, { Component } from "react";
import { Dropdown, Divider, Segment } from "semantic-ui-react";
import { get } from "axios";
import "./SlaveLogs.css";
import _ from "lodash";
import MyConsumer from "../../../../MyConsumer";
import SlaveList from "./SlaveList/SlaveList";

class SlaveLogs extends Component {
  constructor(props) {
    super(props);
    this.state = { tennants: [] };
  }

  componentDidMount() {
    this.fetchTestStatus();
  }

  fetchTestStatus = () => {
    get("/tenants").then((response) => {
      let tennants = response.data.AllTenants;

      let AllTenants = _.map(tennants, function (item) {
        return {
          key: item.Namespace,
          value: item.Namespace,
          text: item.Name + "@" + item.Namespace,
        };
      });
      this.setState({ tennants: AllTenants });
      //  this.setState({teststatus: status});
    });
  };

  render() {
    return (
      <MyConsumer>
        {({ fetchSlaves }) => (
          <div>
              <Segment style={{overflow: 'auto', maxHeight: '100vh' }}>
                <Dropdown
                  placeholder="Select tennet"
                  options={this.state.tennants}
                  onChange={(event, data) => {
                    fetchSlaves(data.value);
                  }}
                />
      
            
              <Divider />
              <SlaveList tenant={this.state.slaves} />
              </Segment>
                  </div>
        )}
      </MyConsumer>
    );
  }
}

export default SlaveLogs;
