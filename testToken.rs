#![cfg_attr(not(feature = "std"), no_std)]

use ink::storage::Mapping;

#[ink::contract]
mod erc20 {
    #[ink(storage)]
    pub struct ERC20 {
        name: String,
        symbol: String,
        decimals: u8,
        total_supply: Balance,
        balances: Mapping<AccountId, Balance>,
        allowances: Mapping<(AccountId, AccountId), Balance>,
    }

    impl ERC20 {
        #[ink(constructor)]
        pub fn new(name: String, symbol: String, decimals: u8, initial_supply: Balance) -> Self {
            let caller = Self::env().caller();
            let mut balances = Mapping::default();
            balances.insert(caller, &initial_supply);
            Self {
                name,
                symbol,
                decimals,
                total_supply: initial_supply,
                balances,
                allowances: Mapping::default(),
            }
        }

        #[ink(message)]
        pub fn name(&self) -> String {
            self.name.clone()
        }

        #[ink(message)]
        pub fn symbol(&self) -> String {
            self.symbol.clone()
        }

        #[ink(message)]
        pub fn decimals(&self) -> u8 {
            self.decimals
        }

        #[ink(message)]
        pub fn total_supply(&self) -> Balance {
            self.total_supply
        }

        #[ink(message)]
        pub fn balance_of(&self, account: AccountId) -> Balance {
            self.balances.get(account).unwrap_or_default()
        }

        #[ink(message)]
        pub fn transfer(&mut self, to: AccountId, amount: Balance) -> Result<(), String> {
            let from = self.env().caller();
            self.transfer_from_to(from, to, amount)
        }

        #[ink(message)]
        pub fn approve(&mut self, spender: AccountId, amount: Balance) -> Result<(), String> {
            let owner = self.env().caller();
            self.allowances.insert((owner, spender), &amount);
            Ok(())
        }

        #[ink(message)]
        pub fn allowance(&self, owner: AccountId, spender: AccountId) -> Balance {
            self.allowances.get((owner, spender)).unwrap_or_default()
        }

        #[ink(message)]
        pub fn transfer_from(&mut self, from: AccountId, to: AccountId, amount: Balance) -> Result<(), String> {
            let caller = self.env().caller();
            let allowance = self.allowances.get((from, caller)).unwrap_or_default();
            if allowance < amount {
                return Err(String::from("Allowance exceeded"));
            }
            self.allowances.insert((from, caller), &(allowance - amount));
            self.transfer_from_to(from, to, amount)
        }

        fn transfer_from_to(&mut self, from: AccountId, to: AccountId, amount: Balance) -> Result<(), String> {
            let sender_balance = self.balances.get(from).unwrap_or_default();
            if sender_balance < amount {
                return Err(String::from("Insufficient balance"));
            }
            self.balances.insert(from, &(sender_balance - amount));
            let recipient_balance = self.balances.get(to).unwrap_or_default();
            self.balances.insert(to, &(recipient_balance + amount));
            Ok(())
        }
    }
}
