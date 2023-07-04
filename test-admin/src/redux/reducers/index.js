import { combineReducers } from "redux";
import {reportFetchTenants, fetchSlavesForTenant } from "./report";

export default combineReducers({ reportFetchTenants, fetchSlavesForTenant });

