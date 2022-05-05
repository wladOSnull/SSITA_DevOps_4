package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/gcp"
	httpHelper "github.com/gruntwork-io/terratest/modules/http-helper"
	terraform "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerragruntExample(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../examples/first",
		TerraformBinary: "terragrunt",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.TgApplyAll(t, terraformOptions)

	public_ip := terraform.Output(t, terraformOptions, "public_ip")

	URL := fmt.Sprintf("http://%s", public_ip)

	httpHelper.HttpGetWithRetry(t, URL, nil, 200, "terragrunt + terratest", 30, 5*time.Second)

	//	host := ssh.Host{
	//		Hostname:    public_ip,
	//		SshUserName: "wlados",
	//		SshKeyPair: &ssh.KeyPair{
	//			PublicKey:  "test",
	//			PrivateKey: "test",
	//		},
	//	}
	//
	//	fmt.Println(ssh.CheckSshConnectionE(t, host))
	//
	key := gcp.ReadBucketObject(t, "ssita", "ssh/id_rsa_server.pub")
	fmt.Println(key)
}

// export GOOGLE_APPLICATION_CREDENTIALS="/home/wlados/.gcp/terraform.json"
