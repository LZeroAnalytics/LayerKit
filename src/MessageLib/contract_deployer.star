def deploy_uln_send(plan, rpc_url, owner_private_key, endpoint_id, owner_address):
    uln_send = plan.run_sh(
        name="contract-deployer",
        description="Deploying ULN302 Send",
        image="tiljordan/layerzero-deployer:v1.0.6",
        run="forge create ../messagelib/contracts/uln/uln302/SendUln302.sol:SendUln302 --json --rpc-url {} --private-key {} --constructor-args {} {} {}".format(
            rpc_url,
            owner_private_key,
            "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
            1000000000000,
            100000
        ),
        store = [
            StoreSpec(src = "/workspace/packages/layerzero-v2/evm/messagelib/out/SendUln302.sol/SendUln302.json", name = "uln-" + str(endpoint_id)),
        ],
    )

def deploy_uln_receive(plan, rpc_url, owner_private_key, endpoint_id, owner_address):
    uln_receive = plan.run_sh(
        name="contract-deployer",
        description="Deploying ULN302 Receive",
        image="tiljordan/layerzero-deployer:v1.0.6",
        run="forge create ../messagelib/contracts/uln/uln302/ReceiveUln302.sol:ReceiveUln302 --json --rpc-url {} --private-key {} --constructor-args {}".format(
            rpc_url,
            owner_private_key,
            "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009"
        ),
    )