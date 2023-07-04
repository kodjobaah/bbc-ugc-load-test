import { REPORT_FETCH_TENANTS, RECEIVE_REPORT_TENANTS, FETCH_LOGS_FOR_SLAVE, RECEIVE_LOGS_FOR_SLAVE } from './actionTypes';

function fetchSlavesForTenant() {
  console.log(" DISPATH: fetchSlavesForTenant");
    return {
        type: FETCH_LOGS_FOR_SLAVE
    };
}

function reportFetchTenants() {
  console.log(" DISPATH: reportFetchTenants");
    return {
        type: REPORT_FETCH_TENANTS
    };
}

function receiveReportTenants(tenants) {
  console.log(" rexeice: receiveReportTenants");
    return {
      type: RECEIVE_REPORT_TENANTS,
      tenants,
      receivedAt: new Date().setMilliseconds(0),
    }
}

function receiveSlavesForTenant(slaves) {
  console.log(" rexeice: receiveSlavesForTenant");
    return {
      type: RECEIVE_LOGS_FOR_SLAVE,
      slaves,
      receivedAt: new Date().setMilliseconds(0),
    }
  }

  export {
    receiveSlavesForTenant,
    receiveReportTenants,
    reportFetchTenants,
    fetchSlavesForTenant
  }
