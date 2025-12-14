# Trusted Setup

Scripts used to perform the trusted setup ceremony for WORM Privacy circuits.

⚠️ Contributing to all circuits is expected to take at least one hour! ⚠️

## Step 1. Install the requirements

1. Install `wget` and `jq`: `sudo apt install wget jq`
2. Install NodeJS: https://nodejs.org/en/download
3. Install SnarkJS: `npm i -g snarkjs`
4. Install GitHub CLI: https://cli.github.com/

## Step 2. Get a GitHub token

1. Go to the **Settings** section of your GitHub profile.
2. Navigate to **Developer settings**.
3. Select **Personal access token**, then choose **Tokens (classic)**.
4. Click **Generate new token (classic)**.
5. Select all necessary permissions and generate the token.
6. Store the token somewhere, you'll need it later!

## Step 3.  Fork this repository

1. Click the **Fork** button at the top of this repository’s page. (Remove the old fork and create a new one if you have already forked the repo!)
2. Clone your forked repository to your local machine using the following command:
   ```bash
   git clone https://github.com/[YOUR_GITHUB_USERNAME]/trusted-setup
   ```

## Step 4. Participate

1. Go to the forked repo: `cd trusted-setup`.
2. Run: `make contribute PERSONAL_GH_TOKEN=[YOUR GITHUB TOKEN]`
