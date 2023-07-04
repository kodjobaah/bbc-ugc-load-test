import { REPORT_FETCH_TENANTS, RECEIVE_REPORT_TENANTS ,FETCH_LOGS_FOR_SLAVE, RECEIVE_LOGS_FOR_SLAVE} from '../actionTypes';
const reportFetchTenants = (state = [], action) => {
    switch (action.type) {
        case REPORT_FETCH_TENANTS:
          return state;
        case RECEIVE_REPORT_TENANTS:
          return action.tenants;
        default:
        return state;
    }
  }

  const fetchSlavesForTenant = (state = [], action) => {
    switch (action.type) {
        case FETCH_LOGS_FOR_SLAVE:
          return state;
        case RECEIVE_LOGS_FOR_SLAVE:
          return action.slaves;
        default:
        return state;
    }
  }
  
  export {
    reportFetchTenants,
    fetchSlavesForTenant
  }