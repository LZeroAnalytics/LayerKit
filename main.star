ethereum_package = import_module("github.com/ethpandaops/ethereum-package/main.star")
contract_deployer = import_module("./src/contracts/contract_deployer.star")

def run(plan):
    ethereum_args = {"network_params": {"preset": "minimal"}, "additional_services": ["blockscout"]}

    # Run Ethereum package
    l1 = ethereum_package.run(plan, ethereum_args)
    all_l1_participants = l1.all_participants

    # Key and address for deployment
    l1_private_key = l1.pre_funded_accounts[
        12
    ].private_key  # reserved for L2 contract deployers
    l1_address = l1.pre_funded_accounts[
        12
    ].address
    rpc_url = all_l1_participants[0].el_context.rpc_http_url

    plan.print(all_l1_participants)
    plan.print(l1_private_key)
    plan.print(l1_address)
    plan.print(rpc_url)

    #Wait for syncing to be done
    plan.wait(
        service_name = all_l1_participants[0].el_context.el_metrics_info[0]["name"],
        recipe = PostHttpRequestRecipe(
            port_id="rpc",
            endpoint="",
            body='{"jsonrpc": "2.0", "method": "eth_syncing", "params": [], "id": 1}',
            headers={
                "Content-Type": "application/json"
            },
            extract = {
                "status": ".result"
            }
        ),
        field = "extract.status",
        assertion = "==",
        target_value = False,
        interval = "1s",
        timeout = "5m",
        description = "Waiting for node to sync"
    )

    # Deploy LayerZero contracts
    contract_deployer.deploy_contracts(plan, rpc_url, l1_private_key, 1, l1_address)
