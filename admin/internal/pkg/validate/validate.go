package validate

import (
	"strings"

	"github.com/gin-gonic/gin"

	types "github.com/afriexUK/afriex-jmeter-testbench/admin/internal/pkg/types"
)

var nonValidNamespaces = []string{"control", "default", "kube-node-lease", "kube-public", "kube-system", "ugcload-reporter", "weave"}

//Validator used to validate request params
type Validator struct {
	Context *gin.Context
}

func (v Validator) StringInSlice(a string, list []string) bool {
	for _, b := range list {
		if b == a {
			return true
		}
	}
	return false
}

//ValidateStopTest used to validate the params for deleting a tenant
func (v Validator) ValidateStopTest(ugcLoadRequest *types.UgcLoadRequest) (result bool) {

	result = false

	if ugcLoadRequest.StopContext == "" {
		ugcLoadRequest.StopTenantMissing = true
		return
	}

	if v.StringInSlice(ugcLoadRequest.StopContext, nonValidNamespaces) {
		ugcLoadRequest.InvalidTenantStop = strings.Join(nonValidNamespaces, ",")
		return
	}

	result = true
	return

}

//ValidateTenantDelete used to validate the params for deleting a tenant
func (v Validator) ValidateTenantDelete(ugcLoadRequest *types.UgcLoadRequest) (result bool) {

	result = false

	if ugcLoadRequest.TenantContext == "" {
		ugcLoadRequest.TenantMissing = true
		return
	}

	if v.StringInSlice(ugcLoadRequest.TenantContext, nonValidNamespaces) {
		ugcLoadRequest.InvalidTenantDelete = strings.Join(nonValidNamespaces, ",")
		return
	}
	result = true
	return

}

//ValidateUpload used to validate the params for starting the test
func (v Validator) ValidateUpload(ugcLoadRequest *types.UgcLoadRequest) (result bool) {

	result = false
	if len(ugcLoadRequest.Context) < 3 {
		ugcLoadRequest.MissingTenant = true
		return

	}

	//REGEX used to validate the name: [a-z0-9]([-a-z0-9]*[a-z0-9])?

	if v.StringInSlice(ugcLoadRequest.Context, nonValidNamespaces) {
		ugcLoadRequest.InvalidTenantName = strings.Join(nonValidNamespaces, ",")
		return
	}

	if ugcLoadRequest.NumberOfNodes < 1 {
		ugcLoadRequest.MissingNumberOfNodes = true
		return

	}

	_, err := v.Context.FormFile("jmeter")
	if err != nil {
		ugcLoadRequest.MissingJmeter = true
		return
	}

	/*
		 * Making this optional
		 *
		*_, e := v.Context.FormFile("data")
		*if e != nil {
		*	ugcLoadRequest.MissingData = true
		*	return
		*}
	*/
	result = true
	return
}
