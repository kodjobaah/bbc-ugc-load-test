package cluster

import (
	"context"
	"fmt"
	"os"
	"strings"

	awscredentials "github.com/afriexUK/afriex-jmeter-testbench/admin/internal/pkg/awscredential"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/eks"
	"github.com/aws/aws-sdk-go/aws/awserr"
	log "github.com/sirupsen/logrus"
)

//Operations performed on the cluster
type Operations struct{}

//DescribeCluster returns a description of the cluster
func (ops Operations) DescribeCluster(clusterName string) (awsRegion string, awsActNmbr string, problems string) {

	webTokenFile := os.Getenv("AWS_WEB_IDENTITY_TOKEN_FILE")

	var cfg aws.Config
	var err error
	if webTokenFile != "" {
		eksCreds := awscredentials.Credentials{}
		creds := eksCreds.GetWebIdentityCredentials()
		keyID := *creds.AccessKeyId
		secretKey := *creds.SecretAccessKey
		st := *creds.SessionToken
		cfg, err = config.LoadDefaultConfig(context.TODO(),
			config.WithCredentialsProvider(
				credentials.NewStaticCredentialsProvider(keyID, secretKey, st)),
		)

	} else {
		cfg, err = config.LoadDefaultConfig(context.TODO(), config.WithRegion("eu-west-3"))
	}
	if err != nil {
		log.WithFields(log.Fields{
			"err": err.Error(),
		}).Error("Problems Loading Credentials")
	}
	cfg.Region = "eu-west-3"
	svc := eks.NewFromConfig(cfg)
	input := &eks.DescribeClusterInput{
		Name: aws.String(clusterName),
	}

	result, err := svc.DescribeCluster(context.Background(), input)
	if err != nil {
		problems = err.Error()
		if aerr, ok := err.(awserr.Error); ok {
			if aerr.Code() != "" {
				log.WithFields(log.Fields{
					"err": err.Error(),
				}).Error(aerr.Code())
			}
		} else {
			log.WithFields(log.Fields{
				"err": err.Error(),
			}).Error("Describe cluster failed")
		}
		return
	}

	clsArn := *result.Cluster.Arn

	fmt.Println(clsArn)
	arns := strings.Split(clsArn, ":")
	awsRegion = arns[3]
	awsActNmbr = arns[4]
	return
}
