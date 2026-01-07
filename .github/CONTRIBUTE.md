# Contribute to Github Actions workflows for the DevOps Tools team
  
Welcome to the repository containing the Github Action workflows used by the DevOps Tools team.
We are delighted that you want to contribute to this repository.

We accept all types of contributions; minor typo fixes to new topics.

This guide will help you understand how you can participate in our project.

The following guidelines will help you get started contributing to our project.

## Contents

- [Contribute to Github Actions workflows for the DevOps Tools team](#contribute-to-github-actions-workflows-for-the-devops-tools-team)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
  - [How can I contribute?](#how-can-i-contribute)
  - [Pull Request Process](#pull-request-process)
  - [Coding standards](#coding-standards)
  - [Tests](#tests)
  - [Versioning Strategy](#versioning-strategy)
  - [Additional Resources](#additional-resources)

## Prerequisites

Before you start contributing, make sure you have the following skills:

- Advanced knowledge of Git, Gitflow, GitHub, and Github Actions.

## How can I contribute?

We welcome contributions in a variety of forms, including bug reports, feature requests, code contributions, and documentation improvements. The objective is to improve the DevOps Tools team so that it correctly meets the needs. Here's how you can get involved:

- **Code Contributions:** To contribute code, please follow the [Pull Request Process](#pull-request-process) below.

- **Documentation:** If you want to improve the documentation, you can submit changes directly through GitHub.

- **Report Bugs:** If you encounter any issues or bugs in the DevOps Tools team, please open an issue on GitHub with a clear description of the issue, steps to reproduce it, and all relevant information.

- **Feature Requests:** Feel free to open issues on GitHub to suggest new features or improvements to existing features.

Please follow the official Github documentation for reporting Bugs and Features [Reporting Bugs and Features](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/best-practices-for-projects)

## Pull Request Process

- **Clone:** You can start by cloning the copy of your own fork to your local machine using git clone.

- **Branch creation:** You then create a new branch from the main branch of the main project with git checkout -b name-of-the-new-branch.

```bash
cd first-contribution
```

Now create a branch using the `git switch` command:

```bash
git switch -c feature/your-new-branch
```

For example :

```bash
git switch -c feature/add-functionality-workflow
```

- **Code Development and Testing:** You write, modify and test the code on your own local branch while respecting the [Exakis Nelite DevOps Tools Coding Standards](#coding-standards) to ensure that the changes work as expected.
  
- **Commit:** Commit your changes locally with git commit -m "commit message", with a clear and concise commit message to help the DevOps Tools team during review.

```bash
git commit -m "commit message"
```

   **Example 1 of the commit message:** Fix issue #123 in the connectivity section: Added new peering connections.
   **Example 2 of the commit message:** Fix issue #124 in the identity part: Resolved problems related to traffic filtration.
   **Example 3 of the commit message:** Fix issue #125 in the management part: Resolved query execution problems on Log Analytics.

- **Push to remote repository:** push your changes to the remote repository.

```bash
git push -u origin feature/your-branch
```

Replace `your-branch` with the name of the branch you created.

Now you can open a pull request:

- **Create a Pull Request (PR)** to the `main` branch of our main repository.
Be prepared to provide additional information or make adjustments based on feedback during the review process.
Your Pull Request is accepted after code validation by the DevOps Tools team.

## Coding standards

We follow specific coding standards to maintain a consistent and clean codebase. Make sure your contributions meet these standards.

You can find detailed coding guidelines in our [Azure Resource Deployment - CAF Terraform](https://learn.microsoft.com/fr-fr/azure/cloud-adoption-framework/ready/landing-zone/deploy-landing-zones-with-terraform).

Before merging a new workflow, the following conditions must be met:

- Should be as simple as necessary for the service.
- There are many programming languages and tools. Right now we don't have a page that allows for a very large number of workflows, so we have to be a little picky about what we accept. Less popular tools or languages may not be accepted.
- Automation and CI workflows should not send data to any third-party services except for the purpose of installing dependencies.
- Automation and CI workflows cannot depend on a paid service or product.
- We require that actions outside of the action organization be pinned to a specific SHA.

## Tests
  
Before submitting a Pull Request contribution, make sure you follow the following steps so that:

- Run existing tests locally.
- Add unit tests for any new features.
- Perform integration tests if necessary.

## Versioning Strategy

We use a versioning system based on Semantic Versioning 2.0.0 (SemVer). Here's how our versioning strategy works:

- The versions, for Github workflows, are in MAJOR.MINOR.PATCH format (e.g.: 1.0.0).
- MAJOR increment for major incompatible changes.
- MINOR increment for new compatible features.
- PATCH increment for compatible bug fixes.

**MAJOR increment example:**

- When major changes are made to workflows, such as major modifications like additions of mandatory parameters or new non-optional options.

**Example of MINOR increment:**

- When adding new features or performance improvements to Github workflows, managing backward compatibility with the previous version.

**PATCH increment example:**

- When performing bug fixes or security patches without introducing new features or major changes, the goal is to improve the stability of workflows.

Be sure to update the appropriate version numbers in your code and pull request.

Please follow the official Github documentation for reporting Bugs and features Versioning Strategy

## Additional Resources

For more information and resources related to our DevOps tools, please visit our Github Governance Wiki and our Azure Technical Architecture Documentation.

Thank you for your contribution and support to improve the DevOps Exakis Nelite tools !
