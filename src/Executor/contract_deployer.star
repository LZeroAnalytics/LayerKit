def deploy_contract(plan, rpc_url, owner_private_key):
    uln_send = plan.run_sh(
        name="contract-deployer",
        description="Deploying Executor",
        image="tiljordan/layerzero-deployer:v1.0.5",
        run="forge create ../messagelib/contracts/Executor.sol:Executor --json --rpc-url {} --private-key {}".format(
            rpc_url,
            owner_private_key
        ),
    )