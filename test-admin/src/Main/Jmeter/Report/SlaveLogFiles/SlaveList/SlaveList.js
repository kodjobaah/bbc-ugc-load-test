import React, { Component } from "react";
import BootstrapTable from "react-bootstrap-table-next";
import paginationFactory from "react-bootstrap-table2-paginator";
import MyConsumer from "../../../../../MyConsumer";
import { get } from "axios";
import { Button, Divider } from "semantic-ui-react";
import "./SlaveList.css";
const columns = [
  {
    dataField: "Name",
    text: "Name",
  },
  {
    dataField: "PodIP",
    text: "PodIP",
  },
  {
    dataField: "Phase",
    text: "Phase",
  },
];

export class SlaveList extends Component {
  state = {
    slaves: {},
  };

  updateState = (row, isSelect, rowIndex, e) => {
    this.setState((state) => {
      let items = this.state.slaves;
      if (isSelect) {
        items[row.Name] = row.PodIP;
      } else {
        delete items[row.Name];
      }
      return {
        slaves: items,
      };
    });

    return true;
  };

  getLogs = () => {
    let slaves = "";
    if (Array.isArray(this.state.slaves)) {
      slaves = this.state.slaves;
    } else {
      var keys = Object.keys( this.state.slaves )
      slaves = this.state.slaves[keys[0]];
    }
   
    if (typeof this.state.slaves !== 'undefined') {
      const FileDownload = require("js-file-download");
      get("/test-output?ip="+slaves).then((response) => {
        var keys = Object.keys( this.state.slaves )
        FileDownload(response.data,keys[0]+".log")
      });

    }
  };
  selectRowProp = {
    mode: "checkbox", // single row selection
    hideSelectAll: true,
    clickToSelect: true,
    onSelect: this.updateState,
  };
  componentDidMount() {}

  render() {
    return (
      <MyConsumer>
        {({ slaves }) => (
          <div>
            <BootstrapTable
              //  classes="reportlist"
              keyField="Name"
              data={slaves}
              selectRow={this.selectRowProp}
              columns={columns}
              pagination={paginationFactory()}
            />
            <Divider />
            <Button color="blue" onClick={this.getLogs}>
              Get Logs
            </Button>
          </div>
        )}
      </MyConsumer>
    );
  }
}

export default SlaveList;
