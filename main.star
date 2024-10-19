optimism_package = import_module("github.com/tiljrd/optimism-package/main.star")
contract_deployer = import_module("./src/contracts/contract_deployer.star")

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

                    }
                }
            ],
            "op_contract_deployer_params": {
                "image": "mslipper/op-deployer:latest",
                "artifacts_url": "https://storage.googleapis.com/oplabs-contract-artifacts/artifacts-v1-4accd01f0c35c26f24d2aa71aba898dd7e5085a2ce5daadc8a84b10caf113409.tar.gz"
            }
        }
    }
    package_output = optimism_package.run(plan, optimism_args)

    plan.print(package_output)

    bridge_address = package_output.bridge_address
    network_id = package_output.l1_network_params.network_id

    # L1 Key and address
    private_key = package_output.pre_funded_accounts[
        12
    ].private_key
    address = package_output.pre_funded_accounts[
        12
    ].address
    l1_rpc_url = package_output.all_l1_participants[0].el_context.rpc_http_url

    contract_deployer.bridge_tokens(plan, private_key, l1_rpc_url, bridge_address, network_id)

    l2_rpc_url = package_output.all_l2_participants[0].el_context.rpc_http_url

    # Deploy LayerZero contracts on L1
    contract_deployer.deploy_contracts(plan, l1_rpc_url, private_key, 1, address)

    # Deploy LayerZero contracts on L2
    #TODO: Wait for address to receive balance
    contract_deployer.deploy_contracts(plan, l2_rpc_url, private_key, 2, address)