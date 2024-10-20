def deploy_contract(
        plan,
        rpc_url,
        owner_private_key,
        vid,
        message_libs,
        price_feed,
        signers,
        quorum,
        admins
):

    dvn_contract = plan.upload_files(
        src = "contracts/DVNMock.sol"
    )
    dvn_deployment = plan.run_sh(
        name="contract-deployer",
        description="Deploying DVN Mock",
        image="tiljordan/layerzero-dev:v1.0.0",
        files = {
            "/tmp/dvn": dvn_contract
        },
        run="forge create contracts/mocks/DVNMock.sol:DVNMock --json --rpc-url {} --private-key {} --constructor-args {} \"{}\" {} \"{}\" {} \"{}\"".format(
            rpc_url,
            owner_private_key,
            vid,
            message_libs,
            price_feed,
            signers,
            quorum,
            admins
        ),
    )