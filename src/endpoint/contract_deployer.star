def deploy_contract(plan, rpc_url, owner_private_key, endpoint_id, owner_address):
    plan.run_sh(
        name="contract-deployer",
        description="Deploying EndpointV2",
        image="tiljordan/layerzero-deployer:v1.0.6",
        run="forge create contracts/EndpointV2.sol:EndpointV2 --json --rpc-url {} --private-key {} --constructor-args {} {}".format(
            rpc_url,
            owner_private_key,
            endpoint_id,
            owner_address
        ),
        store = [
            StoreSpec(src = "/workspace/packages/layerzero-v2/evm/protocol/out/EndpointV2.sol/EndpointV2.json", name = "endpoint-" + str(endpoint_id)),
        ],
    )

def bridge_tokens(plan, private_key, rpc_url, bridge_address, chain_id):
    sender_config = {
        "PrivateKey": private_key,
        "RPCURL": rpc_url,
        "BridgeAddress": bridge_address,
        "ChainId": chain_id
    }
    sender_artifact = plan.render_templates(
        config = {
            "sender.py": struct(
                template = read_file("templates/sender.py.tmpl"),
                data = sender_config
            )
        },
        name="token-sender-artifact"
    )

    plan.run_sh(
        name="token-sender",
        description="Bridging tokens to L2",
        run="python /tmp/sender.py",
        image="ethpandaops/python-web3",
        files = {
            "/tmp": sender_artifact
        }
    )


def register_library(plan, rpc_url, private_key, owner_address, endpoint_address, library_address, endpoint_id):
    endpoint_contract = plan.get_files_artifact(
        name = "endpoint-" + str(endpoint_id)
    )

    register_config = {
        "abi_file_path": "/tmp/abi/EndpointV2.json",
        "rpc_url": rpc_url,
        "contract_address": endpoint_address,
        "library_address": library_address,
        "owner_address": owner_address,
        "owner_private_key": private_key
    }
    register_library_script = plan.render_templates(
        config = {
            "register_library.py": struct(
                template = read_file("templates/register_library.py.tmpl"),
                data = register_config
            )
        },
    )

    plan.run_sh(
        description="Registering library with endpoint",
        run="python /tmp/register_library.py",
        image="ethpandaops/python-web3",
        files = {
            "/tmp": register_library_script,
            "/tmp/abi": endpoint_contract
        }
    )


def set_send_default(plan, rpc_url, private_key, owner_address, destination_eid, endpoint_address, library_address, endpoint_id):
    endpoint_contract = plan.get_files_artifact(
        name = "endpoint-" + str(endpoint_id)
    )

    send_config = {
        "abi_file_path": "/tmp/abi/EndpointV2.json",
        "rpc_url": rpc_url,
        "contract_address": endpoint_address,
        "library_address": library_address,
        "owner_address": owner_address,
        "owner_private_key": private_key,
        "destination_eid": destination_eid,
    }
    send_default_script = plan.render_templates(
        config = {
            "set_send_default.py": struct(
                template = read_file("templates/set_send_default.py.tmpl"),
                data = send_config
            )
        },
    )

    plan.run_sh(
        description="Setting default send",
        run="python /tmp/set_send_default.py",
        image="ethpandaops/python-web3",
        files = {
            "/tmp": send_default_script,
            "/tmp/abi": endpoint_contract
        }
    )


def set_receive_default(plan, rpc_url, private_key, owner_address, destination_eid, endpoint_address, library_address, endpoint_id):
    endpoint_contract = plan.get_files_artifact(
        name = "endpoint-" + str(endpoint_id)
    )

    receive_config = {
        "abi_file_path": "/tmp/abi/EndpointV2.json",
        "rpc_url": rpc_url,
        "contract_address": endpoint_address,
        "library_address": library_address,
        "owner_address": owner_address,
        "owner_private_key": private_key,
        "destination_eid": destination_eid,
    }
    receive_default_script = plan.render_templates(
        config = {
            "set_receive_default.py": struct(
                template = read_file("templates/set_receive_default.py.tmpl"),
                data = receive_config
            )
        },
    )

    plan.run_sh(
        description="Setting default receive",
        run="python /tmp/set_receive_default.py",
        image="ethpandaops/python-web3",
        files = {
            "/tmp": receive_default_script,
            "/tmp/abi": endpoint_contract
        }
    )