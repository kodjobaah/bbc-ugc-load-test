import React, {Component} from 'react';
import { get } from "axios";
import BootstrapTable from "react-bootstrap-table-next";
import { Button, Divider } from "semantic-ui-react";
import paginationFactory from "react-bootstrap-table2-paginator";

import './NodeInformation.css';
import { runSaga } from '@redux-saga/core';
const columns = [
  {
    dataField: "Name",
    text: "Node",
  },
  {
    dataField: "InstanceID",
    text: "Instance ID",
  },
  {
    dataField: "Phase",
    text: "Phase",
  },
  {
    dataField: "NodeConditions",
    text: "NodeConditions",
  },
];

export class NodeInformation extends Component {
  
  state = {
    nodes: [],
    update: false
  }

  fetchNodes = async () => {
    get("/failing-nodes").then((res) => {
      this.setState({nodes: res.data})
    })
  };

  render() {
    return (
      <div>
            <BootstrapTable
              keyField="InstanceID"
              data={this.state.nodes}
              columns={columns}
              pagination={paginationFactory()}
            />
            <Divider/>
            <Button color="blue" onClick={this.fetchNodes}>Fetch Node Details</Button>
          </div>
    );
  }
}

export default NodeInformation;
