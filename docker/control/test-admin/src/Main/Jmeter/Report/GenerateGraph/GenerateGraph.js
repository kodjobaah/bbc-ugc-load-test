import React, { Component } from "react";
import { connect } from "react-redux";
import { Dropdown, Divider, Segment } from "semantic-ui-react";
import { reportFetchTenants } from "../../../../redux/actions";
import ReportList from "./ReportList/ReportList";
import "./GenerateGraph.css";
import _ from "lodash";
import MyConsumer from "../../../../MyConsumer";

class GenerateGraph extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    this.props.reportFetchTenants();
  }


  render() {
    return (
      <MyConsumer>
        {({ fetchReportsForTenant }) => (
          <div>
            <Segment style={{overflow: 'auto', maxHeight: '100vh' }} divided="true">
              <Dropdown
                placeholder="Select tenant"
                options={this.props.tenantList}
                onChange={(event, data) => {
                  this.setState({ tenant: data.value });
                  fetchReportsForTenant(data.value);
                }}
              />
              <Divider />
              <ReportList tenant={this.state.tenant} />
            </Segment>
          </div>
        )}
      </MyConsumer>
    );
  }
}

/*
GenerateGraph.propTypes = {
  reportTenants: PropTypes.object.isRequired,
};
*/

function mapStateToProps(state, ownProps) {
  const { reportFetchTenants } = state;
  let tl = reportFetchTenants.TenantList;

  let con = _.map(tl, function (item) {
    return { key: item, value: item, text: item };
  });
  // component receives additionally:
  return { tenantList: con };
}

const mapDispatchToProps = (dispatch) => ({
  reportFetchTenants: () => dispatch(reportFetchTenants()),
});

export default connect(mapStateToProps, mapDispatchToProps)(GenerateGraph);
