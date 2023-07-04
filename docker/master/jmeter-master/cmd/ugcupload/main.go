package main

import (
	"encoding/gob"
	"net/http"
	"time"

	ginzap "github.com/gin-contrib/zap"
	"github.com/gin-gonic/gin"
	log "go.uber.org/zap"
	"golang.org/x/sync/errgroup"

	"github.com/afriexUK/afriex-jmeter-testbench/jmeter-master/internal/pkg/controller"
	"github.com/afriexUK/afriex-jmeter-testbench/jmeter-master/internal/pkg/types"
)

var logger *log.Logger

func init() {
	logger, _ = log.NewProduction()
}

var (
	g errgroup.Group
)

var control = controller.Controller{}

func main() {

	defer logger.Sync()

	gob.Register(types.StartTestCMD{})
	server01 := &http.Server{
		Addr:         ":1025",
		Handler:      router01(),
		ReadTimeout:  15 * time.Minute,
		WriteTimeout: 15 * time.Minute,
		IdleTimeout:  15 * time.Minute,
	}

	g.Go(func() error {
		return server01.ListenAndServe()
	})
	if err := g.Wait(); err != nil {
		logger.Fatal("Server stopped",
			log.String("err", err.Error()),
			log.Duration("backoff", time.Second))
	}

}

func router01() http.Handler {

	// Gin instance
	r := gin.Default()

	// Add a ginzap middleware, which:
	//   - Logs all requests, like a combined access and error log.
	//   - Logs to stdout.
	//   - RFC3339 with UTC time format.
	r.Use(ginzap.Ginzap(logger, time.RFC3339, true))

	// Logs all panic to error log
	//   - stack means whether output the stack info.
	r.Use(ginzap.RecoveryWithZap(logger, true))

	r.NoRoute(func(c *gin.Context) {
		res := types.Response{}
		res.Message = "no route defined"
		c.PureJSON(http.StatusOK, res)
	})

	r.GET("/stop-test", control.StopTest)
	r.POST("/start-test", control.StartTest)
	r.GET("/is-running", control.IsRunning)
	r.GET("/kill", control.KillMaster)

	return r
}
