def deploy_contracts(plan, rpc_url, owner_private_key, endpoint_id, owner_address,):
    plan.run_sh(
        name="contract-deployer",
        description="Deploying the LayerZero contracts",
        image="tiljordan/layerzero-deployer:v1.0.0",
        run="forge create contracts/EndpointV2.sol:EndpointV2 --rpc-url {} --private-key {} --constructor-args {} {}".format(
            rpc_url,
            owner_private_key,
            endpoint_id,
            owner_address
        ),
    )