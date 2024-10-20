def deploy_contract(plan, rpc_url, owner_private_key, owner_address):

    price_feed_contract = plan.upload_files(
        src = "contracts/PriceFeedMock.sol"
    )
    uln_send = plan.run_sh(
        name="contract-deployer",
        description="Deploying Price Feed Mock",
        image="tiljordan/layerzero-dev:v1.0.0",
        files = {
            "/tmp/feed": price_feed_contract
        },
        run="forge create contracts/mocks/PriceFeedMock.sol:PriceFeedMock --json --rpc-url {} --private-key {} --constructor-args {}".format(
            rpc_url,
            owner_private_key,
            owner_address
        ),
    )