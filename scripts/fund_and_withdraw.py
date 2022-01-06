from brownie import FundMe
from scripts.helpful_scripts import get_account


def fund():
    print("Funding...")
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    print(f"Entrance fee: {entrance_fee}")
    fund_me.fund({"from": account, "value": entrance_fee})
    print("Funded")


def withdraw():
    print("Withdrawing...")
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
