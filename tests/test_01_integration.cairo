use testings::ERC20::ERC20;
use starknet::contract_address_const;
use starknet::ContractAddress;
use starknet::testing::set_caller_address;
use integer::u256;
use integer::u256_from_felt252;

const NAME: felt252 = 'Starknet Token';
const SYMBOL: felt252 = 'STAR';

// Helper function
fn setup() -> (ContractAddress, ContractAddress, u256) {
    let initial_supply: u256 = u256_from_felt252(2000);
    let account: ContractAddress = contract_address_const::<1>();
    let account2: ContractAddress = contract_address_const::<2>();
    let decimals: u8 = 18_u8;

    // Set account as default caller
    set_caller_address(account);

    ERC20::constructor(NAME, SYMBOL, decimals, initial_supply, account);
    (account, account2, initial_supply)
}
// Testing
#[test]
#[available_gas(2000000)]
fn test_transfer() {
    let (sender, recipient, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<2>();
    let amount: u256 = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);

    assert(ERC20::balance_of(recipient) == amount, 'Balance should eq amount');
    assert(ERC20::balance_of(sender) == supply - amount, 'Should eq supply - amount');
    assert(ERC20::get_total_supply() == supply, 'Total supply should not change');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected:('ERC20: transfer to 0', ))]
fn test_transfer_to_zero() {
    let (owner, recipient, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<0>();
    let amount: u256 = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from() {
    let (sender, recipient, supply) = setup();

    let amount: u256 = u256_from_felt252(100);

    let balanceSenderBefore: u256 = ERC20::balance_of(sender);
    let balanceRecipientBefore: u256 = ERC20::balance_of(recipient);

    set_callet_address(sender);
    ERC20::approve(recipient, amount);

    let allowance: u256 = ERC20::allowance(sender, recipient);
    set_caller_address(recipient);
    ERC20::transfer_from(sender, recipient, allowance);

    let balanceSenderAfter: u256 = ERC20::balance_of(sender);
    let balanceRecipientAfter: u256 = ERC20::balance_of(recipient);

    assert(balanceSenderAfter == balanceSenderBefore - allowance, 'Balance should eq balanceSenderBefore - allowance');
    assert(balanceRecipientAfter == balanceRecipientBefore + allowance, 'Balance should eq balanceRecipientBefore + allowance');
    assert(ERC20::get_total_supply() == supply, 'Total supply should not change');
}
