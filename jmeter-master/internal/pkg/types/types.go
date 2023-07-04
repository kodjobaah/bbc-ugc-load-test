package types

//RedisTenant used to store infor about tenant in redis
type RedisTenant struct {
	Started string `redis:"started"`
	Errors  string `redis:"errors"`
	Tenant  string `redis:"tenant"`
}

//StartTestCMD structure holding the data required to start a test
type StartTestCMD struct {
	TestFile string `json:"testfile" form:"testfile"`
	Tenant   string `json:"tenant" form:"tenant"`
	Hosts    string `json:"hosts" form:"hosts"`
}

//Response The response that is sent back to the caller
type Response struct {
	Message string
	Code    int
}
