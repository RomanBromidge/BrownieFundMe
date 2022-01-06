from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deploy_fund_me():
    # Always need to add an account as we're making changes to the blockchain
    account = get_account()

    # We need to pass the priceFeed address to the constructor for the contract

    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    # If we're in development mode
    else:
        # Get the address of the latest mock aggregator
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    # 'publish_source' is set to True to publish the source code to the blockchain
    # This means that the code is published to the blockchain and can be accessed by anyone via Etherscan etc
    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    return fund_me


def main():
    deploy_fund_me()
