package test

import (
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())
	randID := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randID}

	exampleInput := "Hello, world!"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
			"example":    exampleInput,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	id := terraform.Output(t, terraformOptions, "id")
	example := terraform.Output(t, terraformOptions, "example")
	random := terraform.Output(t, terraformOptions, "random")

	// Verify we're getting back the outputs we expect
	// Ensure we get a random number appended
	assert.Equal(t, exampleInput+" "+random, example)
	// Ensure we get the attribute included in the ID
	assert.Equal(t, "eg-ue2-test-example-"+randID, id)

	// ************************************************************************
	// This steps below are unusual, not generally part of the testing
	// but included here as an example of testing this specific module.
	// This module has a random number that is supposed to change
	// only when the example changes. So we run it again to ensure
	// it does not change.

	// This will run `terraform apply` a second time and fail the test if there are any errors
	terraform.Apply(t, terraformOptions)

	id2 := terraform.Output(t, terraformOptions, "id")
	example2 := terraform.Output(t, terraformOptions, "example")
	random2 := terraform.Output(t, terraformOptions, "random")

	assert.Equal(t, id, id2, "Expected `id` to be stable")
	assert.Equal(t, example, example2, "Expected `example` to be stable")
	assert.Equal(t, random, random2, "Expected `random` to be stable")

	// Then we run change the example and run it a third time and
	// verify that the random number changed
	newExample := "Goodbye"
	terraformOptions.Vars["example"] = newExample
	terraform.Apply(t, terraformOptions)

	example3 := terraform.Output(t, terraformOptions, "example")
	random3 := terraform.Output(t, terraformOptions, "random")

	assert.NotEqual(t, random, random3, "Expected `random` to change when `example` changed")
	assert.Equal(t, newExample+" "+random3, example3, "Expected `example` to use new random number")

}
