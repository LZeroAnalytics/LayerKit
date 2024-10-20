optimism_package = import_module("github.com/tiljrd/optimism-package/main.star")
endpoint_deployer = import_module("./src/endpoint/contract_deployer.star")
message_lib_deployer = import_module("./src/MessageLib/contract_deployer.star")
executor_deployer = import_module("./src/Executor/contract_deployer.star")
price_feed_deployer = import_module("./src/PriceFeed/contract_deployer.star")
dvn_deployer = import_module("./src/DVN/contract_deployer.star")

def run(plan):
    # Add Ethereum and Optimism network
    optimism_args = {
        "optimism_package": {
            "chains": [
                {
                    "participants": [
                        {
                            "el_type": "op-geth",
                            "el_image": "",
                            "cl_type": "op-node",
                            "cl_image": "",
                            "count": 1
                        }
                    ],
                    "network_params": {
                        "network": "kurtosis",
                        "network_id": "2151908",
                        "seconds_per_slot": 2,
                        "name": "op-kurtosis"

                    },
                    "additional_services": [
                    ]
                }
            ],
            "op_contract_deployer_params": {
                "image": "mslipper/op-deployer:latest",
                "artifacts_url": "https://storage.googleapis.com/oplabs-contract-artifacts/artifacts-v1-4accd01f0c35c26f24d2aa71aba898dd7e5085a2ce5daadc8a84b10caf113409.tar.gz"
            }
        },
        "ethereum_package": {
            "additional_services": [
            ]
        }
    }
    package_output = optimism_package.run(plan, optimism_args)

    plan.print(package_output)

    bridge_address = package_output.bridge_address
    network_id = package_output.l1_network_params.network_id

    # L1 Key and address
    private_key = package_output.pre_funded_accounts[
        1
    ].private_key
    address = package_output.pre_funded_accounts[
        1
    ].address
    l1_rpc_url = package_output.all_l1_participants[0].el_context.rpc_http_url

    l2_rpc_url = package_output.all_l2_participants[0].el_context.rpc_http_url

    endpoint_deployer.deploy_contract(plan, l1_rpc_url, private_key, 1, address) # 0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009

    # Bridge tokens to L2
    endpoint_deployer.bridge_tokens(plan, private_key, l1_rpc_url, bridge_address, network_id)

    # Wait for balance to arrive at L2
    token_wait_recipe = PostHttpRequestRecipe(
        port_id = "rpc",
        endpoint = "/",
        content_type = "application/json",
        body = '{"method":"eth_getBalance","params":["' + address + '", "latest"],"id":1,"jsonrpc":"2.0"}',
        extract={
            "balance": ".result"
        }
    )

    # Wait and check if balance is larger than 0
    plan.wait(
        service_name=package_output.all_l2_participants[0].el_context.service_name,
        recipe=token_wait_recipe,
        field="extract.balance",
        assertion="!=",
        target_value="0x0",
        interval="1s",
        timeout="5m",
        description="Waiting for tokens to reach L2"
    )

    # Deploy endpoint on L2
    endpoint_deployer.deploy_contract(plan, l2_rpc_url, private_key, 2, address) # 0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009

    # Deploy ULN302 Send and Receive
    # TODO: Retrieve contract addresses from deployment (tr -d '\n'")
    message_lib_deployer.deploy_uln_send(plan, l1_rpc_url, private_key, 1, address) #0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a
    message_lib_deployer.deploy_uln_receive(plan, l1_rpc_url, private_key, 1, address) # 0x70e9F1967498e8d863B371d0d6B22DA6B53E8D05
    message_lib_deployer.deploy_uln_send(plan, l2_rpc_url, private_key, 2, address) # 0x6f00cAa972723C5e1D1012cdAc385753c2AA3a93
    message_lib_deployer.deploy_uln_receive(plan, l2_rpc_url, private_key, 2, address) # 0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a

    # Deploy Executors
    executor_deployer.deploy_contract(plan, l1_rpc_url, private_key) # 0xCC97bb833F9D361Fd8F65e02Ba4b8413E1E0AE0D
    executor_deployer.deploy_contract(plan, l2_rpc_url, private_key) # 0x70e9F1967498e8d863B371d0d6B22DA6B53E8D05

    # Deploy Price Feed Mocks
    price_feed_deployer.deploy_contract(plan, l1_rpc_url, private_key, address) # 0x015B8C864D1B6e9BACd0DD666D77590cFd4188Cb
    price_feed_deployer.deploy_contract(plan, l2_rpc_url, private_key, address) # 0xCC97bb833F9D361Fd8F65e02Ba4b8413E1E0AE0D

    # Deploy DVN contracts
    dvn_deployer.deploy_contract(
        plan,
        l1_rpc_url,
        private_key,
        1,
        ['0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a', '0x70e9F1967498e8d863B371d0d6B22DA6B53E8D05'],
        '0x015B8C864D1B6e9BACd0DD666D77590cFd4188Cb',
        [address],
        1,
        [address]
    ) # 0xBFfF570853d97636b78ebf262af953308924D3D8

    dvn_deployer.deploy_contract(
        plan,
        l2_rpc_url,
        private_key,
        2,
        ['0x6f00cAa972723C5e1D1012cdAc385753c2AA3a93', '0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a'],
        '0xCC97bb833F9D361Fd8F65e02Ba4b8413E1E0AE0D',
        [address],
        1,
        [address]
    ) # 0x015B8C864D1B6e9BACd0DD666D77590cFd4188Cb

    # Register libraries with endpoints
    endpoint_deployer.register_library(
        plan,
        l1_rpc_url,
        private_key,
        address,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a",
        1
    )
    endpoint_deployer.register_library(
        plan,
        l1_rpc_url,
        private_key,
        address,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0x70e9F1967498e8d863B371d0d6B22DA6B53E8D05",
        1
    )

    endpoint_deployer.register_library(
        plan,
        l2_rpc_url,
        private_key,
        address,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0x6f00cAa972723C5e1D1012cdAc385753c2AA3a93",
        2
    )
    endpoint_deployer.register_library(
        plan,
        l2_rpc_url,
        private_key,
        address,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a",
        2
    )

    # Set default send library
    endpoint_deployer.set_send_default(
        plan,
        l1_rpc_url,
        private_key,
        address,
        2,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a",
        1
    )

    endpoint_deployer.set_send_default(
        plan,
        l2_rpc_url,
        private_key,
        address,
        1,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0x6f00cAa972723C5e1D1012cdAc385753c2AA3a93",
        2
    )

    # Set default receive library
    endpoint_deployer.set_receive_default(
        plan,
        l1_rpc_url,
        private_key,
        address,
        2,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0x70e9F1967498e8d863B371d0d6B22DA6B53E8D05",
        1
    )

    endpoint_deployer.set_receive_default(
        plan,
        l2_rpc_url,
        private_key,
        address,
        1,
        "0x6db20C530b3F96CD5ef64Da2b1b931Cb8f264009",
        "0xDeC3326BE4BaDb9A1fA7Be473Ef8370dA775889a",
        2
    )