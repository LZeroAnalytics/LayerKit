def deploy_contract(plan, rpc_url, owner_private_key, endpoint_id, owner_address):
    plan.run_sh(
        name="contract-deployer",
        description="Deploying EndpointV2",
        image="tiljordan/layerzero-deployer:v1.0.5",
        run="forge create contracts/EndpointV2.sol:EndpointV2 --json --rpc-url {} --private-key {} --constructor-args {} {}".format(
            rpc_url,
            owner_private_key,
            endpoint_id,
            owner_address
        ),
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


def register_library(plan, rpc_url, private_key, library_address):
    plan.print("Registering library")

