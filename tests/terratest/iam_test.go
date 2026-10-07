package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIAMModule(t *testing.T) {
	t.Parallel()

	awsRegion    := "ca-central-1"
	uniqueID     := random.UniqueId()
	projectName  := fmt.Sprintf("test-iac-%s", uniqueID)
	accountID    := aws.GetAccountId(t)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../terraform/modules/iam",
		Vars: map[string]interface{}{
			"project_name":         projectName,
			"github_org":           "test-org",
			"github_repo":          "test-repo",
			"create_oidc_provider": true,
			"state_bucket_name":    fmt.Sprintf("terraform-state-%s", accountID),
			"lock_table_name":      "terraform-locks",
			"kms_key_arn":          fmt.Sprintf("arn:aws:kms:%s:%s:key/test-key", awsRegion, accountID),
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

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// ── Verify plan role ──────────────────────────────────────────────────
	planRoleARN := terraform.Output(t, terraformOptions, "plan_role_arn")
	assert.Contains(t, planRoleARN, fmt.Sprintf("%s-github-plan", projectName))
	assert.Contains(t, planRoleARN, accountID)

	// ── Verify apply role ─────────────────────────────────────────────────
	applyRoleARN := terraform.Output(t, terraformOptions, "apply_role_arn")
	assert.Contains(t, applyRoleARN, fmt.Sprintf("%s-github-apply", projectName))

	// ── Verify OIDC provider ──────────────────────────────────────────────
	oidcProviderARN := terraform.Output(t, terraformOptions, "oidc_provider_arn")
	assert.Contains(t, oidcProviderARN, "token.actions.githubusercontent.com")
	assert.NotEmpty(t, oidcProviderARN)

	// Plan role should NOT equal apply role
	assert.NotEqual(t, planRoleARN, applyRoleARN, "Plan and apply roles must be different")

	t.Logf("✅ IAM module test passed — Plan role: %s", planRoleARN)
}
