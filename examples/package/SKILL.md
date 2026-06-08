# Skill: gitlab-policy-reviewer

Reviews GitLab security policies and approval policy YAML for compliance and correctness.

## What this skill does

Given a GitLab security policy YAML file or approval policy configuration, this skill:

1. Validates the policy syntax against the GitLab schema
2. Reviews approval rules for coverage gaps
3. Checks for overly permissive rules
4. Identifies missing approvals for sensitive paths
5. Suggests remediation where issues are found

## Inputs

Provide one or more of:
- A GitLab `.gitlab/security-policy-project/` directory or its contents
- A GitLab Merge Request approval settings configuration
- A YAML snippet from a security policy or approval policy

## Outputs

A structured review containing:
- **Summary**: overall policy health
- **Issues**: list of problems with severity (critical, high, medium, low)
- **Recommendations**: concrete changes to resolve each issue
- **Compliant items**: what is already correctly configured

## Constraints

- Does not modify files
- Does not access the network
- Does not require GitLab API access (static analysis only)
- Works with GitLab 15.x and later policy formats

## Example invocation

```
Review the security policy in .gitlab/security-policy-project/policy.yml
```

```
Does this approval configuration require approval from a code owner for changes to src/?
[paste YAML]
```
