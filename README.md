# Trusted Setup

Scripts used to perform the trusted-setup ceremony of WORM Privacy circuits.

## Step 1. Install the requirements

1. Install NodeJS: https://nodejs.org/en/download
2. Install SnarkJS: `npm i -g snarkjs`

## Step 2. Get a GitHub token

1. Go to **Settings** section of your GitHub profile.
2. Go to **Developer settings**.
3. Select **Personal access token** and then **Tokens (classic)**.
4. Now select **Generate new token (classic)**.
5. Choose all of the permissions.
6. Store the token somewhere, you'll need it later!

## Step 3.  Fork this repository

1. Click on the **Fork** button of this repository.
2. Clone the forked version of this repository on your machine: `https://github.com/[YOUR GITHUB USERNAME]/trusted-setup`

## Step 4. Participate

1. Go to the forked repo: `cd trusted-setup`.
2. Run: `make contribute NAME=[YOUR GITHUB USERNAME] ENTROPY=[SOME RANDOM ENTROPY] PERSONAL_GH_TOKEN=[YOUR GITHUB TOKEN]`
