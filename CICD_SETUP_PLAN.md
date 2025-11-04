# CI/CD Setup Plan

This document outlines the plan to establish a professional Continuous Integration and Continuous Deployment (CI/CD) workflow for this project.

## Phase 1: Local Development with Firebase Emulators

This phase will allow for rapid, offline testing of the app and cloud functions.

- [ ] **1.1: Initialize Emulators:** Run `firebase init emulators` to create the initial configuration.
- [ ] **1.2: Configure Emulators:** Modify `firebase.json` to specify which emulators to use (Auth, Functions, Firestore, Hosting).
- [ ] **1.3: Configure App for Emulators:** Modify the application's source code (`main.dart`) to detect when it's in debug mode and connect to the local emulators instead of the live Firebase project.
- [ ] **1.4: Create Emulator Script:** Create a script (`scripts/run_emulators.sh`) to start the emulator suite with one command.
- [ ] **1.5: Document Emulator Usage:** Add instructions to the `README.md` on how to use the emulators for local development.

## Phase 2: Automated Testing with GitHub Actions

This phase will ensure that tests are automatically run for every code change, preventing regressions.

- [ ] **2.1: Create Workflow File:** Create a new GitHub Actions workflow file at `.github/workflows/run_tests.yml`.
- [ ] **2.2: Define Workflow Trigger:** Configure the workflow to trigger on every `push` to any branch.
- [ ] **2.3: Define Workflow Steps:** Add steps to the workflow to:
    - Check out the code.
    - Set up the Flutter environment.
    - Run `flutter pub get`.
    - Run `flutter analyze` to check for code quality issues.
    - Run `flutter test` to run the unit and widget tests.

## Phase 3: Staging Environment & Cloud Testing

This phase will automatically deploy feature branches to a temporary URL for review and testing before merging.

- [ ] **3.1: Create Workflow File:** Create a new GitHub Actions workflow file at `.github/workflows/deploy_preview.yml`.
- [ ] **32.2: Define Workflow Trigger:** Configure the workflow to trigger whenever a `pull_request` is opened or updated against the `main` branch.
- [ ] **3.3: Define Workflow Steps:** Add steps to the workflow to:
    - Check out the code.
    - Run the test suite from Phase 2.
    - If tests pass, use the `firebase-hosting-deploy` GitHub Action to deploy to a preview channel.
    - Configure the action to post the unique preview URL as a comment on the pull request.

## Phase 4: Automated Production Deployment

This phase will automate the final deployment to your live application.

- [ ] **4.1: Create Workflow File:** Create a new GitHub Actions workflow file at `.github/workflows/deploy_production.yml`.
- [ ] **4.2: Define Workflow Trigger:** Configure the workflow to trigger only when a `pull_request` is **merged** into the `main` branch.
- [ ] **4.3: Define Workflow Steps:** Add steps to the workflow to:
    - Check out the code.
    - Run the test suite from Phase 2.
    - If tests pass, run the `scripts/deploy_web.sh` script to build and deploy the app to your live Firebase Hosting URL.
- [ ] **4.4: Secure Secrets:** Ensure that the `FIREBASE_TOKEN` and any other required secrets are securely stored in the GitHub repository's secrets configuration and passed to the workflow.
