//
//  ExceptionHandlingExperiment.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 23/08/21.
//

import Foundation

class ExceptionHandling: NSObject {
	
	private var accountHolder1: AccountHolder?
	private var accountHolder2: AccountHolder?
	
	private var atmMachine = ATMMachine()
	
	override init() {
		super.init()
		
		// create user account
		accountHolder1 = createUser(name: "user1", accountNumber: "123456789", initialDeposit: 50.0)
		accountHolder2 = createUser(name: "user2", accountNumber: "123456789", initialDeposit: 1000.0)
		
		// user2
		if let user2 = accountHolder2 {
			onlineCredit(user: user2, amount: 5000.0) // 6000
			onlineCredit(user: user2, amount: 12000.0) // throw an error, reach limit
			onlineCredit(user: user2, amount: 5000.0) // 11000
			onlineCredit(user: user2, amount: 5000.0) // 16000
						
			withdrawFromATM(user: user2, amount: 15100) // throw an exception -- insufficient cash
			withdrawFromATM(user: user2, amount: 4000) // 12000
		}
	}
	
	func createUser(name: String, accountNumber: String, initialDeposit: Double) -> AccountHolder? {
		var user: AccountHolder?
		
		do {
			user = try AccountHolder(name: name, accountNumber: accountNumber, initialDeposit: initialDeposit)
			print(name + " -- Account created successfully.")
			
		} catch let error {
			
			if let error = error as? AccountHolderError, error == AccountHolderError.belowMinimumAmount {
				print("To create an account, you need to deposit at least Rs \(AccountHolder.minimumAmount)")
			}
		}
		return user
	}
	
	func onlineCredit(user: AccountHolder, amount: Double) {
		do {
			let currentBalance = try user.credit(value: amount)
			print("Credit successful - Balance of \(user.name) is \(currentBalance)")
			
		} catch let error {
			
			if let error = error as? AccountHolderError, error == AccountHolderError.creditLimitExceed {
				print("Credit Failed as deposited amount exceeds limit \(AccountHolder.creditLimit) ")
			}
		}
	}
	
	func withdrawFromATM(user: AccountHolder, amount: Double) {
		do {
			let currentBalance = try atmMachine.withdraw(accountHolder: user, amount: amount)
			print("Withdraw successful - Balance of \(user.name) is \(currentBalance)")
			
		} catch let error {
			
			if let error = error as? ATMMachineError, error == ATMMachineError.insufficientCash {
				print("Withdraw failed - Insufficient cash at ATM.")
			}
			
			if let error = error as? AccountHolderError, error == AccountHolderError.withdrawLimitExceed {
				print("Withdraw failed - insuffient balance in account")
			}
			
		}
	}
	
}

enum AccountHolderError: Error {
	case belowMinimumAmount
	case withdrawLimitExceed
	case creditLimitExceed
}

/// Account holder have a valid account and
class AccountHolder: NSObject {
	
	let name: String
	let accountNumber: String
	var amount: Double
	
	static let minimumAmount: Double = 100.0
	static let creditLimit: Double = 10000.0
	
	init(name: String, accountNumber: String, initialDeposit: Double) throws {
		if initialDeposit < AccountHolder.minimumAmount {
			throw AccountHolderError.belowMinimumAmount
		}
		
		self.name = name
		self.accountNumber = accountNumber
		self.amount = initialDeposit
		super.init()
	}
	
	func withdrawMoney(value: Double) throws -> Double {
		// check whether the amount goes below to minimum amount or not
		var tempAmount = amount
		tempAmount -= value
		if tempAmount < AccountHolder.minimumAmount {
			throw AccountHolderError.withdrawLimitExceed
		}
		
		amount = tempAmount
		return amount
	}
	
	func credit(value: Double) throws -> Double {
		if value > AccountHolder.creditLimit {
			throw AccountHolderError.creditLimitExceed
		}
		
		amount += value
		return amount
	}
}

enum ATMMachineError: Error {
	case insufficientCash
	case bankServerDown
}


/// It helps the customer to withdraw money
class ATMMachine: NSObject {
	
	private let bankServerOnline = true
	private var atmCurrentCash: Double = 15000.0
	
	func withdraw(accountHolder: AccountHolder, amount: Double) throws -> Double {
		
		if !bankServerOnline {
			throw ATMMachineError.bankServerDown
		}
		
		if amount > atmCurrentCash {
			throw ATMMachineError.insufficientCash
		}
		
		do {
			let accountHolderRemainingAmount = try accountHolder.withdrawMoney(value: amount)
			atmCurrentCash -= amount
			return accountHolderRemainingAmount
			
		} catch {
			throw AccountHolderError.withdrawLimitExceed // rethrow an exception
		}
	}
}
