# Changelog

All notable changes to this skill are documented here.

## [1.5.0] - 2024-03-15

### Added
- Review of approval policy YAML in addition to security policies
- Detection of missing code owner approvals for sensitive paths
- Severity classification for identified issues (critical, high, medium, low)

### Changed
- Restructured output format to include a compliant items section
- Improved remediation suggestions with concrete YAML examples

### Fixed
- Correctly handles empty `rules` arrays in security policy blocks

## [1.4.0] - 2024-01-20

### Added
- Initial support for GitLab 16.x security policy format changes

## [1.3.0] - 2023-11-05

### Added
- First public release
- Static analysis of `.gitlab/security-policy-project/policy.yml`
- Approval rule gap detection
