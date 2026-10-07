package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
	t.Parallel()

	awsRegion := "ca-central-1"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../terraform/modules/vpc",
		Vars: map[string]interface{}{
			"vpc_name":         "test-vpc",
			"vpc_cidr":         "10.99.0.0/16",
			"az_count":         2,
			"nat_gateway_count": 0, // No NAT in tests — saves cost
			"enable_flow_logs": false,
			"tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"ManagedBy":   "terraform",
				"Owner":       "ci@example.com",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// Always destroy after test — never leave resources running
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// ── Verify VPC exists and has correct settings ──────────────────────
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcID, "VPC ID should not be empty")

	vpc := aws.GetVpcById(t, vpcID, awsRegion)
	assert.Equal(t, "10.99.0.0/16", vpc.CidrBlock, "VPC CIDR should match")
	assert.True(t, aws.IsPublicHost(t, vpcID, awsRegion) == false, "VPC should not be publicly accessible directly")

	// ── Verify subnet counts ──────────────────────────────────────────────
	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Equal(t, 2, len(publicSubnets), "Should have 2 public subnets (one per AZ)")

	privateAppSubnets := terraform.OutputList(t, terraformOptions, "private_app_subnet_ids")
	assert.Equal(t, 2, len(privateAppSubnets), "Should have 2 private app subnets")

	privateDataSubnets := terraform.OutputList(t, terraformOptions, "private_data_subnet_ids")
	assert.Equal(t, 2, len(privateDataSubnets), "Should have 2 private data subnets")

	// ── Verify no NAT gateways (nat_gateway_count=0) ──────────────────────
	natGateways := terraform.OutputList(t, terraformOptions, "nat_gateway_ids")
	assert.Equal(t, 0, len(natGateways), "Should have 0 NAT gateways in test")

	// ── Verify S3 VPC endpoint exists ─────────────────────────────────────
	s3EndpointID := terraform.Output(t, terraformOptions, "s3_endpoint_id")
	assert.NotEmpty(t, s3EndpointID, "S3 VPC endpoint should be created")
}
