# CI/CD Setup Plan

This document outlines the plan to establish a professional Continuous Integration and Continuous Deployment (CI/CD) workflow for this project.

---

## Phase 1: Local Development with Firebase Emulators

**Goal:** Allow for rapid, offline testing of the app and cloud functions.

- [ ] **1.1: Initialize Emulators**
    - **Work Items:** I will run the `firebase init emulators` command and guide you through the interactive setup prompts.
    - **Purpose:** This creates the configuration file (`firebase.json`) and downloads the emulator software, which is the first step to being able to run Firebase services locally.

- [ ] **1.2: Configure Emulators**
    - **Work Items:** I will modify `firebase.json` to specify which emulators to use (Auth, Functions, Firestore, Hosting).
    - **Purpose:** This tells the Firebase CLI which services we want to simulate locally.

- [ ] **1.3: Configure App for Emulators**
    - **Work Items:** I will modify the application's source code (`main.dart`) to detect when it's in debug mode and connect to the local emulators instead of the live Firebase project.
    - **Purpose:** This allows the Flutter app to communicate with the local emulators on your machine for testing, instead of touching your live production data.

- [ ] **1.4: Create Emulator Script**
    - **Work Items:** I will create a new script at `scripts/run_emulators.sh`.
    - **Purpose:** This provides a simple, one-command way to start the entire suite of emulators.

- [ ] **1.5: Document Emulator Usage**
    - **Work Items:** I will add a new section to your `README.md` file.
    - **Purpose:** This documents how any developer on the project can use the new emulator script for easy local development.

---

## Phase 2: Automated Testing with GitHub Actions

**Goal:** Ensure that tests are automatically run for every code change, preventing regressions.

- [x] **2.1: Create Workflow File**
    - **Work Items:** I will create a new directory and file: `.github/workflows/run_tests.yml`.
    - **Purpose:** This file will contain the instructions for the automated testing process (the CI pipeline).

- [ ] **2.2: Define Workflow Trigger**
    - **Work Items:** I will add configuration to the `run_tests.yml` file.
    - **Purpose:** This will configure the workflow to trigger automatically on every `push` to any branch in your GitHub repository.

- [ ] **2.3: Define Workflow Steps**
    - **Work Items:** I will add the specific job steps to the `run_tests.yml` file.
    - **Purpose:** These steps will check out the code, set up the Flutter environment, install dependencies, run the code analyzer, run your widget/unit tests, and build the debug APK to ensure it compiles.

---

## Phase 3: Staging Environment & Cloud Testing

**Goal:** Automatically deploy feature branches to a temporary URL for review and run integration tests on a realistic cloud-based Android device.

- [ ] **3.1: Create Workflow File**
    - **Work Items:** I will create a new GitHub Actions workflow file at `.github/workflows/deploy_preview.yml`.
    - **Purpose:** This file will contain the instructions for deploying a temporary preview of the app and running cloud tests.

- [ ] **3.2: Define Workflow Trigger**
    - **Work Items:** I will add configuration to the `deploy_preview.yml` file.
    - **Purpose:** This will configure the workflow to trigger automatically whenever a `pull_request` is opened or updated against the `main` branch.

- [ ] **3.3: Define Deployment Steps**
    - **Work Items:** I will add job steps to the `deploy_preview.yml` file for deployment.
    - **Purpose:** These steps will run the test suite, and if they pass, will deploy the web app to a unique, temporary preview URL and post that URL as a comment on the pull request.

- [ ] **3.4: Define Cloud Testing Steps (Cuttlefish)**
    - **Work Items:** I will add a second job to the `deploy_preview.yml` file for running tests on Cuttlefish.
    - **Purpose:** These steps will provision a Google Cloud VM, launch a Cuttlefish virtual Android device, build and install the debug APK, run integration/end-to-end tests against it, and report the results back to the pull request. This provides high-fidelity testing on a realistic device, as you requested.

---

## Phase 4: Automated Production Deployment

**Goal:** Automate the final deployment to your live application to ensure it is safe and consistent.

- [ ] **4.1: Create Workflow File**
    - **Work Items:** I will create a new GitHub Actions workflow file at `.github/workflows/deploy_production.yml`.
    - **Purpose:** This file will contain the instructions for deploying the app to your live users.

- [ ] **4.2: Define Workflow Trigger**
    - **Work Items:** I will add configuration to the `deploy_production.yml` file.
    - **Purpose:** This will configure the workflow to trigger automatically only when a `pull_request` is **merged** into the `main` branch.

- [ ] **4.3: Define Workflow Steps**
    - **Work Items:** I will add the specific job steps to the `deploy_production.yml` file.
    - **Purpose:** These steps will run the tests, and if they pass, will execute our `scripts/deploy_web.sh` script to build and deploy the app to your live production URL.

- [ ] **4.4: Secure Secrets**
    - **Work Items:** This step is a manual configuration for you. I will guide you on where to do it.
    - **Purpose:** To allow the automated workflow to authenticate with Firebase, your `FIREBASE_TOKEN` must be securely stored in the GitHub repository's "Secrets" configuration.

---

## Phase 5: Natural Language Testing Framework (Future)

**Goal:** Create a custom testing framework that allows tests to be driven by plain English commands, interpreted by Gemini.

- [ ] **5.1: Design Command Structure:** Define a clear, consistent structure for natural language commands (e.g., "tap the 'Add' button", "verify 'Hello' is visible").
- [ ] **5.2: Implement Test Runner:** Create a Dart test helper function that takes a natural language string, parses it, and maps it to the corresponding `flutter_test` widget tester action (e.g., `tester.tap`, `expect`).
- [ ] **5.3: Write Example Tests:** Convert an existing widget test to use the new natural language runner to prove the concept.
