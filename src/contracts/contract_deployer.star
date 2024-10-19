def deploy_contracts(plan, owner_private_key, owner_address):
    plan.add_service(
        name="contract-deployer",
        description="Deploying the LayerZero contracts",
        config = ServiceConfig(
            image="tiljordan/layerzero-deployer:v1.0.0",
            entrypoint=[
                "/bin/bash",
                "-c",
                "tail -f /dev/null"
            ]
        )
    )