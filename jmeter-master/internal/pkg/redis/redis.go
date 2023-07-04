package redis

import (
	"fmt"
	"time"

	"github.com/gomodule/redigo/redis"
	log "github.com/sirupsen/logrus"

	types "github.com/afriexUK/afriex-jmeter-testbench/jmeter-master/internal/pkg/types"
)

//Redis used for all redis operations
type Redis struct {
	RedisPool *redis.Pool
}

func (r *Redis) Setup() {
	r.RedisPool = &redis.Pool{
		MaxIdle:     100,               // adjust to your needs
		IdleTimeout: 240 * time.Second, // adjust to your needs
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", "admin-controller.control.svc.cluster.local:6379")
			if err != nil {
				return nil, err
			}
			return c, err
		},
	}

}

//AddTenant used to set the tenant started state to not-yet
func (r *Redis) AddTenant(redisTenant types.RedisTenant) (error string, started bool) {
	return r.addItem(fmt.Sprintf("testStartStatus:%s", redisTenant.Tenant), redisTenant)
}

func (r *Redis) addItem(item string, redisTenant types.RedisTenant) (error string, started bool) {
	c := r.RedisPool.Get()
	defer c.Close()
	if _, err := c.Do("HMSET", redis.Args{}.Add(item).AddFlat(&redisTenant)...); err != nil {
		log.WithFields(log.Fields{
			"err": err.Error(),
		}).Error("Problems adding tenant to redis")
		error = err.Error()
		started = false
		return
	}
	r.addTTL(item, 3600)
	started = true
	return

}

//GetTenant used to get the tenant
func (r *Redis) GetTenant(tenant string) (ten types.RedisTenant, error string, found bool) {
	return r.getItem(fmt.Sprintf("testStartStatus:%s", tenant))
}

func (r *Redis) getItem(item string) (ten types.RedisTenant, error string, found bool) {
	c := r.RedisPool.Get()
	redisTenant := types.RedisTenant{}
	values, err := redis.Values(c.Do("HGETALL", item))
	defer c.Close()
	if err != nil {
		log.WithFields(log.Fields{
			"err": err.Error(),
		}).Error("Problems getting tenant from redis")
		error = err.Error()
		found = false
	}
	redis.ScanStruct(values, &redisTenant)
	ten = redisTenant
	found = true
	return
}

//addTTL used to add and expiration time to the key
func (r *Redis) addTTL(key string, ttl int) (error string, added bool) {
	c := r.RedisPool.Get()
	defer c.Close()
	_, err := redis.Int(c.Do("EXPIRE", key, ttl))
	if err != nil {
		error = err.Error()
		added = false
	}

	added = true
	return
}
