package controller

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	uuid "github.com/satori/go.uuid"
	log "go.uber.org/zap"

	myExec "github.com/afriexUK/afriex-jmeter-testbench/jmeter-master/internal/pkg/exec"
	"github.com/afriexUK/afriex-jmeter-testbench/jmeter-master/internal/pkg/redis"
	"github.com/afriexUK/afriex-jmeter-testbench/jmeter-master/internal/pkg/types"
)

//Controller the web control layer
type Controller struct {
}

var logger *log.Logger
var jmeterExec myExec.Exec

func init() {
	jmeterExec = myExec.Exec{}
	logger, _ = log.NewProduction()
}

func (cnt *Controller) runTest(args []string) {
	cnt.executeCommand("/home/jmeter/bin/load_test.sh", args)
}

func (cnt *Controller) monitorTests(tenant string) {
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Minute)
	rd := redis.Redis{}
	rd.Setup()
	for {
		select {
		case <-ctx.Done():
			found, _ := jmeterExec.IsProcessRunning("ApacheJMeter")
			if !found {
				rt, err, f := rd.GetTenant(tenant)

				if err != "" {
					logger.Error("Redis Tenant not found", log.String("tenant", tenant))
					return
				}

				if f {
					dt := time.Now()
					rt.Started = "Complete[master]"
					rt.Errors = fmt.Sprintf("%s  TestStopped[%s]", rt.Errors, dt.Format("01-02-2006 15:04:05 Monday"))
					rd.AddTenant(rt)
				}
				//log error
				return
			}
			logger.Info("Wating for tests to complete")
			cancel()
			ctx, cancel = context.WithTimeout(context.Background(), 1*time.Minute)
		}
	}
}

func (cnt *Controller) waitForPorts(hosts []string) (notReady bool) {

	defer logger.Sync()

	count := 0
	temp := hosts
	var ready []string
	var waiting []string
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Minute)
	for {
		select {
		case <-ctx.Done():
			for _, host := range temp {
				timeout := time.Second
				conn, err := net.DialTimeout("tcp", net.JoinHostPort(host, "50000"), timeout)
				if err != nil {
					logger.Error("Problems connecting to slaveL",
						// Structured context as strongly typed Field values.
						log.String("err", err.Error()),
						log.String("slave", host),
						log.Duration("backoff", time.Second))
				}
				if conn != nil {
					defer conn.Close()
					ready = append(ready, host)
				} else {
					waiting = append(waiting, host)
				}
			}
			temp = waiting
			waiting = []string{}

			if len(ready) == len(hosts) {
				fmt.Println("All ports are ready")
				notReady = false
				return
			}

			count = count + 1
			if count == 10 {
				logger.Error("slaves ports are not read",
					// Structured context as strongly typed Field values.
					log.String("Slaves", strings.Join(waiting, ",")),
					log.Duration("backoff", time.Second))
				notReady = true
				return
			}
			cancel()
			ctx, cancel = context.WithTimeout(context.Background(), 1*time.Minute)
		}
	}

}

//StartTest used to start the jmeter tests
func (cnt *Controller) StartTest(c *gin.Context) {
	defer logger.Sync()

	res := types.Response{}
	var startTestCMD types.StartTestCMD
	if er := c.ShouldBindWith(&startTestCMD, binding.Form); er != nil {
		logger.Error("Problems binding form",
			// Structured context as strongly typed Field values.
			log.String("err", er.Error()),
			log.Duration("backoff", time.Second))

		return
	}

	var jsonData []byte
	jsonData, _ = json.Marshal(startTestCMD)

	logger.Info("Command Received",
		log.String("startTestCmd", string(jsonData)),
		log.Duration("backoff", time.Second))


	found, _ := jmeterExec.IsProcessRunning("ApacheJMeter")
	if found {
		res.Message = "Test Are Running You will need to stop first"
		res.Code = 402
		c.PureJSON(http.StatusOK, res)
		return
	}

	notReady := cnt.waitForPorts(strings.Split(startTestCMD.Hosts, ","))
	if notReady == true {
		res.Message = "slave ports were not opened"
		res.Code = 400
		c.PureJSON(http.StatusBadRequest, res)
		return
	}

	t := time.Now()
	u2 := fmt.Sprintf("%s-%s", uuid.NewV4(), t.Format("20060102150405"))
	path := fmt.Sprintf("/home/jmeter/test/%s", u2)
	errMkdir := os.MkdirAll(path, os.ModePerm)
	if errMkdir != nil {
		logger.Error("Problems creating the directory",
			log.String("err", errMkdir.Error()),
			log.Duration("backoff", time.Second))

		res := types.Response{}
		res.Message = "Unable to create the test path directory"
		res.Code = 404
		c.PureJSON(http.StatusBadRequest, res)
		return
	}

	jmeterScript, err := c.FormFile("file")
	if err != nil {
		logger.Error("Unable to get the jmeter script from the form",
			log.String("err", err.Error()),
			log.Duration("backoff", time.Second))

		res.Message = "Unable to get the jmeter script from the form"
		res.Code = 403
		c.PureJSON(http.StatusBadRequest, res)
		return
	}

	if jmeterScript != nil {
		destFileName := fmt.Sprintf("%s/upload.jmx", path)
		c.SaveUploadedFile(jmeterScript, destFileName)
	}

	args := []string{fmt.Sprintf("%s/upload.jmx", path), startTestCMD.Tenant, startTestCMD.Hosts}
	logger.Info("Arguments being sent to jmeter script",
		log.String("args", strings.Join(args, "")),
		log.Duration("backoff", time.Second))

	go cnt.runTest(args)
	go cnt.monitorTests(startTestCMD.Tenant)
	res.Message = "test should have started"
	res.Code = 200
	c.PureJSON(http.StatusOK, res)
	return

}

func (cnt *Controller) KillMaster(c *gin.Context) {

	res := types.Response{}
	found, pidStr := jmeterExec.IsProcessRunning("ApacheJMeter")
	if found {
		pid, _ := strconv.Atoi(pidStr)
		syscall.Kill(pid, 9)
		res.Message = "master killed"
		res.Code = 200
		if err := os.RemoveAll("/tmp/hsperfdata_jmeter"); err != nil {
			logger.Error("Removing hsperfdata_jmeter",
				log.String("err", err.Error()),
				log.Duration("backoff", time.Second))
		}
		c.PureJSON(http.StatusBadRequest, res)
		return
	}
	res.Message = "master killed not killed"
	res.Code = 400
	c.PureJSON(http.StatusOK, res)
	return
}

//IsRunning use to determine if the tenant is running
func (cnt *Controller) IsRunning(c *gin.Context) {
	defer logger.Sync()

	found, pid := jmeterExec.IsProcessRunning("ApacheJMeter")

	if !found {
		res := types.Response{}
		res.Message = "No Test Running"
		res.Code = 401
		c.PureJSON(http.StatusOK, res)
		return
	}

	logger.Info("Processes",
		log.String("pid", pid),
		log.Duration("backoff", time.Second))

	res := types.Response{}
	res.Message = fmt.Sprintf("Test Are Running: Pid:%s", pid)
	res.Code = 200
	fmt.Println("1")

	c.PureJSON(http.StatusOK, res)
	return
}

func (cnt *Controller) executeCommand(c string, args []string) {
	defer logger.Sync()

	cmd := exec.Command(c, args...)
	_, errExec := cmd.CombinedOutput()
	if errExec != nil {
		logger.Error("Problems executing the script",
			log.String("err", errExec.Error()),
			log.String("cmd", c),
			log.String("args", strings.Join(args, ",")),
			log.Duration("backoff", time.Second))

	}
}

func (cnt *Controller) stopTest() {
	cnt.executeCommand(fmt.Sprintf("/opt/apache-jmeter/bin/stoptest.sh"), []string{})
}

//StopTest used to stop the tests
func (cnt *Controller) StopTest(c *gin.Context) {
	go cnt.stopTest()

	resp := types.Response{}
	resp.Message = "Test stopped"
	resp.Code = 200
	c.PureJSON(http.StatusOK, resp)
	return
}