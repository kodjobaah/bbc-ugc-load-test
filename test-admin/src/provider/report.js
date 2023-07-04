import fetch from "isomorphic-fetch";
import { get } from "axios";

const fetchPostsApi = () => {
  let data = fetch("/tenants").then(function (response) {
    return response.json();
  });

  return data;
};

const fetchReportByTenant = (tenantId) => {
  let data = fetch("/tenantReport?tenant=" + tenantId).then(function (
    response
  ) {
    return response.json();
  });

  return data;
};

const fetchLogs = (tenantId) => {
  let data = fetch("/test-ouput?tenant=" + tenantId).then(function (
    response
  ) {
    return response.json();
  });

  return data;
};

const fetchDashboardUrl = () => {
  let data = fetch("/dashboardUrl").then(function (response) {
    if (response.status === 500) {
      return {
        DashboardURL: "",
        InfluxdbURL: "",
        ChronografURL: "",
        ReportURL: "",
        MonitorURL: "",
      };
    } else {
      return response.json();
    }
  });

  return data;
};

const fetchSlavesForTenant = async (tenantId) => {
  let data = get("/slaves?tenant=" + tenantId).then((res) => {
    return res.data
  })
  return data;
};

export {
  fetchPostsApi,
  fetchReportByTenant,
  fetchDashboardUrl,
  fetchSlavesForTenant,
};
